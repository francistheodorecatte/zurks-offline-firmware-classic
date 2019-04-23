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
	{ 0x14290afe, "register_pernet_gen_device" },
	{ 0x8d4e51c7, "xfrm6_tunnel_register" },
	{ 0xf51d1869, "ip_route_input" },
	{ 0xadb3660, "ip_route_output_key" },
	{ 0xf2a6d2bf, "xfrm_policy_count" },
	{ 0xf2650be6, "netif_rx" },
	{ 0xf274c0d, "__secpath_destroy" },
	{ 0xcf86b153, "__xfrm_policy_check" },
	{ 0x651d43b4, "skb_pull" },
	{ 0xbb714e86, "skb_clone" },
	{ 0x3d64a406, "icmpv6_send" },
	{ 0xca78f10e, "icmp_send" },
	{ 0xbc458eb0, "ipv6_chk_addr" },
	{ 0xeb4a7935, "dev_get_by_index" },
	{ 0x8e0b7743, "ipv6_ext_hdr" },
	{ 0x1909f0c8, "__pskb_pull_tail" },
	{ 0xe54f8f39, "sock_wfree" },
	{ 0x22afe4e6, "ip6_local_out" },
	{ 0xd83791bc, "nf_conntrack_destroy" },
	{ 0x472c31cf, "skb_push" },
	{ 0x6544ccbd, "ipv6_push_nfrag_opts" },
	{ 0x9811db5c, "kfree_skb" },
	{ 0xafbb58f8, "skb_realloc_headroom" },
	{ 0xf6ebc03b, "net_ratelimit" },
	{ 0xa4a3b2f, "xfrm_lookup" },
	{ 0xd0bfe422, "ip6_route_output" },
	{ 0xfa2a45e, "__memzero" },
	{ 0x67c2fa54, "__copy_to_user" },
	{ 0x59331e72, "netdev_state_change" },
	{ 0x7dceceac, "capable" },
	{ 0xfbc74f64, "__copy_from_user" },
	{ 0x90263c46, "register_netdevice" },
	{ 0x8a15cded, "dev_alloc_name" },
	{ 0x349cba85, "strchr" },
	{ 0x3c2c5af5, "sprintf" },
	{ 0x73e20c1c, "strlcpy" },
	{ 0xb78734f2, "rt6_lookup" },
	{ 0xd542439, "__ipv6_addr_type" },
	{ 0x6800b1fc, "dst_release" },
	{ 0x799aca4, "local_bh_enable" },
	{ 0x3ff62317, "local_bh_disable" },
	{ 0x2bd6fc61, "init_net" },
	{ 0xe914e41e, "strcpy" },
	{ 0xd379b8e0, "kmalloc_caches" },
	{ 0x210a617f, "register_netdev" },
	{ 0xc5c117db, "alloc_netdev_mq" },
	{ 0x70bdb3d4, "net_assign_generic" },
	{ 0x25dbe321, "kmem_cache_alloc" },
	{ 0x37a0cba, "kfree" },
	{ 0x6e720ff2, "rtnl_unlock" },
	{ 0xfba9eb9d, "unregister_netdevice" },
	{ 0xc7a4fbed, "rtnl_lock" },
	{ 0x43b0c9c3, "preempt_schedule" },
	{ 0x90db18cd, "unregister_pernet_gen_device" },
	{ 0xea147363, "printk" },
	{ 0xf4745c7f, "xfrm6_tunnel_deregister" },
	{ 0xaf93f81c, "free_netdev" },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=tunnel6,ipv6";

