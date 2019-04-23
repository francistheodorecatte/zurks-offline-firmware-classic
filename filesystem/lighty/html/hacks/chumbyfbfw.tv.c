/*
 * Freescale STMP37XX/STMP378X framebuffer driver
 *
 * Adapted for use in the Chumby by also integrating the PXP, to give the
 * user two framebuffer devices to work with.
 *
 * Author: Vitaly Wool <vital@embeddedalley.com>
 *         Sean Cross  <scross@chumby.com>
 *
 * Copyright 2008 Freescale Semiconductor, Inc. All Rights Reserved.
 * Copyright 2008 Embedded Alley Solutions, Inc All Rights Reserved.
 */

/*
 * The code contained herein is licensed under the GNU General Public
 * License. You may obtain a copy of the GNU General Public License
 * Version 2 or later at the following locations:
 *
 * http://www.opensource.org/licenses/gpl-license.html
 * http://www.gnu.org/copyleft/gpl.html
 */
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/device.h>
#include <linux/platform_device.h>
#include <linux/input.h>
#include <linux/interrupt.h>
#include <linux/fb.h>
#include <linux/init.h>
#include <linux/list.h>
#include <linux/delay.h>
#include <linux/dma-mapping.h>
#include <linux/err.h>
#include <linux/uaccess.h>
#include <linux/cpufreq.h>
#include <linux/proc_fs.h>
#include <linux/mutex.h>



#include <linux/io.h>
#include <linux/vmalloc.h>

#include <media/videobuf-dma-contig.h>

#include <mach/regs-pxp.h>


// CHUMBY_logo
#include <chumby_boot_logo_2.h>
#include <chumby_boot_logo_recovery.h>
#include <linux/init.h>
// ! CHUMBY_logo



// CHUMBY_fbsize
//
// Multiple framebuffers are presented as /dev/fbN.  This descriptor
// defines what they look like, regardless of the resulting output device.
// A later stage will take the data and scale it up or down to suit the
// needs of the output device.
static struct fb_var_screeninfo default_mode __devinitdata = {
    .activate       = FB_ACTIVATE_NOW,
    .width          = 320,
    .height         = 240,
    .xres           = 320,
    .yres           = 240,
    .xres_virtual   = 320,
    .yres_virtual   = 240*2,
    .yoffset        = 1,
    .pixclock       = 154000,
    .left_margin    = 5,
    .right_margin   = 4,
    .upper_margin   = 3,
    .lower_margin   = 3,
    .hsync_len      = 40,
    .vsync_len      = 2,
    .vmode          = FB_VMODE_NONINTERLACED,
    .bits_per_pixel = 16,
    .red.offset     = 11,
    .red.length     = 5,
    .green.offset   = 5,
    .green.length   = 6,
    .blue.offset    = 0,
    .blue.length    = 5,
};
// !CHUMBY_fbsize


#include <mach/hardware.h>
#include <mach/regs-pinctrl.h>
#include <mach/regs-lcdif.h>
#include <mach/regs-clkctrl.h>
#include <mach/regs-apbh.h>
#include <mach/lcdif.h>

#include <mach/stmp3xxx.h>

