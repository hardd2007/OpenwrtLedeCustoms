/*
 * dhcdrop_types.h
 *
 *  Created on: 30.07.2009
 *      Author: Chebotarev Roman
 */

#ifndef DHCDROP_TYPES_H_
#define DHCDROP_TYPES_H_

#include "common_includes.h"

#pragma pack(1)

#define DEF_TTL             64
#define IP_HDR_LEN          5       /* IP header len in 32-bit words */
#define B_IP_HDR_LEN        5 * 4   /* IP header len in bytes */
#define DEF_SERVER_PORT     67
#define DEF_CLIENT_PORT     68
#define MAX_PORT_VALUE      65535

#define DHCP_UDP_OVERHEAD   (20 +   /* IP header */           \
                 8)                 /* UDP header */
#define DHCP_SNAME_LEN      64
#define DHCP_FILE_LEN       128
#define DHCP_FIXED_NON_UDP  236
#define DHCP_FIXED_LEN      (DHCP_FIXED_NON_UDP + DHCP_UDP_OVERHEAD)
                        /* Everything but options. */
#define DHCP_MTU_MAX        1500
#define DHCP_OPTION_LEN     (DHCP_MTU_MAX - DHCP_FIXED_LEN)
#define DHCP_MAX_LEN		1472

#define BOOTP_MIN_LEN       300
#define DHCP_MIN_LEN        548
#define IPV4_ALEN			4	/* 4 bytes */

#define ARP_OP_REQ			htons(1)
#define	ARP_OP_RESP			htons(2)

#define MAX_HOSTS_SCAN		512
#define DEF_TIMEOUT			3
#define MAX_CHILDREN		32
#define	CAP_TIMEOUT			100		/* Waiting 100 microseconds for avoid CPU overload (microsecs) */
#define IPTOSBUFFERS		12
#define MAX_IP4_ALEN		15		/* 12 digits + 3 delimiters */
#define MIN_IP4_ALEN		7		/* 4 digit + 3 delimiters */
#define MAX_STR_MAC_LEN		17		/* 12 hex digits + 5 delimiters */
#define MIN_STR_MAC_LEN		11
#define PCAP_FILTER_LEN		1024

#define MAX_ADDR_COUNT      512
#define MAX_ATTEMPTS        5
#define	WAIT_BEFORE_RERUN	60
#define DEF_HOSTNAME        "DHCP-dropper"
#define DEF_DHCPCLIENT      DEF_HOSTNAME
#define STR_SERVERDISCOVER_FILTER	"(ether dst host %s or ether dst host FF:FF:FF:FF:FF:FF) and udp and src port %d and dst port %d"
#define	STR_DROP_FILTER				" and ether src host %s"
#define STR_SERVERDROP_FILTER		STR_SERVERDISCOVER_FILTER STR_DROP_FILTER


/*Defined errors codes*/
#define ERR_EUID                10
#define ERR_SIGNAL              20
#define ERR_CONFIG              30
#define ERR_MEMORY              40
#define ERR_OPENDEV             50
#define	ERR_LISTING_DEV			51
#define ERR_FILTER_OWERFLOW     60
#define ERR_PCAP_COMPILE        70
#define ERR_PCAP_SETFILTER      80
#define ERR_SENDPACKET          90
#define ERR_GETPACKET           100
#define ERR_SETNOBLOCK          110
#define ERR_INVALID_DEV			120
#define ILLEGAL_SERV_FOUND      200
#define	ERR_ABNORMAL			255

#ifdef  __FreeBSD__
#define PCAP_OPEN_LIVE_TIMEOUT	1
#elif	__DragonFly__
#define PCAP_OPEN_LIVE_TIMEOUT	1
#elif	__NetBSD__
#define PCAP_OPEN_LIVE_TIMEOUT	1
#elif	__OpenBSD__
#define PCAP_OPEN_LIVE_TIMEOUT	1
#elif	__APPLE__
#define PCAP_OPEN_LIVE_TIMEOUT	1
#elif	__linux__
#define	PCAP_OPEN_LIVE_TIMEOUT	-1
#elif	__WIN32
#define	PCAP_OPEN_LIVE_TIMEOUT	1
#define MAX_THREADS_COUNT	MAXIMUM_WAIT_OBJECTS /* MAXIMUM_WAIT_OBJECTS == 64 (winbase.h) */
#else
#error "Unsupported system! Supported is: Linux, FreeBSD, OpenBSD, NetBSD & Windows (MinGW)."
#endif

enum list_operations
{
	get_count,
	add,
	rem,
	get_top,
	search,
	by_index,
	flush
};

struct ignored_mac_node
{
    char mac_addr[MAX_STR_MAC_LEN + 1];
    struct ignored_mac_node * next;
};

struct config_params
{
    char    	test_mode;
    char    	yes;
    char    	rand_mac_always;
    int     	max_attempts;
    char    	* if_name;
    int     	max_address_count;
    char    	client_hostname[64];
    char    	dhcp_client[16];
    uint8_t		source_mac[6];
    char    	str_source_mac[MAX_STR_MAC_LEN + 1];		/* Hex-string MAC address */
    char    	flood;
    int     	children_count;
    char    	broadcast;
    int     	client_port;
    int     	server_port;
    char    	always_wait_from_67;
    char    	always_wait_to_68;
	int			timeout;
	int			discover;
	int			max_hosts_scan;
	int			wait_before_restart;
	uint32_t	scanned_network;
	uint32_t	scan_netmask;
	uint32_t	from_ip;
	uint32_t	send_dhcprelease;
	uint32_t	server_ip;
	int			quiet_mode;
};

typedef struct flood_params
{
	const struct config_params * config;
#ifdef _WIN32
	HANDLE * flood_threads;
	DWORD  * threads_ids;
#endif
} *flood_params_ptr;

#endif /* DHCDROP_TYPES_H_ */
