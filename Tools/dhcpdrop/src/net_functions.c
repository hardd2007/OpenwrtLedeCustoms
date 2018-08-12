/*
 * net_functios.c
 *
 *  Created on: 30.07.2009
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

#include "common_includes.h"
#include "dhcp.h"
#include "dhcdrop_types.h"
#include "net_functions.h"

int is_timeout;

uint16_t rs_crc(const unsigned short *buffer, int length)
{
    uint32_t crc = 0;
    /* Calculate CRC */
    while (length > 1)
    {
        crc += *buffer++;
        length -= sizeof (unsigned short);
    }
    if (length)
        crc += *(unsigned char*) buffer;

    crc = (crc >> 16) + (crc & 0xFFFF);
    crc += (crc >> 16);

    return (uint16_t)(~crc);
}

void assemble_net_header_arp(struct arp_packet_net_header * net_header,
		const uint8_t * ether_src,
		uint16_t op_code)
{
    /* Fill ethernet header */
	memcpy(net_header->eth_head.ether_shost, ether_src, sizeof(net_header->eth_head.ether_shost));
	memset(net_header->eth_head.ether_dhost, 0xFF, sizeof(net_header->eth_head.ether_dhost));
    net_header->eth_head.ether_type = htons(ETHERTYPE_ARP);
    /* Fill ARP header */
    net_header->arp_head.arp_hwtype = htons(1);				/* Ethernet */
	net_header->arp_head.arp_proto = htons(ETHERTYPE_IP);
	net_header->arp_head.arp_hwlen = ETH_ALEN;
	net_header->arp_head.arp_palen = IPV4_ALEN;
	net_header->arp_head.arp_oper = op_code;
}

void assemble_net_header_dhcp
    (
        struct dhcp_packet_net_header * header,
		const int data_len,
        const struct config_params * params,
        const uint8_t * ether_src,
        const uint32_t	dst_ip,
        const uint32_t	src_ip
    )
{
    /* Fill ethernet header */
	memcpy(header->eth_head.ether_shost, ether_src, sizeof(header->eth_head.ether_shost));
	memset(header->eth_head.ether_dhost, 0xFF, sizeof(header->eth_head.ether_dhost));
    header->eth_head.ether_type = htons(ETHERTYPE_IP);
    /* Fill IP header */
    bzero(&header->ip_header, sizeof(struct iphdr));
    header->ip_header.ihl = IP_HDR_LEN;
    header->ip_header.version = 4;
    header->ip_header.tos = 0x10;
    header->ip_header.tot_len = htons(B_IP_HDR_LEN + sizeof(struct udphdr) + data_len);
    header->ip_header.id = (uint16_t) rand();
    header->ip_header.frag_off = 0;
    header->ip_header.ttl = DEF_TTL;
    header->ip_header.protocol = IPPROTO_UDP;
    header->ip_header.check = 0;
    header->ip_header.saddr = src_ip;
    if(dst_ip)
    	header->ip_header.daddr = dst_ip;
    else
    	memset(&header->ip_header.daddr, 0xFF, sizeof(uint32_t));    	/*Set dst IP = 255.255.255.255*/

    header->ip_header.check = rs_crc((unsigned short*)&header->ip_header, sizeof(struct iphdr));
    header->udp_header.source = htons(params->client_port);
    header->udp_header.dest = htons(params->server_port);
    header->udp_header.len = htons(sizeof(struct udphdr) + data_len);
    header->udp_header.check = 0;	/* Don't use because CRC for UDP - optional parametr */

    return;
}

int send_packet(pcap_t* descr, enum packet_types packet_type, const uint8_t *snd_data, const int data_len,
		const struct config_params * config,
		const uint8_t * ether_src, const uint32_t dst_ip)
{
	int header_size = 0;
    static unsigned char pack_buf[DHCP_MTU_MAX];

    bzero(pack_buf, sizeof(pack_buf));

    /* Create net-header */
	switch(packet_type)
	{
	case dhcp_packet:
		if(!config)
			return 0;
		assemble_net_header_dhcp((struct dhcp_packet_net_header *)pack_buf,
				data_len, config, ether_src, dst_ip, 0);//((struct dhcp_packet *) snd_data)->ciaddr.s_addr);
		header_size = sizeof(struct dhcp_packet_net_header);
		break;
	case arp_packet:
		assemble_net_header_arp((struct arp_packet_net_header *) pack_buf, ether_src, ARP_OP_REQ);
		header_size = sizeof(struct arp_packet_net_header);
		break;
	default:
		printf("send_packet(): unknown type of packet.\n");
		return 0;
	}

	/* Copy user data to send buffer */
    memcpy(pack_buf + header_size, snd_data, data_len);

    if(pcap_inject(descr, pack_buf, header_size + data_len) == -1)
    {
        pcap_perror(descr, "pcap_inject");
        return 0;
    }

    return 1;
}

void packet_handler(u_char *out_packet, const struct pcap_pkthdr *h,
                                   const u_char *packet)
{
	if(h->len > DHCP_MTU_MAX)
	{
		printf("Received too long packet: %d. Can't dispatch!\n", h->len);
		return;
	}

    memcpy(out_packet, (u_char*)packet, h->len);
    return;
}

int get_packet(pcap_t * descr, u_char * ether_packet, const int wait_seconds)
{
    int ret = 0;
	uint32_t t;

	if(wait_seconds > 0)
	{
		is_timeout = 0;
		t = timer_start(wait_seconds, timeout);
	}
	else
		is_timeout = 1;
	while(1)
    {
		if(wait_seconds)
			usleep(CAP_TIMEOUT);		/* Waiting 100 microseconds for avoid CPU overload */

        ret = pcap_dispatch(descr, 1, packet_handler, (u_char*)ether_packet);
        if(ret < 0)
        {
            perror("pcap_dispatch");
            return -1;
        }

        if(is_timeout || ret)
		{
        	timer_stop(t);
            break;
		}
    }
    return ret;
}


#ifdef	_WIN32
void CALLBACK timeout(UINT uTimerID, UINT uMsg, DWORD_PTR dwUser, DWORD_PTR dw1, DWORD_PTR dw2)
#else
void timeout(int signal)
#endif
{
	is_timeout = 1;
}

/* Opening and testing device */
pcap_t * get_device(const struct config_params * params)
{
    char errbuf[PCAP_ERRBUF_SIZE];
	pcap_t * pcap_socket = pcap_open_live(params->if_name, DHCP_MTU_MAX, 1,
			PCAP_OPEN_LIVE_TIMEOUT, errbuf);

    if(pcap_socket == NULL)
    {
        printf("Opening device error! %s\n",errbuf);
        exit(ERR_OPENDEV);
    }

	if(pcap_datalink(pcap_socket) != DLT_EN10MB)
	{
		printf("Can't work on this link layer type! Exit.\n");
		exit(ERR_INVALID_DEV);
	}

#ifdef __linux__
	/* Set nonblock mode for processing DHCP timeouts */
    if(pcap_setnonblock(pcap_socket, 1, errbuf) == -1)
    {
        printf("pcap_setnoblock error: '%s'\n", errbuf);
        pcap_close(pcap_socket);
        exit(ERR_SETNOBLOCK);
    }
#endif

    return pcap_socket;
}

