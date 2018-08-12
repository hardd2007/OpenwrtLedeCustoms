/*
 * dhcdrop_functions.h
 *
 *  Created on: 30.07.2009
 *      Author: root
 */

#ifndef DHCP_FUNCTIONS_H_
#define DHCP_FUNCTIONS_H_

uint16_t make_dhcp_req	/* Return length of field DHCP-options */
    (
		struct  dhcp_packet * dhcp_data,	/* Pointer to structure of DHCP packet. Can't be NULL*/
		const uint8_t message_type,			/* DHCPDISCOVER, DHCPREQUEST... */
		const uint8_t * ether_src_addr,		/* Ethernet address of pseudo client. Can't be NULL */
		const uint32_t server_address,	/* NULL for DHCPDISCOVER */
		const uint32_t cl_ip_addr,		/* NULL for DHCPDISCOVER */
		const int xid,							/* XID for DHCP transaction */
		const struct config_params * config		/* Pointer to structure of programm configuration */
    );
uint16_t set_dhcp_type(const struct dhcp_packet *request, const uint16_t new_type);
int get_dhcp_option(const struct dhcp_packet *request, const uint16_t packet_len,
                        const int req_option, void * option_value, int option_size);
void packet_handler(u_char *out_packet, const struct pcap_pkthdr *h,
                                   const u_char *packet);
int get_packet(pcap_t * descr, u_char * ether_packet, const int wait_seconds);

#endif /* DHCP_FUNCTIONS_H_ */
