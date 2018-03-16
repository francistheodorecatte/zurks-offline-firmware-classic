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
	{ 0x9ea48b86, "xfrm6_prepare_output" },
	{ 0xf3ba5dfa, "xfrm_prepare_input" },
	{ 0x334f62d2, "xfrm_register_mode" },
	{ 0x99bb8806, "memmove" },
	{ 0x5b04ec9c, "pskb_expand_head" },
	{ 0x1909f0c8, "__pskb_pull_tail" },
	{ 0x9d669763, "memcpy" },
	{ 0xdb451f1a, "xfrm_unregister_mode" },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=ipv6";

