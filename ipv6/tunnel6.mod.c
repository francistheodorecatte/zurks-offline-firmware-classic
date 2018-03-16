#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

MODULE_INFO(vermagic, VERMAGIC_STRING);

struct module __this_module
__attribute__((section(".gnu.linkonce.this_module"))) = {
 .name = KBUILD_MODNAME,
 .init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
 .exit = cleanup_module,
#endif
 .arch = MODULE_ARCH_INIT,
};

static const struct modversion_info ____versions[]
__used
__attribute__((section("__versions"))) = {
	{ 0xbb69ac7a, "struct_module" },
	{ 0x609f1c7e, "synchronize_net" },
	{ 0x3d64a406, "icmpv6_send" },
	{ 0xdbd244a7, "inet6_add_protocol" },
	{ 0x323222ba, "mutex_unlock" },
	{ 0x1909f0c8, "__pskb_pull_tail" },
	{ 0xea147363, "printk" },
	{ 0xb97d4c9c, "mutex_lock" },
	{ 0x9811db5c, "kfree_skb" },
	{ 0xdceceb12, "inet6_del_protocol" },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=ipv6";

