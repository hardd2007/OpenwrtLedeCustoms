/*
 * net.h
 *
 *  Created on: 05.08.2009
 *      Author: Chebotarev Roman
 */

#ifndef NET_H_
#define NET_H_

#pragma pack(1)

#define ETH_ALEN	6		/* Octets in one ethernet addr	 */

#define	ETHERTYPE_IP		0x0800		/* IP */
#define	ETHERTYPE_ARP		0x0806		/* Address resolution */

/* 10Mb/s ethernet header */
struct eth_header
{
  u_int8_t  ether_dhost[ETH_ALEN];	/* destination eth addr	*/
  u_int8_t  ether_shost[ETH_ALEN];	/* source ether addr	*/
  u_int16_t ether_type;		        /* packet type ID field	*/
} __attribute__ ((__packed__));

/*
 * Structure of an internet header, naked of options.
 */
struct iphdr
{
#if __BYTE_ORDER == __LITTLE_ENDIAN
    unsigned int ihl:4;
    unsigned int version:4;
#elif __BYTE_ORDER == __BIG_ENDIAN
    unsigned int version:4;
    unsigned int ihl:4;
#else
# error "Please fix <bits/endian.h>"
#endif
    uint8_t tos;
    uint16_t tot_len;
    uint16_t id;
    uint16_t frag_off;
    uint8_t ttl;
    uint8_t protocol;
    uint16_t check;
    uint32_t saddr;
    uint32_t daddr;
    /*The options start here. */
};

/* ARP header */
struct arp_header
{
    uint16_t	arp_hwtype;   /* Format of hardware address */
    uint16_t	arp_proto;   /* Format of protocol address */
    uint8_t		arp_hwlen;     /* Length of hardware address */
    uint8_t 	arp_palen;     /* Length of protocol address */
    uint16_t	arp_oper;      /* ARP opcode (command) */
};

/* UDP header as specified by RFC 768, August 1980. */

struct pseudo_header
{
    unsigned int src_addr;
    unsigned int dst_addr;
    unsigned char zero ;
    unsigned char proto;
    unsigned short length;
};

struct udphdr
{
	uint16_t source;
	uint16_t dest;
	uint16_t len;
	uint16_t check;
};

struct arp_packet_net_header
{
	struct eth_header eth_head;
	struct arp_header arp_head;
};

struct arp_data
{
	uint8_t		from_ether[ETH_ALEN];
	uint32_t 	from_ip;
	uint8_t		to_ether[ETH_ALEN];
	uint32_t	to_ip;
};

struct dhcp_packet_net_header
{
    struct eth_header eth_head;
    struct iphdr ip_header;
    struct udphdr udp_header;
};

#endif /* NET_H_ */
