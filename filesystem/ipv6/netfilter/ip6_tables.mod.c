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
	{ 0x346f5662, "xt_unregister_target" },
	{ 0x66042bb2, "xt_find_target" },
	{ 0xfbc74f64, "__copy_from_user" },
	{ 0xeb52b00d, "xt_unregister_table" },
	{ 0x40728a63, "xt_find_revision" },
	{ 0x67c2fa54, "__copy_to_user" },
	{ 0x97255bdf, "strlen" },
	{ 0xbad62844, "xt_check_target" },
	{ 0x34824943, "xt_proto_fini" },
	{ 0xbda95d96, "xt_table_unlock" },
	{ 0x999e8297, "vfree" },
	{ 0x1cc4a412, "xt_find_table_lock" },
	{ 0x2ffd9c15, "xt_replace_table" },
	{ 0xe2d5255a, "strcmp" },
	{ 0x5071d8f7, "nf_log_packet" },
	{ 0xa1c32483, "xt_proto_init" },
	{ 0xb0002e26, "xt_register_table" },
	{ 0xfa2a45e, "__memzero" },
	{ 0x5f754e5a, "memset" },
	{ 0x1c8b13e8, "unregister_pernet_subsys" },
	{ 0xea147363, "printk" },
	{ 0x8e0b7743, "ipv6_ext_hdr" },
	{ 0x2bd6fc61, "init_net" },
	{ 0x682917d2, "xt_register_target" },
	{ 0x8c439100, "module_put" },
	{ 0x7dceceac, "capable" },
	{ 0x3ff62317, "local_bh_disable" },
	{ 0x5a4c6420, "nf_unregister_sockopt" },
	{ 0x8990ef5a, "xt_unregister_match" },
	{ 0x799aca4, "local_bh_enable" },
	{ 0xb7eb0ba, "register_pernet_subsys" },
	{ 0xf6ebc03b, "net_ratelimit" },
	{ 0x9d669763, "memcpy" },
	{ 0xb6c719b3, "xt_check_match" },
	{ 0xe762d6e, "request_module" },
	{ 0x119c49da, "nf_register_sockopt" },
	{ 0x3dcd58c5, "xt_alloc_table_info" },
	{ 0xe71d28ed, "xt_find_match" },
	{ 0xa6a6486c, "xt_register_match" },
	{ 0xa84d090e, "skb_copy_bits" },
	{ 0xf7037dc6, "xt_free_table_info" },
	{ 0x23fd3028, "vmalloc_node" },
	{ 0xe914e41e, "strcpy" },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=";

