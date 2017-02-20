/*
 *	Copyright (C) 2009 by Chebotarev Roman <roma@ultranet.ru>
 *
 *	This program is free software; you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation; either version 2 of the License.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program; if not, write to the Free Software
 *	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef DHCDROP_H
#define DHCDROP_H

#define RELEASE_DATE        "05.08.2009"
#define PROG_NAME			"DHCP-dropper"
#define BASE_VERSION        PROG_NAME" v0.5"
#define VERSION             BASE_VERSION

#define COPYRIGHT           VERSION" was written by Chebotarev Roman at "RELEASE_DATE"\n"
#define	HOMEPAGE			"Home page: http://www.netpatch.ru/en/dhcdrop.html"


/* Function for filling configuration structure 'params' from command line arguments */
void configure(const int argc, char **argv, struct config_params * params);

/* Execute all programm actions */
int exec_action(const struct config_params * config);

/* Discover available network interfaces.
 * If 'num' not zero - return name of interface with index 'num' if success, 0 otherwise. */
char * interfaces_discover(const int num);

/* Creating and launch children for generate DHCP flood. */
void send_flood(const struct config_params * params);

/* Get ethernet address of illegal DHCP server in network.
 * Retrun: 0 if server not found, ILLEGAL_SERV_FOUND if illegal server found. Error code otherwise. */
int get_dhcp_server(const struct config_params * config,	/* Configuration parametrs. Can't be NULL */
		pcap_t * pcap_socket,						/* Pointer to pcap device. Can't be NULL */
		struct dhcp_packet_net_header * net_header,	/* Can't be NULL */
		struct dhcp_packet * server_response,		/* Function store DHCP response server here, */
													/* can't be NULL */
		uint16_t * response_length);

/* Drop DHCP server specified in 'srv_etheraddr'. Return number of address recieved. */
int drop_dhcp_server(const struct config_params * config,	/* Can't be NULL */
		pcap_t * pcap_socket,			/* Pointer to pcap device. Can't be NULL */
		const char * srv_etheraddr);	/* Ethrenet addres of DHCP server to dropping */

/* Scanning network for search hosts with invalid  IP configuration and send
 * DHCPRELEASE for each found hosts to illegal DHCP server. Return zero if success, -1 otherwise */
int agressive_clean_leases(pcap_t * pcap_socket,	/* Pointer to pcap device. Can't be NULL */
		const struct config_params * config,		/* Can't be NULL */
		struct dhcp_packet_net_header * net_header, /* Network header from DHCP server response */
		const struct dhcp_packet * srv_resp, 		/* Pointer to structure contain server DHCPOFFER response */
		uint16_t resp_len);							/* Length DHCPOFFER */

/* ARP scan network on interface 'pcap_socket' in range specified by network/netmask. */
void scan_subnet(pcap_t * pcap_socket, 	/* Pointer to pcap device. Can't be NULL */
		uint32_t from_ip, 				/* Source IP address. If == 0 - using random value */
		const uint8_t * from_eth,		/* Source ethernet address. */
		const uint32_t network, 		/* Destination network */
		const uint32_t netmask);		/* Network mask */

/* ARP scan network on interface 'pcap_socket' in IP range 'start_range' - 'end_range'
 * Return zero if success, error code otherwise. */
int arp_scan(pcap_t * pcap_socket,		/* Pointer to pcap device. Can't be NULL */
		const uint32_t start_range,		/* Start IP range. Host byte order! */
		const uint32_t end_range,		/* End IP range. Host byte order! */
		uint32_t from_ip, 				/* Source IP address */
		const uint8_t * from_ether);	/* Source ethernet address */

/* Return 0 if success, or error code otherwise. */
int send_arpreq(pcap_t * pcap_socket, 	/* Pointer to pcap device. Can't be NULL */
		const uint32_t to_ip,			/* Destination of ARP request */
		const uint32_t from_ip, 		/* Source IP address */
		const uint8_t * from_ether);	/* Source ethernet address */

/* Waiting ARP responses on interface 'pcap_socket' */
int get_arpresps(pcap_t * pcap_socket,	/* Pointer to pcap device. Can't be NULL */
		int timeout);					/* Timeout in seconds */

#ifdef  _WIN32
/* Keyboard interrupt handler */
BOOL WINAPI int_sign(DWORD signal);

/* Generate DHCP flood - one thread. Windows version. */
unsigned __stdcall start_flood( void* arg );

#else
/* Keyboard interrupt handler */
int int_sign(int32_t signal);
/* Generate DHCP flood - one child. UNIX-like version. */
int start_flood( void* arg );
#endif

/* Create new child process (for UNIX) or new thread (for Windows) for generate DHCP flood. */
void new_child(const struct flood_params * p, const int child_num);

/* Wait unless all child DHCP flood processes (in UNIX)/ threads (in Windows) finished. */
void wait_children(const struct flood_params * p);

/* Make filter expression for pcap_setfilter() function for discover
 * DHCP servers in network. Return 0 if success, or error code otherwise. */