#define CHLOG(format, arg...)            \
    printk("chumbyfbfw.c - %s():%d - " format, __func__, __LINE__, ## arg)


#define NUM_SCREENS 4

#define PXP_STATUS_OFF          0
#define PXP_STATUS_ON           1
#define PXP_STATUS_TURNING_ON   2
#define PXP_STATUS_TURNING_OFF  3
#define PXP_STATUS_READY        4   // PXP should fire this time.


struct chumbyfw_fb_plane {
    struct fb_info           fb_info;

    // Something seems to be overrunning fb_info.  Padding helps, maybe?
    char                     padding[128];

    dma_addr_t               phys_start;
    dma_addr_t               cur_phys;
    void                    *virt_start;
    ssize_t                  mem_size;
    ssize_t                  map_size;
    ssize_t                  width, height, bpp;
    int                      idx;
    struct chumbyfw_fb_data *fb_data;
};

struct chumbyfw_fb_data {
    struct device                    *dev;
    struct stmp3xxx_platform_fb_data *pdata;

    int                               is_blank;
    ssize_t                           mem_size;
    ssize_t                           map_size;
    dma_addr_t                        phys_start;
    dma_addr_t                        cur_phys;
    int                               dma_irq;
    int                               err_irq;
    int                               pxp_irq;
    spinlock_t                        pxp_lock;
    struct mutex                      pxp_mutex;
    void                             *virt_start;
    wait_queue_head_t                 vsync_wait_q;
    u32                               vsync_count;
    u32                               pxp_missed_count;
    int                               pxp_status;
    struct chumbyfw_fb_plane         *planes[NUM_SCREENS];
};

#define MAX_PALETTES 16

// forward declaration.
static int chumbyfwfb_blank(int blank, struct fb_info *info);
static int pxp_setup(struct chumbyfw_fb_data *data);
//static void pxp_run(unsigned long ptr);
static int chumbyfwfb_wait_for_vsync(u32 channel, struct fb_info *info);


static unsigned char *default_panel_name;


// Global data handle.
static struct chumbyfw_fb_data *gdata;


// Used to figure out how often the PXP is firing.
static int pxp_irq_frequency   = 0;
static int lcdif_irq_frequency = 0;
static int vsync_edge_irqs     = 0;
static int cur_frame_done_irqs = 0;
static unsigned int pxp_start_jiffies   = 0;
static unsigned int pxp_stop_jiffies    = 0;

static irqreturn_t lcd_irq_handler(int irq, void *dev_id) {
    struct chumbyfw_fb_data *data = gdata;
    static int times_fired = 0;
    static int last_time   = 0;
    int did_draw_frame = 0;

    u32 status_lcd = HW_LCDIF_CTRL1_RD();
    u32 status_apbh = HW_APBH_CTRL1_RD();
    pr_debug("%s: irq %d\n", __func__, irq);

    if (status_apbh & BM_APBH_CTRL1_CH0_CMDCMPLT_IRQ)
        HW_APBH_CTRL1_CLR(BM_APBH_CTRL1_CH0_CMDCMPLT_IRQ);

    // IRQ fires at the start of frame.
    if (status_lcd & BM_LCDIF_CTRL1_VSYNC_EDGE_IRQ) {
        pr_debug("%s: VSYNC irq\n", __func__);
        vsync_edge_irqs++;
        HW_LCDIF_CTRL1_CLR(BM_LCDIF_CTRL1_VSYNC_EDGE_IRQ);
    }

    // IRQ fires at the end of the frame.
    if (status_lcd & BM_LCDIF_CTRL1_CUR_FRAME_DONE_IRQ) {
        pr_debug("%s: frame done irq\n", __func__);
        did_draw_frame = 1;
        cur_frame_done_irqs++;
        HW_LCDIF_CTRL1_CLR(BM_LCDIF_CTRL1_CUR_FRAME_DONE_IRQ);
    }

    // Error conditions.
    if (status_lcd & BM_LCDIF_CTRL1_UNDERFLOW_IRQ) {
        CHLOG("%s: underflow irq\n", __func__);
        HW_LCDIF_CTRL1_CLR(BM_LCDIF_CTRL1_UNDERFLOW_IRQ);
    }
    if (status_lcd & BM_LCDIF_CTRL1_OVERFLOW_IRQ) {
        CHLOG("%s: overflow irq\n", __func__);
        HW_LCDIF_CTRL1_CLR(BM_LCDIF_CTRL1_OVERFLOW_IRQ);
    }


    if(did_draw_frame) {
        if(!data)
            CHLOG("Data is NULL, we'll probably segfault right here\n");

        data->vsync_count++;
        wake_up_interruptible(&data->vsync_wait_q);

        // Since the frame has finished drawing, we're able to run the PXP
        // to composite the next frame.
        // Since the LCD runs at 60 Hz, and we want the PXP to run at 30 Hz, 
        // only run it every other time.
        if(data->pxp_status == PXP_STATUS_TURNING_ON) {
            HW_LCDIF_NEXT_BUF_WR(data->phys_start);
            data->pxp_status = PXP_STATUS_ON;
        }
        else if(data->pxp_status == PXP_STATUS_TURNING_OFF) {
            HW_LCDIF_NEXT_BUF_WR(data->planes[0]->phys_start);
            data->pxp_status = PXP_STATUS_OFF;
        }

        // If the PXP is enabled, queue the PXP.
        else if(data->pxp_status == PXP_STATUS_ON) {
            data->pxp_status = PXP_STATUS_READY;
        }

        // If the PXP is queued, it means it's ready to fire.  Attempt to
        // acquire the lock.  If we can, great, fire the PXP.  Otherwise,
        // leave the PXP queued.
        else if(data->pxp_status == PXP_STATUS_READY) {
            if(mutex_trylock(&data->pxp_mutex)) {
                pxp_start_jiffies = jiffies;
                HW_PXP_CTRL_SET(BM_PXP_CTRL_ENABLE);
                data->pxp_status = PXP_STATUS_ON;
            }
            else
                data->pxp_missed_count++;
        }

		else if(data->pxp_status == PXP_STATUS_OFF)
			;

		else
			CHLOG("Unknown pxp_status: %d\n", data->pxp_status);
    }

    times_fired++;
    if((jiffies_to_msecs(jiffies) - last_time) > 1000) {
        lcdif_irq_frequency = times_fired;
        times_fired = 1;
        last_time = jiffies_to_msecs(jiffies);
    }

    return IRQ_HANDLED;
}


static irqreturn_t pxp_irq_handler(int irq, void *dev_id) {
    struct chumbyfw_fb_data *data = dev_id;
    unsigned long flags;
    static int times_fired = 0;
    static int last_time   = 0;

    spin_lock_irqsave(&data->pxp_lock, flags);

    pxp_stop_jiffies = jiffies;


    // Keep track of how many times this IRQ has fired.
    times_fired++;
    if((jiffies_to_msecs(jiffies) - last_time) > 1000) {
        pxp_irq_frequency = times_fired;
        times_fired = 1;
        last_time = jiffies_to_msecs(jiffies);
    }


    // Clear the interrupt so that we can eventually run the PXP again.
    HW_PXP_STAT_CLR(BM_PXP_STAT_IRQ);


    mutex_unlock(&data->pxp_mutex);
    spin_unlock_irqrestore(&data->pxp_lock, flags);


    return IRQ_HANDLED;
}






///////////////////////////////////
//// proc entrypoints

#if(NUM_SCREENS>=4)
static int chumbyfwfb_proc_read_fb3_alpha(char *buf, char **start, off_t offset,
                                 int count, int *eof, void *data)
{
    int len;
    len = sprintf(buf, "0x%x\n", ((HW_PXP_OLnPARAM_RD(2) >> 8) & 0xff));
    *eof = 1;

    return len;
}

static int chumbyfwfb_proc_write_fb3_alpha(struct file *file, const char *buf,
                                  unsigned long count, void *data)
{
    unsigned long alpha = (simple_strtoul(buf, NULL, 0)<<8)&0x0000FF00;
    HW_PXP_OLnPARAM_CLR(2, 0x0000FF00);
    HW_PXP_OLnPARAM_SET(2, alpha);
    if(alpha)
        HW_PXP_OLnPARAM_SET(2, 1);
    else
        HW_PXP_OLnPARAM_CLR(2, 1);
    
    return count;
}
#endif



#if(NUM_SCREENS>=3)
static int chumbyfwfb_proc_read_fb2_alpha(char *buf, char **start, off_t offset,
                                 int count, int *eof, void *data)
{
    int len;
    len = sprintf(buf, "0x%x\n", ((HW_PXP_OLnPARAM_RD(1) >> 8) & 0xff));
    *eof = 1;

    return len;
}

static int chumbyfwfb_proc_write_fb2_alpha(struct file *file, const char *buf,
                                  unsigned long count, void *data)
{
    unsigned long alpha;

    alpha = (simple_strtoul(buf, NULL, 0)<<8)&0x0000FF00;

    HW_PXP_OLnPARAM_CLR(1, 0x0000FF00);
    HW_PXP_OLnPARAM_SET(1, alpha);
    if(alpha)
        HW_PXP_OLnPARAM_SET(1, BM_PXP_OLnPARAM_ENABLE);
    else
        HW_PXP_OLnPARAM_CLR(1, BM_PXP_OLnPARAM_ENABLE);
    
    return count;
}
#endif




static int chumbyfwfb_proc_read_alpha(char *buf, char **start, off_t offset,
                                 int count, int *eof, void *data)
{
    int len;
    len = sprintf(buf, "0x%x\n", ((HW_PXP_OLnPARAM_RD(0) >> 8) & 0xff));
    *eof = 1;

    return len;
}

static int chumbyfwfb_proc_write_alpha(struct file *file, const char *buf,
                                  unsigned long count, void *data)
{
    unsigned long alpha;

    alpha = (simple_strtoul(buf, NULL, 0)<<8)&0x0000FF00;

    HW_PXP_OLnPARAM_CLR(0, 0x0000FF00);
    HW_PXP_OLnPARAM_SET(0, alpha);
    if(alpha)
        HW_PXP_OLnPARAM_SET(0, BM_PXP_OLnPARAM_ENABLE);
    else
        HW_PXP_OLnPARAM_CLR(0, BM_PXP_OLnPARAM_ENABLE);
    
    return count;
}



static int chumbyfwfb_proc_read_enable(char *buf, char **start, off_t offset,
                                  int count, int *eof, void *data)
{
    int len;
    int enabled = gdata->pxp_status == PXP_STATUS_ON 
               || gdata->pxp_status == PXP_STATUS_TURNING_ON;
    len = sprintf(buf, "%d\n", enabled);
    *eof = 1;
    return len;
}

static int chumbyfwfb_proc_write_enable(struct file *file, const char *buf,
                                   unsigned long count, void *data)
{
    unsigned long en;

    en = simple_strtoul(buf, NULL, 0);
    if (en) {
        gdata->pxp_status = PXP_STATUS_TURNING_ON;
    }
    else {
        gdata->pxp_status = PXP_STATUS_TURNING_OFF;
    }

    return count;
}

static int chumbyfwfb_proc_read_key(char *buf, char **start, off_t offset,
                               int count, int *eof, void *data)
{
    int len = 0;
    len += sprintf(buf + len, "0x%02x",   ((HW_PXP_OLCOLORKEYLOW_RD() >> 12) & 0x3f));
    len += sprintf(buf + len,   "%02x",   ((HW_PXP_OLCOLORKEYLOW_RD() >> 6) & 0x3f));
    len += sprintf(buf + len,   "%02x\n", ((HW_PXP_OLCOLORKEYLOW_RD() >> 0) & 0x3f));
    *eof = 1;

    return len;
}

static int chumbyfwfb_proc_write_key(struct file *file, const char *buf,
                                unsigned long count, void *data)
{
    unsigned long key = simple_strtoul(buf, NULL, 0);

    HW_PXP_OLCOLORKEYLOW_WR(key);
    HW_PXP_OLCOLORKEYHIGH_WR(key);
    
    return count;
}


static int chumbyfwfb_proc_read_fb_stats(char *buf, char **start,
                            off_t offset, int count, int *eof, void *data)
{
    int len;
    len = sprintf(buf, "PXP frequency:		%d Hz\n"
                       "LCDIF frequency:	%d Hz\n"
                       "VSYNC Edge IRQs:	%d\n"
                       "Cur Frame Done IRQs:	%d\n"
                       "Missed PXP firings:	%d\n"
//                       "PXP started:		%lu\n"
//                       "PXP stopped:		%lu\n"
//                       "PXP duration:		%lu uS / % mS\n"
                       ,
                       pxp_irq_frequency, lcdif_irq_frequency,
                       vsync_edge_irqs, cur_frame_done_irqs,
                       gdata->pxp_missed_count);
//                       jiffies_to_usecs(
//                           time_after(pxp_start_jiffies, pxp_stop_jiffies)),
//                       jiffies_to_msecs(
//                           time_after(pxp_start_jiffies, pxp_stop_jiffies)));
    *eof = 1;
    return len;
}

static int chumbyfwfb_proc_read_key_en(char *buf, char **start, off_t offset,
                                  int count, int *eof, void *data)
{
    int len;

    if (HW_PXP_OLnPARAM_RD(0) & BM_PXP_OLnPARAM_ENABLE_COLORKEY) {
        len = sprintf(buf, "1\n");
    } else {
        len = sprintf(buf, "0\n");
    }
    *eof = 1;

    return len;
}

static int chumbyfwfb_proc_write_key_en(struct file *file, const char *buf,
                                   unsigned long count, void *data) {
    unsigned long en;

    en = simple_strtoul(buf, NULL, 0);

    if (en) {
        HW_PXP_OLnPARAM_SET(0, 0x00000008);//BM_PXP_OLnPARAM_ENABLE_COLORKEY);
    } else {
        HW_PXP_OLnPARAM_CLR(0, 0x00000008);//BM_PXP_OLnPARAM_ENABLE_COLORKEY);
    }
    
    return count;
}



static int chumbyfwfb_proc_read_pxp_lock(char *buf, char **start, off_t offset,
                                  int count, int *eof, void *data) {
    *eof = 1;
    return sprintf(buf, mutex_is_locked(&gdata->pxp_mutex) ? "1" : "0");
}

static int chumbyfwfb_proc_write_pxp_lock(struct file *file, const char *buf,
                                   unsigned long count, void *data) {
    int setting = simple_strtoul(buf, NULL, 0);

    // If the setting is to lock the mutex, try to lock it.
    if(setting) {
        if(mutex_trylock(&gdata->pxp_mutex))
            return count;
        return -EINVAL;
    }

    // Otherwise, unlock the mutex if it's locked.
    else if(mutex_is_locked(&gdata->pxp_mutex)) {
        mutex_unlock(&gdata->pxp_mutex);
        return count;
    }
    else
        return -EINVAL;
}


static void chumbyfwfb_proc_init(void)
{
    struct proc_dir_entry *pde;

    proc_mkdir("driver/chumbyfwfb", 0);


    pde = create_proc_read_entry("driver/chumbyfwfb/enable", 0, NULL, 
                                 chumbyfwfb_proc_read_enable, NULL);
    pde->write_proc = chumbyfwfb_proc_write_enable;


    pde = create_proc_read_entry("driver/chumbyfwfb/alpha", 0, NULL, 
                                 chumbyfwfb_proc_read_alpha, NULL);
    pde->write_proc = chumbyfwfb_proc_write_alpha;


    pde = create_proc_read_entry("driver/chumbyfwfb/key", 0, NULL, 
                                 chumbyfwfb_proc_read_key, NULL);
    pde->write_proc = chumbyfwfb_proc_write_key;


    pde = create_proc_read_entry("driver/chumbyfwfb/key_en", 0, NULL, 
                                 chumbyfwfb_proc_read_key_en, NULL);
    pde->write_proc = chumbyfwfb_proc_write_key_en;

    pde = create_proc_read_entry("driver/chumbyfwfb/fb_stats", 0, NULL,
                                 chumbyfwfb_proc_read_fb_stats, NULL);

#if(NUM_SCREENS>=3)
    pde = create_proc_read_entry("driver/chumbyfwfb/fb2_alpha", 0, NULL,
                                 chumbyfwfb_proc_read_fb2_alpha, NULL);
    pde->write_proc = chumbyfwfb_proc_write_fb2_alpha;
#endif

#if(NUM_SCREENS>=4)
    pde = create_proc_read_entry("driver/chumbyfwfb/fb3_alpha", 0, NULL,
                                 chumbyfwfb_proc_read_fb3_alpha, NULL);
    pde->write_proc = chumbyfwfb_proc_write_fb3_alpha;
#endif


    pde = create_proc_read_entry("driver/chumbyfwfb/pxp_lock", 0, NULL,
                                chumbyfwfb_proc_read_pxp_lock, NULL);
    pde->write_proc = chumbyfwfb_proc_write_pxp_lock;

}



//////////////////////////////////
//// 



/*
static struct fb_var_screeninfo chumbyfwfb_default __devinitdata = {
    .activate       = FB_ACTIVATE_TEST,
    .height         = 320,
    .width          = 240,
    .pixclock       = 154000,
    .left_margin    = 5,
    .right_margin   = 4,
    .upper_margin   = 3,
    .lower_margin   = 3,
    .hsync_len      = 40,
    .vsync_len      = 2,
    .vmode          = FB_VMODE_NONINTERLACED,
};
*/

static struct fb_fix_screeninfo chumbyfwfb_fix __devinitdata = {
    .id             = "chumbyfwfb",
    .type           = FB_TYPE_PACKED_PIXELS,
    .visual         = FB_VISUAL_TRUECOLOR,
    .xpanstep       = 0,
    .ypanstep       = 0,
    .ywrapstep      = 0,
    .type_aux       = 0,
    .accel          = FB_ACCEL_NONE,
};

void chumbyfwfb_get_info(struct fb_var_screeninfo *var,
            struct fb_fix_screeninfo *fix)
{
    // Punt and give the user fb0's information, which sould be identical
    // to fb1's information.
    *var = gdata->planes[0]->fb_info.var;
    *fix = gdata->planes[0]->fb_info.fix;
}

    
static int chumbyfwfb_mmap(struct fb_info *info, struct vm_area_struct *vma)
{
    struct chumbyfw_fb_plane *plane = (struct chumbyfw_fb_plane *)info;

    unsigned long off = vma->vm_pgoff << PAGE_SHIFT;

    if (off < info->fix.smem_len)
        return dma_mmap_writecombine(NULL/*data->dev*/, vma,
                plane->virt_start,
                plane->phys_start,
                info->fix.smem_len/2);
    else
        return -EINVAL;
}

static int chumbyfwfb_setcolreg(u_int regno, u_int red, u_int green, u_int blue,
             u_int transp, struct fb_info *info)
{
    if (regno >= 256)   /* no. of hw registers */
        return 1;
    /*
    * Program hardware... do anything you want with transp
    */

    /* grayscale works only partially under directcolor */
    if (info->var.grayscale) {
        /* grayscale = 0.30*R + 0.59*G + 0.11*B */
        red = green = blue =
            (red * 77 + green * 151 + blue * 28) >> 8;
    }

    /* Directcolor:
     *   var->{color}.offset contains start of bitfield
     *   var->{color}.length contains length of bitfield
     *   {hardwarespecific} contains width of RAMDAC
     *   cmap[X] is programmed to
     *  (X << red.offset) | (X << green.offset) | (X << blue.offset)
     *   RAMDAC[X] is programmed to (red, green, blue)
     *
     * Pseudocolor:
     *    uses offset = 0 && length = RAMDAC register width.
     *    var->{color}.offset is 0
     *    var->{color}.length contains widht of DAC
     *    cmap is not used
     *    RAMDAC[X] is programmed to (red, green, blue)
     * Truecolor:
     *    does not use DAC. Usually 3 are present.
     *    var->{color}.offset contains start of bitfield
     *    var->{color}.length contains length of bitfield
     *    cmap is programmed to
     *  (red << red.offset) | (green << green.offset) |
     *  (blue << blue.offset) | (transp << transp.offset)
     *    RAMDAC does not exist
     */
#define CNVT_TOHW(val, width) ((((val)<<(width))+0x7FFF-(val))>>16)
    switch (info->fix.visual) {
    case FB_VISUAL_TRUECOLOR:
    case FB_VISUAL_PSEUDOCOLOR:
        red = CNVT_TOHW(red, info->var.red.length);
        green = CNVT_TOHW(green, info->var.green.length);
        blue = CNVT_TOHW(blue, info->var.blue.length);
        transp = CNVT_TOHW(transp, info->var.transp.length);
        break;
    case FB_VISUAL_DIRECTCOLOR:
        red = CNVT_TOHW(red, 8);    /* expect 8 bit DAC */
        green = CNVT_TOHW(green, 8);
        blue = CNVT_TOHW(blue, 8);
        /* hey, there is bug in transp handling... */
        transp = CNVT_TOHW(transp, 8);
        break;
    }
#undef CNVT_TOHW
    /* Truecolor has hardware independent palette */
    if (info->fix.visual == FB_VISUAL_TRUECOLOR) {

        if (regno >= MAX_PALETTES)
            return 1;

        ((u32 *) (info->pseudo_palette))[regno] =
                (red << info->var.red.offset) |
                (green << info->var.green.offset) |
                (blue << info->var.blue.offset) |
                (transp << info->var.transp.offset);
    }
    return 0;
}

static inline u_long get_line_length(int xres_virtual, int bpp)
{
    u_long length;

    length = xres_virtual * bpp;
    length = (length + 31) & ~31;
    length >>= 3;
    return length;
}

static int get_matching_pentry(struct stmp3xxx_platform_fb_entry *pentry,
                   void *data, int ret_prev)
{
    struct fb_var_screeninfo *info = data;
    pr_debug("%s: %d:%d:%d vs %d:%d:%d\n", __func__,
        pentry->x_res, pentry->y_res, pentry->bpp,
        info->xres, info->yres, info->bits_per_pixel);
    if (pentry->x_res == info->xres && pentry->y_res == info->yres &&
        pentry->bpp == info->bits_per_pixel)
        ret_prev = (int)pentry;
    return ret_prev;
}

static int get_matching_pentry_by_name(
        struct stmp3xxx_platform_fb_entry *pentry,
        void *data,
        int ret_prev)
{
    unsigned char *name = data;
    if (!strcmp(pentry->name, name))
        ret_prev = (int)pentry;
    return ret_prev;
}

/*
 * This routine actually sets the video mode. It's in here where we
 * the hardware state info->par and fix which can be affected by the
 * change in par. For this driver it doesn't do much.
 *
 * XXX: REVISIT
 */
//int add_preferred_console(char *name, int idx, char *options);
static int chumbyfwfb_set_par(struct fb_info *info) {
    struct chumbyfw_fb_plane *plane = (struct chumbyfw_fb_plane *)info;
    struct chumbyfw_fb_data *data;
    struct stmp3xxx_platform_fb_data *pdata;
    struct stmp3xxx_platform_fb_entry *pentry;

    if(!info) {
        CHLOG("info is NULL\n");
        return -EINVAL;
    }

    if(!plane) {
        CHLOG("plane is NULL\n");
        return -EINVAL;
    }


    data = plane->fb_data;
    if(!data) {
        CHLOG("data is NULL\n");
        return -EINVAL;
    }


    pdata = data->pdata;
    if(!pdata) {
        CHLOG("pdata is NULL!\n");
        return -EINVAL;
    }


    // Figure out which LCD panel matches the parameters we were passed.
    pentry = (void *)stmp3xxx_lcd_iterate_pdata(pdata,
                        get_matching_pentry,
                        &info->var);
    if (!pentry) {
        CHLOG("pentry is NULL\n");
        return -EINVAL;
    }


    // Recalculate the line length, as it may have changed.
    info->fix.line_length = get_line_length(info->var.xres_virtual,
                        info->var.bits_per_pixel);


    // If we're not switching devices, then we don't need to reinitialize
    // the device panel.
    if (pentry == pdata->cur || !pdata->cur)
        return 0;
    CHLOG("Detected that you're switching output devices.\n");


    // release prev panel.
    chumbyfwfb_blank(FB_BLANK_POWERDOWN, (struct fb_info *)&data->planes[0]);
    if (pdata->cur->stop_panel)
        pdata->cur->stop_panel();
    pdata->cur->release_panel(data->dev, pdata->cur);

    info->fix.smem_len = pentry->y_res * pentry->x_res * pentry->bpp / 8;
    info->screen_size = info->fix.smem_len;
    memset((void *)info->screen_base, 0, info->screen_size);

    // init next panel.
    pdata->cur = pentry;
    stmp3xxx_init_lcdif();
    pentry->init_panel(data->dev, data->phys_start, info->fix.smem_len, pentry);
    pentry->run_panel();
    chumbyfwfb_blank(FB_BLANK_UNBLANK, (struct fb_info *)&data->planes[0]);

	pxp_setup(data);

    return 0;
}

static int chumbyfwfb_check_var(struct fb_var_screeninfo *var,
                struct fb_info *info)
{
    u32 line_length;
    struct chumbyfw_fb_plane *plane         = (struct chumbyfw_fb_plane *)info;
    struct chumbyfw_fb_data *data           = plane->fb_data;
    struct stmp3xxx_platform_fb_data *pdata = data->pdata;

    /*
     *  FB_VMODE_CONUPDATE and FB_VMODE_SMOOTH_XPAN are equal!
     *  as FB_VMODE_SMOOTH_XPAN is only used internally
     */

    if (var->vmode & FB_VMODE_CONUPDATE) {
        var->vmode |= FB_VMODE_YWRAP;
        var->xoffset = info->var.xoffset;
        var->yoffset = info->var.yoffset;
    }

    pr_debug("%s: xres %d, yres %d, bpp %d\n", __func__,
        var->xres,  var->yres, var->bits_per_pixel);
    /*
     *  Some very basic checks
     */
    if (!var->xres)
        var->xres = 1;
    if (!var->yres)
        var->yres = 1;
    if (var->xres > var->xres_virtual)
        var->xres_virtual = var->xres;
    if (var->yres > var->yres_virtual)
        var->yres_virtual = var->yres;

    if (var->xres_virtual < var->xoffset + var->xres)
        var->xres_virtual = var->xoffset + var->xres;
    if (var->yres_virtual < var->yoffset + var->yres)
        var->yres_virtual = var->yoffset + var->yres;

    line_length = get_line_length(var->xres_virtual, var->bits_per_pixel);
    if (line_length * var->yres_virtual > data->map_size) {
        CHLOG("Not enough memory to switch to %dx%d@%d\n",
				var->xres_virtual, var->yres_virtual, var->bits_per_pixel);
        return -ENOMEM;
    }

    if (!stmp3xxx_lcd_iterate_pdata(pdata, get_matching_pentry, var)) {
        CHLOG("Couldn't find a screen that matched %dx%d@%d\n",
				var->xres_virtual, var->yres_virtual, var->bits_per_pixel);
        return -EINVAL;
    }


    if (var->bits_per_pixel == 16) {
        /* RGBA 5551 */
        if (var->transp.length) {
            var->red.offset = 0;
            var->red.length = 5;
            var->green.offset = 5;
            var->green.length = 5;
            var->blue.offset = 10;
            var->blue.length = 5;
            var->transp.offset = 15;
            var->transp.length = 1;
        } else {    /* RGB 565 */
            var->red.offset = 0;
            var->red.length = 5;
            var->green.offset = 5;
            var->green.length = 6;
            var->blue.offset = 11;
            var->blue.length = 5;
            var->transp.offset = 0;
            var->transp.length = 0;
        }
    } else {
        var->red.offset = 16;
        var->red.length = 8;
        var->green.offset = 8;
        var->green.length = 8;
        var->blue.offset = 0;
        var->blue.length = 8;
    }

    var->red.msb_right = 0;
    var->green.msb_right = 0;
    var->blue.msb_right = 0;
    var->transp.msb_right = 0;

    return 0;
}


static int chumbyfwfb_wait_for_vsync(u32 channel, struct fb_info *info)
{
    struct chumbyfw_fb_data *data = gdata;
    u32 count = data->vsync_count;
    int ret = 0;

    ret = wait_event_interruptible_timeout(data->vsync_wait_q,
            count != data->vsync_count, HZ / 10);
    if (!ret) {
        dev_err(data->dev, "wait for vsync timed out\n");
        ret = -ETIMEDOUT;
    }
    return ret;
}

static int chumbyfwfb_ioctl(struct fb_info *info, unsigned int cmd,
            unsigned long arg)
{
    u32 channel = 0;
    int ret = -EINVAL;

    switch (cmd) {
    case FBIO_WAITFORVSYNC:
        if (!get_user(channel, (__u32 __user *) arg))
            ret = chumbyfwfb_wait_for_vsync(channel, info);
        break;
    default:
        break;
    }
    return ret;
}

static int chumbyfwfb_blank(int blank, struct fb_info *info)
{
#if 0
    struct chumbyfw_fb_data *data = (struct chumbyfw_fb_data *)info;
    int ret;

    if(!data)
        panic("fb_info was NULL");
    if(!data->pdata)
        panic("pdata was NULL");
    if(!data->pdata->cur)
        panic("pdata->cur was NULL");
    
    ret = data->pdata->cur->blank_panel ?
        data->pdata->cur->blank_panel(blank) :
        -ENOTSUPP;
    if (ret == 0)
        data->is_blank = (blank != FB_BLANK_UNBLANK);
    return ret;
#endif
    return 0;
}

static int chumbyfwfb_pan_display(struct fb_var_screeninfo *var,
                struct fb_info *info)
{
    struct chumbyfw_fb_plane *plane = (struct chumbyfw_fb_plane *)info;
    int ret = 0;

    /*
    CHLOG("var->xoffset %d, info->var.xoffset %d  "
          "var->yoffset %d, info->var.yoffset %d  "
          "var->yres_virtual %d\n",
        var->xoffset, info->var.xoffset, var->yoffset, info->var.yoffset,
        var->yres_virtual);
    */
    // check if var is valid; also, xpan is not supported
    if (!var || (var->xoffset != info->var.xoffset) ||
        (var->yoffset + var->yres > var->yres_virtual)) {
        ret = -EINVAL;
        CHLOG("Invalid panning offset\n");
        goto out;
    }


    // Update the framebuffer offset.
    switch(plane->idx) {
        case 0:
            CHLOG("Updating framebuffer offset.  yoffset: %d  New offset: 0x%p\n",
                    var->yoffset,
                    (void *)(plane->phys_start+(info->fix.line_length
                                     * var->yoffset)));
            HW_PXP_S0BUF_WR(plane->phys_start+(info->fix.line_length
                                             * var->yoffset));
            break;
        default:
            HW_PXP_OLn_WR(plane->idx-1,
                          plane->phys_start+(info->fix.line_length
                                           * var->yoffset));
            break;
    }

out:
    return ret;
}

static struct fb_ops chumbyfwfb_ops = {
    .owner              = THIS_MODULE,
    .fb_check_var       = chumbyfwfb_check_var,
    .fb_set_par         = chumbyfwfb_set_par,
    .fb_mmap            = chumbyfwfb_mmap,
    .fb_setcolreg       = chumbyfwfb_setcolreg,
    .fb_ioctl           = chumbyfwfb_ioctl,
    .fb_blank           = chumbyfwfb_blank,
    .fb_pan_display     = chumbyfwfb_pan_display,
    .fb_fillrect        = cfb_fillrect,
    .fb_copyarea        = cfb_copyarea,
    .fb_imageblit       = cfb_imageblit,
};

static void init_timings(struct chumbyfw_fb_data *data)
{
    unsigned phase_time;
    unsigned timings;

    // Just use a phase_time of 1. As optimal as it gets, now.
    phase_time = 1;

    // Program all 4 timings the same.
    timings = phase_time;
    timings |= timings << 8;
    timings |= timings << 16;
    HW_LCDIF_TIMING_WR(timings);
}

#ifdef CONFIG_CPU_FREQ

struct chumbyfwfb_notifier_block {
    struct chumbyfw_fb_data *fb_data;
    struct notifier_block nb;
};

static int chumbyfwfb_notifier(struct notifier_block *self,
                unsigned long phase, void *p)
{
    struct chumbyfwfb_notifier_block *block =
        container_of(self, struct chumbyfwfb_notifier_block, nb);
    struct chumbyfw_fb_data *data = block->fb_data;

    switch (phase) {
    case CPUFREQ_POSTCHANGE:
        chumbyfwfb_blank(FB_BLANK_UNBLANK, (struct fb_info *)&data->planes[0]);
        break;

    case CPUFREQ_PRECHANGE:
        chumbyfwfb_blank(FB_BLANK_POWERDOWN, (struct fb_info *)&data->planes[0]);
        break;

    default:
        dev_dbg(data->dev, "didn't handle notify %ld\n", phase);
    }
    //CHLOG("Ignoring notifier call\n");

    return NOTIFY_DONE;
}

static struct chumbyfwfb_notifier_block chumbyfwfb_nb = {
    .nb = {
        .notifier_call = chumbyfwfb_notifier,
    },
};
#endif /* CONFIG_CPU_FREQ */


static int get_max_memsize(struct stmp3xxx_platform_fb_entry *pentry,
               void *data, int ret_prev)
{
    struct chumbyfw_fb_data *fbdata = data;
    int sz = (pentry->x_res * pentry->y_res * pentry->bpp / 8);
    fbdata->mem_size = sz < ret_prev ? ret_prev : sz;
    pr_debug("%s: mem_size now %d\n", __func__, fbdata->mem_size);
    CHLOG("%s: mem_size now %d (%d x %d x %d)\n", __func__, fbdata->mem_size, pentry->x_res, pentry->y_res, pentry->bpp);
    return fbdata->mem_size;
}


static int pxp_setup(struct chumbyfw_fb_data *data) {
    int screen_width, screen_height, screen_bpp;
    int screen_bpp_value, plane_bpp_value;
    int do_scale = 0;
    struct stmp3xxx_platform_fb_data *pdata;
    int screen;
    
    if(!data) {
        CHLOG("data is NULL!  Try again later.\n");
        return 0;
    }

    pdata = data->pdata;

    if(!pdata) {
        CHLOG("pdata is NULL!  Try again later.\n");
        return 0;
    }

    screen_width  = pdata->cur->x_res;
    screen_height = pdata->cur->y_res;
    screen_bpp    = pdata->cur->bpp;


    // Start it running.  Set the correct format, enable the interrupt,
    // and start it.
    if(16==screen_bpp) {
        screen_bpp_value = 4;
		plane_bpp_value = 4;
	}
    else if(32==screen_bpp) {
        screen_bpp_value = 0;
		plane_bpp_value = 4;
	}
    else {
        CHLOG("Unrecognized bpp value: %d\n", screen_bpp);
        screen_bpp_value = 4;
		plane_bpp_value = 4;
    }

    
    // Set up the parameters for width and height.
    // The first two octets are panning offsets, which are 0.
    // The last two octets are the width and height, divided by 8.
    HW_PXP_S0PARAM_WR( ((screen_width/8)<<8) | ((screen_height/8)<<0) );


    // Disable cropping, scaling, and offset rendering.
    HW_PXP_S0CROP_WR(0x00000000);
    HW_PXP_S0SCALE_WR(0x00000000);
    HW_PXP_S0OFFSET_WR(0x00000000);


    // Set the default background to Magic Pink.  Users shouldn't see this,
    // so if they do they'll complain about it and we'll fix it.
    HW_PXP_S0BACKGROUND_WR(0x00FF00FF);


    // Point the Source0 buffer at our fb0.
    CHLOG("Pointing S0 at %p\n", (void *)(data->planes[0]->phys_start));
    HW_PXP_S0BUF_WR(data->planes[0]->phys_start);


    // Point Overlay n at our fbn+1.
    for(screen=1; screen<NUM_SCREENS; screen++)
        HW_PXP_OLn_WR(screen-1, data->planes[screen]->phys_start);


    // Set up the size of Overlay 0 to 320/8 x 240/8 (since the overlay
    // works in macroblocks of 8x8 pixels, we need to divide everything by 8).
    for(screen=1; screen<NUM_SCREENS; screen++)
        HW_PXP_OLnSIZE_WR(screen-1, (((screen_width)/8)<<8) 
                                  | (((screen_height)/8)<<0) );


    // Set the overlay format of RGB565, with a status of "enabled".
    // Bits 15-8 are the alpha lebel, which we set to 0.
    for(screen=1; screen<NUM_SCREENS; screen++)
        HW_PXP_OLnPARAM_WR(screen-1, 0x0000002 | (plane_bpp_value<<4));


    // Point the PXP's output buffer at the screen's offset.
    HW_PXP_RGBBUF_WR(data->phys_start);

    // Set the PXP's output size to the screen's size.
    HW_PXP_RGBSIZE_WR( (screen_width<<12) | (screen_height<<0) );


    data->pxp_status = PXP_STATUS_ON;

    // XXX This pre-defines the plane bpp value to 16-bit.
    HW_PXP_CTRL_WR(0x00000003
			| (screen_bpp_value<<4) | (plane_bpp_value<<12) | (do_scale<<18));


    // We key the PXP to run during the vsync periods.  Enable the IRQ that
    // will fire the PXP.
    HW_LCDIF_CTRL1_SET(BM_LCDIF_CTRL1_CUR_FRAME_DONE_IRQ_EN);

    return 0;
}



static int __devinit chumbyfwfb_probe(struct platform_device *pdev) {
    struct chumbyfw_fb_data *data;
    struct resource *res;
    static struct fb_info *fb_info[NUM_SCREENS];
    int plane_n;
    int current_memory_plane;
    int ret = 0;

    struct stmp3xxx_platform_fb_data *pdata = pdev->dev.platform_data;
    struct stmp3xxx_platform_fb_entry *pentry = NULL;

    //CHLOG("entered function\n");
    if (pdata == NULL) {
        ret = -ENODEV;
        goto out;
    }


    // Locate the panel, which is stored in the pentry field.  This
    // contains all sorts of information about the panel, including bit
    // depth and resolution.
    if (default_panel_name) {
        pentry = (void *)stmp3xxx_lcd_iterate_pdata(pdata,
                    get_matching_pentry_by_name,
                    default_panel_name);
        if (pentry) {
            stmp3xxx_lcd_move_pentry_up(pentry, pdata);
            pdata->cur = pentry;
        }
    }

    // If we couldn't find a matching panel entry, or no panel name was
    // supplied, grab the default, built-in one.
    if (!default_panel_name || !pentry)
        pentry = pdata->cur;

    // Make sure we have a panel, and that it's a valid panel complete with
    // initalization structures.
    if (!pentry || !pentry->init_panel || !pentry->run_panel ||
        !pentry->release_panel) {
        ret = -EINVAL; goto out;
    }


    // We allocate enough memory for the container object, then allocate a
    // framebuffer for each of the overlays.
    data = kmalloc(sizeof(struct chumbyfw_fb_data), GFP_KERNEL);
    if( !data ) {
        ret = -ENOMEM; goto out;
    }


    // Go through each memory plane and allocate a plane for it.
    for(current_memory_plane=0;
        current_memory_plane<NUM_SCREENS;
        current_memory_plane++) {
        data->planes[current_memory_plane] 
            = (struct chumbyfw_fb_plane *) framebuffer_alloc(
                            sizeof(struct chumbyfw_fb_plane), &pdev->dev);
        if(NULL==data->planes[current_memory_plane]) {
            ret = -ENOMEM; goto out;
        }
        data->planes[current_memory_plane]->idx = current_memory_plane;
    }



    gdata       = data;
    data->dev   = &pdev->dev;
    data->pdata = pdata;
    platform_set_drvdata(pdev, data);
    for(plane_n=0; plane_n<NUM_SCREENS; plane_n++)
        fb_info[plane_n] = &data->planes[plane_n]->fb_info;



    CHLOG("resolution %dx%d, bpp %d\n", pentry->x_res,pentry->y_res,pentry->bpp/8);

    // Go through all available resolutions for this panel and figure out
    // the greatest amount of memory that can be used for any given mode.
    // This value will get stored in the pdata struct.
    stmp3xxx_lcd_iterate_pdata(pdata, get_max_memsize, data);

    // We allocate memory for all the screens here, plus one.  That way,
    // the /n/ screens can have their own virtual buffers, which go to a
    // zeroth buffer for compositing.
    // We allocate each plane individually to prevent us from requesting
    // too large of a contiguous chunk of RAM.
    data->map_size = PAGE_ALIGN(data->mem_size);
    CHLOG("memory to allocate for screen: %d\n", data->map_size);
    data->virt_start = dma_alloc_writecombine(&pdev->dev,
                    data->map_size,
                    &data->phys_start,
                    GFP_KERNEL);

    if (data->virt_start == NULL) {
        ret = -ENOMEM; goto out_dma;
    }
    CHLOG("allocated screen at %p:0x%x\n", data->virt_start, data->phys_start);



    // XXX We copy the default video modes from the screen now, because we
    // don't have a way of scaling a default_mode virtual screen up to full
    // screen.
    default_mode.width          = pentry->x_res;
    default_mode.height         = pentry->y_res;
    default_mode.xres           = pentry->x_res;
    default_mode.yres           = pentry->y_res;
    default_mode.xres_virtual   = pentry->x_res;
    default_mode.yres_virtual   = pentry->y_res*2;
    default_mode.yoffset        = 1;



    // Now, allocate each subsequent framebuffer screen, beginning at 1.
    //for(current_memory_plane=1;
    for(current_memory_plane=0;
        current_memory_plane<NUM_SCREENS;
        current_memory_plane++) {

        struct chumbyfw_fb_plane *plane = data->planes[current_memory_plane];
        struct fb_var_screeninfo params = default_mode;


        plane->width    = params.width;
        plane->height   = params.height;
        plane->bpp      = params.bits_per_pixel;
        plane->fb_data  = data;


        // Allocate memory for the current screen.
        //plane->mem_size = plane->width * plane->height * (plane->bpp/8) * 2;
        plane->mem_size = 720 * 576 * 2;
        plane->map_size = PAGE_ALIGN(plane->mem_size);
        CHLOG("memory to allocate for plane %d: %d\n", 
              current_memory_plane, plane->map_size);
        plane->virt_start = dma_alloc_writecombine(&pdev->dev,
                        plane->map_size,
                        &plane->phys_start,
                        GFP_KERNEL);

        if(plane->virt_start == NULL) {
            CHLOG("Failed to allocate memory\n");
            ret = -ENOMEM; goto out_dma;
        }
        CHLOG("allocated at %p:0x%x\n", plane->virt_start, plane->phys_start);
    }


// CHUMBY_logo
    // Pre-copy the logo to both the screen (where the PXP will point to)
    // as well as pxp buffer 0.
    printk("Going to copy splash image from %p (%d bytes) to %p (not %p)\n",
            (void *)chumby_boot_logo_2, chumby_boot_logo_2_size,
            data->virt_start, (void *)data->phys_start);

    if(strstr(boot_command_line, "partition=recovery")) {
        memcpy(data->planes[0]->virt_start, chumby_boot_logo_recovery,
               chumby_boot_logo_recovery_size);
        memcpy(data->virt_start, chumby_boot_logo_recovery,
               chumby_boot_logo_recovery_size);
    }
    else {
        memcpy(data->planes[0]->virt_start, chumby_boot_logo_2,
               chumby_boot_logo_2_size);
        memcpy(data->virt_start, chumby_boot_logo_2,
               chumby_boot_logo_2_size);
    }
// ! CHUMBY_logo


    chumbyfwfb_fix.smem_start = data->phys_start;
    chumbyfwfb_fix.smem_len   = 2 * pentry->y_res * pentry->x_res * pentry->bpp / 8;
    chumbyfwfb_fix.ypanstep   = 1;


    for(plane_n=0; plane_n<NUM_SCREENS; plane_n++) {
        fb_info[plane_n]->screen_base       = data->planes[plane_n]->virt_start;
        fb_info[plane_n]->fbops             = &chumbyfwfb_ops;
        fb_info[plane_n]->var               = default_mode;
        fb_info[plane_n]->fix               = chumbyfwfb_fix;
        fb_info[plane_n]->pseudo_palette    = kmalloc(sizeof (u32) * MAX_PALETTES, GFP_KERNEL);
        fb_info[plane_n]->flags             = FBINFO_FLAG_DEFAULT;
        fb_info[plane_n]->node              = plane_n;
    }



    // Set up a spinlock for the PXP IRQ handler.
    spin_lock_init(&data->pxp_lock);
    mutex_init(&data->pxp_mutex);


    init_waitqueue_head(&data->vsync_wait_q);
    data->vsync_count      = 0;
    data->pxp_missed_count = 0;




    // Allocate necessary IRQs.  There are three:
    //  One for the DMA engine, and
    //  One for any errors that might crop up in the LCDIF, and
    //  One for when the PXP completes its run.
    res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
    if (res == NULL) {
        dev_err(&pdev->dev, "cannot get DMA IRQ resource\n");
        ret = -ENODEV; goto out_dma;
    }
    data->dma_irq = res->start;

    res = platform_get_resource(pdev, IORESOURCE_IRQ, 1);
    if (res == NULL) {
        dev_err(&pdev->dev, "cannot get ERR IRQ resource\n");
        ret = -ENODEV; goto out_dma;
    }
    data->err_irq = res->start;

    res = platform_get_resource(pdev, IORESOURCE_IRQ, 2);
    if (res == NULL) {
        dev_err(&pdev->dev, "cannot get PXP IRQ resource\n");
        ret = -ENODEV; goto out_dma;
    }
    data->pxp_irq = res->start;



    // Allocate a colormap for all framebuffers.
    for(plane_n=0; plane_n<NUM_SCREENS; plane_n++) {
        if((ret = fb_alloc_cmap(&fb_info[plane_n]->cmap, 256, 0)))
            goto out_cmap;
    }



    // Install the IRQ handlers.
    ret = request_irq(data->dma_irq, lcd_irq_handler, 0, "fb_dma", data);
    if (ret) {
        dev_err(&pdev->dev, "request_irq (%d) failed with error %d\n",
                data->dma_irq, ret);
        goto out_panel;
    }
    ret = request_irq(data->err_irq, lcd_irq_handler, 0, "fb_error", data);
    if (ret) {
        dev_err(&pdev->dev, "request_irq (%d) failed with error %d\n",
                data->err_irq, ret);
        goto out_irq;
    }
    ret = request_irq(data->pxp_irq, pxp_irq_handler, 0, "fb_pxp", data);
    if (ret) {
        dev_err(&pdev->dev, "request_irq (%d) failed with error %d\n",
                data->pxp_irq, ret);
        goto out_pxp;
    }


    // Tell the system about the framebuffers we've allocated.
    for(plane_n=0; plane_n<NUM_SCREENS; plane_n++) {
        if((ret = register_framebuffer(fb_info[plane_n])))
            goto out_register;
    }



    // Init the LCD.
    //CHLOG("Calling init_lcdif()...\n");
    stmp3xxx_init_lcdif();


    //CHLOG("Calling pentry->init_panel()...\n");
    ret = pentry->init_panel(data->dev, data->phys_start,
                chumbyfwfb_fix.smem_len, pentry);
    if (ret) {
        dev_err(&pdev->dev, "cannot initialize LCD panel\n");
        goto out_panel;
    }
    dev_dbg(&pdev->dev, "LCD panel initialized\n");

    //CHLOG("Calling init_timings()...\n");
    init_timings(data);

    //CHLOG("Calling pentry->run_panel()...\n");
    pentry->run_panel();
    //CHLOG("LCD DMA channel has been started\n");
    dev_dbg(&pdev->dev, "LCD DMA channel has been started\n");
    data->cur_phys = data->phys_start;
    dev_dbg(&pdev->dev, "LCD running now\n");




#ifdef CONFIG_CPU_FREQ
    chumbyfwfb_nb.fb_data = data;
    cpufreq_register_notifier(&chumbyfwfb_nb.nb, CPUFREQ_TRANSITION_NOTIFIER);
#endif /* CONFIG_CPU_FREQ */




    // Set up our /proc entries.
    chumbyfwfb_proc_init();


    // Init the PXP, which will set up the framebuffer compositing.
    HW_PXP_CTRL_WR(0);  // Pull PxP out of reset.
    //CHLOG("Setting up pxp...\n");
    pxp_setup(data);



    goto out;

out_register:
    free_irq(data->err_irq, data);
out_pxp:
    free_irq(data->err_irq, data);
out_irq:
    free_irq(data->dma_irq, data);
out_panel:
    for(plane_n=0; plane_n<NUM_SCREENS; plane_n++) 
        fb_dealloc_cmap(&fb_info[plane_n]->cmap);

    /*
    fb_dealloc_cmap(&fb0_info->cmap);
    fb_dealloc_cmap(&fb1_info->cmap);
    */
out_cmap:
    dma_free_writecombine(&pdev->dev, data->map_size, data->virt_start,
            data->phys_start);
out_dma:
    kfree(data);
out:
    return ret;
}

static int chumbyfwfb_remove(struct platform_device *pdev)
{
	int fb_num;
    struct chumbyfw_fb_data *data = platform_get_drvdata(pdev);
    struct stmp3xxx_platform_fb_data *pdata = pdev->dev.platform_data;
    struct stmp3xxx_platform_fb_entry *pentry = pdata->cur;

	for(fb_num=0; fb_num<NUM_SCREENS; fb_num++)
		chumbyfwfb_blank(FB_BLANK_POWERDOWN, &data->planes[fb_num]->fb_info);

    if (pentry->stop_panel)
        pentry->stop_panel();
    pentry->release_panel(&pdev->dev, pentry);

	for(fb_num=0; fb_num<NUM_SCREENS; fb_num++) {
		unregister_framebuffer(&data->planes[fb_num]->fb_info);
		framebuffer_release(&data->planes[fb_num]->fb_info);
		fb_dealloc_cmap(&data->planes[fb_num]->fb_info.cmap);
        kfree(data->planes[fb_num]->fb_info.pseudo_palette);
	}

    free_irq(data->dma_irq, data);
    free_irq(data->err_irq, data);
    dma_free_writecombine(&pdev->dev, data->map_size, data->virt_start,
            data->phys_start);
    kfree(data);
    platform_set_drvdata(pdev, NULL);
    return 0;
}

#ifdef CONFIG_PM
static int chumbyfwfb_suspend(struct platform_device *pdev, pm_message_t state)
{
    struct chumbyfw_fb_data *data = platform_get_drvdata(pdev);
    struct stmp3xxx_platform_fb_data *pdata = pdev->dev.platform_data;
    struct stmp3xxx_platform_fb_entry *pentry = pdata->cur;
    int ret;

    CHLOG("Warning: Suspending framebuffer device\n");
    ret = chumbyfwfb_blank(FB_BLANK_POWERDOWN, &data->planes[0]->fb_info);
    ret = chumbyfwfb_blank(FB_BLANK_POWERDOWN, &data->planes[1]->fb_info);
    if (ret)
        goto out;
    if (pentry->stop_panel)
        pentry->stop_panel();
    pentry->release_panel(data->dev, pentry);

out:
    return ret;
}

static int chumbyfwfb_resume(struct platform_device *pdev)
{
    struct chumbyfw_fb_data *data = platform_get_drvdata(pdev);
    struct stmp3xxx_platform_fb_data *pdata = pdev->dev.platform_data;
    struct stmp3xxx_platform_fb_entry *pentry = pdata->cur;

    stmp3xxx_init_lcdif();
    init_timings(data);
    pentry->init_panel(data->dev, data->phys_start, 
                       data->planes[0]->fb_info.fix.smem_len, pentry);
    pentry->run_panel();
    chumbyfwfb_blank(FB_BLANK_UNBLANK, &data->planes[0]->fb_info);
    chumbyfwfb_blank(FB_BLANK_UNBLANK, &data->planes[1]->fb_info);
    CHLOG("Warning: Resuming framebuffer device\n");
    return 0;
}
#else
#define chumbyfwfb_suspend  NULL
#define chumbyfwfb_resume   NULL
#endif

static struct platform_driver chumbyfwfb_driver = {
    .probe      = chumbyfwfb_probe,
    .remove     = chumbyfwfb_remove,
    .suspend    = chumbyfwfb_suspend,
    .resume     = chumbyfwfb_resume,
    .driver     = {
        .name   = "stmp3xxx-fb",
        .owner  = THIS_MODULE,
    },
};

static int __init chumbyfwfb_init(void)
{
    return platform_driver_register(&chumbyfwfb_driver);
}

static void __exit chumbyfwfb_exit(void)
{
    platform_driver_unregister(&chumbyfwfb_driver);
}

#ifdef MODULE
module_init(chumbyfwfb_init);
#else
subsys_initcall(chumbyfwfb_init);
#endif
module_exit(chumbyfwfb_exit);

/*
 * LCD panel select
 */
static int __init default_panel_select(char *str)
{
    default_panel_name = str;
    return 0;
}


MODULE_AUTHOR("Sean Cross <scross@chumby.com>");
MODULE_DESCRIPTION("Chumby Falconwing Framebuffer Driver");
MODULE_LICENSE("GPL");
__setup("lcd_panel=", default_panel_select);

