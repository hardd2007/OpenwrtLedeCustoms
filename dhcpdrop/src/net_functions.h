/*
 * net_functions.h
 *
 *  Created on: 30.07.2009
 *      Author: Chebotarev Roman
 */

#ifndef NET_FUNCTIONS_H_
#define NET_FUNCTIONS_H_

#include "net.h"

enum packet_types
{
	dhcp_packet,
	arp_packet
};

/* Return pcap network device if success. Otherwise - exit from programm. */
pcap_t * get_device(const struct config_params * params);

/* Calculate CRC for data in 'buffer'. Return checksumm. */
uint16_t rs_crc(const unsigned short *buffer, int length);

/* Create ARP header */
void assemble_net_header_arp(struct arp_packet_net_header * net_header,
		const uint8_t * ether_src,
		uint16_t op_code);

/* Create network header - ethernet + IP + UDP. Store in 'header'. */
void assemble_net_header_dhcp
    (
        struct dhcp_packet_net_header * header,		/* Can't be NULL */
		const int data_len,						/* Length of UDP data */
        const struct config_params * params,	/* Can't be NULL */
        const uint8_t * ether_src,				/* Source ethernet address. Binary format. Can't be NULL */
        const uint32_t	dst_ip,					/* If zero - using broadcast. */
        const uint32_t	src_ip
        );

/* Send packet to network. 'data_len' - only UDP data, exclude network headers */
int send_packet(pcap_t* descr, 			/* Can't be NULL */
		enum packet_types packet_type,	/* Type of sended packet. Se 'enum packet_types' in dhcdrop_types.h */
		const uint8_t *snd_data, 		/* UDP payload. Can't be NULL */
		const int data_len,				/* Payload data length */
		const struct config_params * params,	/* May be NULL */
		const uint8_t * ether_src,  	/* Source ethernet address. Can't be NULL */
		const uint32_t dst_ip);

#ifdef  _WIN32
void CALLBACK timeout(UINT uTimerID, UINT uMsg, DWORD_PTR dwUser, DWORD_PTR dw1, DWORD_PTR dw2);
#else
void timeout(int signal);
#endif

#endif /* NET_FUNCTIONS_H_ */