int make_serverdiscover_filter(char * out_filter, const int max_filter_len,
		const struct config_params * config, const char * src_etheraddr);

/* Make filter expression for pcap_setfilter() function for ARP scanning
 * network. Return 0 if success, or error code otherwise. */
int make_arp_filter(char * out_filter, const int max_filter_len, const char * src_etheraddr);

/* Make filter expression for pcap_setfilter() function to drop
 * DHCP servers specified in 'server_ethaddr'. Using client Ethernet address
 * specified in 'src_etheraddr'. Return 0 if success, or error code otherwise. */
int make_serverdrop_filter(char * out_filter, const int max_filter_len,
		const struct config_params * config,
		const char * src_etheraddr, const char * server_ethaddr);

/* Set filter specified in 'filter_expression' to interface 'pcap_socket'.
 * Return 0 if success, or error code otherwise. */
int set_pcap_filter(pcap_t * pcap_socket, char * filter_expression);

/* Create and send DHCPDISCOVER from pseudo-client 'ether_src'.
 * Return 0 if success, or error code otherwise. */
int send_dhcp_discover(pcap_t * pcap_socket,	/* Can't be NULL */
		const struct config_params * config,	/* Can't be NULL */
		uint8_t * ether_src,					/* May be NULL */
		const uint32_t xid);

/* Create and send DHCPDISCOVER from pseudo-client 'ether_src' to DHCP server.
 * Return 0 if success, or error code otherwise. */
int send_dhcp_request(pcap_t * pcap_socket, const struct config_params * config,
	uint8_t * src_ether,	/* Pseudo-client source ethernet address. Can't be NULL */
    const uint32_t server_ip_address,	/* DHCP server IP address. Can't be NULL */
    const uint32_t req_ip_addr,			/* Required client IP address. Can't be NULL */
    const int32_t xid);							/* DHCP transcaction XID */

int send_dhcp_release(pcap_t * pcap_socket, const struct config_params * config,
	const uint8_t * src_ether,	/* Pseudo-client source ethernet address. Can't be NULL */
    const uint32_t server_ip_address,	/* DHCP server IP address. Can't be NULL */
    const uint32_t cl_ip_addr,			/* Released client IP address. Can't be NULL */
    const int32_t xid
);

/* Waiting DHCP response of type specified in 'resp_type' from server.
 * Return: -1 if timeout; 0 if DHCP server responded or error code otherwise. */
int get_dhcp_response(pcap_t * pcap_socket,			/* Can't be NULL */
		const int timeout, const uint8_t resp_type,	/* Timeout in seconds */
		const uint32_t xid, 						/* DHCP transcaction XID */
		struct dhcp_packet_net_header * net_header,		/* Function store network header (Ethernet, IP, UDP)
														here. Can't be NULL */
		struct dhcp_packet * response,				/* Function store DHCP response here. Can't be NULL */
		int * dhcp_data_len);						/* Function store DHCP data length here. Can't be NULL*/

/* Function that implements a list of legal DHCP server list. */
struct ignored_mac_node * ignor_servers_list(
		enum list_operations operation,	/* Operation type. See enum 'list_operations'
											in dhcdrop_types.h */
		char * ether_addr);					/* Ethernet address of DHCP server */

/* Function that implements a list of legal IP networks on interface */
uint32_t legal_nets_list(enum list_operations operation, /* Operation type. See enum 'list_operations'
															in dhcdrop_types.h */
		const uint32_t * value);						/* Network IP address */
/* Function that implements a list of hosts */
int	hosts_list(enum list_operations operation,  /* Operation type. See enum 'list_operations'
															in dhcdrop_types.h */
		uint32_t ip_addr,						/* Host IP address */
		uint8_t * ether_addr);					/* Host ethernet address */

/* Executed on programm finished. */
void cleanup(void);

/* Misc functions */

/* Decode and print DHCP message. Return DHCP message type is success, 0 otherwise. */
int decode_dhcp(const struct dhcp_packet * packet, const uint16_t dhcp_data_len);

/* Print usage message. Print help message if 'help' != 0 */
void usage(const char help);

/* Convert network mask to CIDR notation */
uint32_t to_cidr(uint32_t mask);

/* Convert a numeric IP address to a string */
char *iptos(const uint32_t in);

/* Print information about network interface */
void ifprint(const pcap_if_t *dev);

/* Convert ethernet address specified in 'str_addr' to binary format and store to 'bin_addr'.
 * Return >0 if success. */
int etheraddr_str_to_bin(const char * str_addr, uint8_t * bin_addr);

/* Convert ethernet address specified in 'bin_addr' to string format and store to 'str_addr'.
 * Return >0 if success. */
inline int etheraddr_bin_to_str(const uint8_t * bin_addr, char * str_addr);

/* Replase all '-' symbols in string 'str_ether' to ':' */
inline void replace_semicolons(char * str_ether);

/* Print ethernet address as hex-digits string */
inline void print_ether(const uint8_t * ether_addr);

/* Create random ethernet address and store to string 'str_mac_addr' */
inline void rand_ether_addr(char * str_mac_addr);

#endif	/* ifdef DHCDROP_H*/
