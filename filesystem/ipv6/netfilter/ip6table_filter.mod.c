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
	{ 0xfbf92453, "param_get_bool" },
	{ 0xa925899a, "param_set_bool" },
	{ 0x85673ea3, "nf_register_hooks" },
	{ 0xb7eb0ba, "register_pernet_subsys" },
	{ 0xea147363, "printk" },
	{ 0x2bd6fc61, "init_net" },
	{ 0xd93cfa1b, "ip6t_do_table" },
	{ 0xc06a21e4, "ip6t_register_table" },
	{ 0xf83b689d, "ip6t_unregister_table" },
	{ 0x1c8b13e8, "unregister_pernet_subsys" },
	{ 0x577fd6af, "nf_unregister_hooks" },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=ip6_tables";

