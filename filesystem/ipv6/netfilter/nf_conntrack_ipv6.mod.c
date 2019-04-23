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
	{ 0xa8f71ae0, "nf_conntrack_in" },
	{ 0xb4448b14, "inet_frag_kill" },
	{ 0x608c2831, "warn_on_slowpath" },
	{ 0x385cf56d, "__nf_ct_refresh_acct" },
	{ 0x30afaf5e, "proc_dointvec" },
	{ 0xff91c2ba, "nf_ct_get_tuplepr" },
	{ 0xbb714e86, "skb_clone" },
	{ 0x64461a52, "seq_printf" },
	{ 0x3e383385, "nf_hooks" },
	{ 0xf35e742b, "nf_conntrack_l3proto_unregister" },
	{ 0x9773a7a1, "nf_hook_slow" },
	{ 0xbc6f16c7, "inet_frag_find" },
	{ 0x5071d8f7, "nf_log_packet" },
	{ 0x1909f0c8, "__pskb_pull_tail" },
	{ 0xd4ecfd36, "__nf_ct_kill_acct" },
	{ 0x85478a0b, "inet6_hash_frag" },
	{ 0x134a5b52, "nf_ct_invert_tuple" },
	{ 0x8e279ff2, "__nf_conntrack_confirm" },
	{ 0xea147363, "printk" },
	{ 0x8e0b7743, "ipv6_ext_hdr" },
	{ 0x3e7c85af, "nf_conntrack_l4proto_unregister" },
	{ 0xe9a434ce, "inet_frags_fini" },
	{ 0x472c31cf, "skb_push" },
	{ 0x43b0c9c3, "preempt_schedule" },
	{ 0x2bd6fc61, "init_net" },
	{ 0x577fd6af, "nf_unregister_hooks" },
	{ 0x3ff62317, "local_bh_disable" },
	{ 0xa767b6b2, "__alloc_skb" },
	{ 0xf2f1dc6c, "inet_frag_evictor" },
	{ 0x6e224a7a, "need_conntrack" },
	{ 0x9811db5c, "kfree_skb" },
	{ 0xe07f73ba, "inet_frag_destroy" },
	{ 0x885142a6, "nf_net_netfilter_sysctl_path" },
	{ 0x799aca4, "local_bh_enable" },
	{ 0x6ec0165b, "nf_conntrack_l4proto_tcp6" },
	{ 0x5b04ec9c, "pskb_expand_head" },
	{ 0xa7d182f0, "ip6_frag_init" },
	{ 0xf6ebc03b, "net_ratelimit" },
	{ 0x41166725, "inet_frags_init_net" },
	{ 0x9d669763, "memcpy" },
	{ 0x2bb63c02, "___pskb_trim" },
	{ 0x85673ea3, "nf_register_hooks" },
	{ 0x9f6d0b80, "nf_conntrack_l3proto_register" },
	{ 0xecc0e7f9, "inet_frags_init" },
	{ 0x99bb8806, "memmove" },
	{ 0xe113bbbc, "csum_partial" },
	{ 0x41d4974e, "nf_conntrack_l4proto_udp6" },
	{ 0xe620b7ca, "nf_conntrack_l4proto_register" },
	{ 0x81d051eb, "proc_dointvec_jiffies" },
	{ 0xa84d090e, "skb_copy_bits" },
	{ 0xbbd8990d, "nf_ip6_checksum" },
	{ 0xd9221c48, "nf_conntrack_find_get" },
	{ 0xa1677ee4, "ip6_frag_match" },
	{ 0x89b941cb, "__nf_ct_l4proto_find" },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=ipv6";

