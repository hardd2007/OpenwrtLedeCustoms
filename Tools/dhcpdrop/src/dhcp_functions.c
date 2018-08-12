/*
 * dhcdrop_functions.c
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
#include "net.h"
#include "dhcdrop_types.h"
#include "dhcp_functions.h"

const uint8_t magic_cookie[] = {99, 130, 83, 99};

uint16_t make_dhcp_req	/* Return length of field DHCP-options */
    (
        struct  dhcp_packet * dhcp_data,	/* Pointer to structure of DHCP packet. Can't be NULL*/
        const uint8_t message_type,			/* DHCPDISCOVER, DHCPREQUEST... */
        const uint8_t * ether_src_addr,		/* Ethernet address of pseudo client. Can't be NULL */
        const uint32_t server_address,	/* NULL for DHCPDISCOVER */
        const uint32_t cl_ip_addr,		/* NULL for DHCPDISCOVER */
        const int xid,							/* XID for DHCP transaction */
        const struct config_params * config		/* Pointer to structure of programm configuration */
    )
{
	uint8_t *p_dhcp_opt;
    bzero(dhcp_data, sizeof(struct dhcp_packet));
    /* Fill common options */
    dhcp_data->op = BOOTREQUEST;
    dhcp_data->htype = HTYPE_ETHER;
    dhcp_data->hlen = ETH_ALEN;
    dhcp_data->flags = config->broadcast ? htons(BOOTP_BROADCAST) : 0;
    dhcp_data->xid = (xid)? xid : rand();						/* If xid == 0 create new xid */
    memcpy(dhcp_data->chaddr, ether_src_addr, ETH_ALEN);

    /*Fill dhcp-options field*/
    p_dhcp_opt = dhcp_data->options;

    /*Start DHCP options*/
    memcpy(p_dhcp_opt, magic_cookie, sizeof(magic_cookie));
    p_dhcp_opt += sizeof(magic_cookie);

    /*Create DHCP-message type*/
    *p_dhcp_opt++ = DHO_DHCP_MESSAGE_TYPE;
    *p_dhcp_opt++ = 1;

    *p_dhcp_opt++ = message_type;

    if(message_type == DHCPREQUEST)
    {
        *p_dhcp_opt++ = DHO_DHCP_REQUESTED_ADDRESS;
        *p_dhcp_opt++ = sizeof(cl_ip_addr);
        memcpy(p_dhcp_opt, &cl_ip_addr, sizeof(cl_ip_addr));
        p_dhcp_opt += sizeof(cl_ip_addr);
    }
    else if(message_type == DHCPRELEASE)
    	dhcp_data->ciaddr.s_addr = cl_ip_addr;

    if((message_type == DHCPREQUEST) ||
    		(message_type == DHCPRELEASE))
    {
        /*Create parametr "server identifier"*/
        *p_dhcp_opt++ = DHO_DHCP_SERVER_IDENTIFIER;
        *p_dhcp_opt++ = sizeof(server_address);
        memcpy(p_dhcp_opt, &server_address, sizeof(server_address));
        p_dhcp_opt += sizeof(server_address);
    }

    if(message_type != DHCPRELEASE)
    {
		/*Create parametrs request list*/
		*p_dhcp_opt++ = DHO_DHCP_PARAMETER_REQUEST_LIST;
		*p_dhcp_opt++ = 3;
		*p_dhcp_opt++ = DHO_DOMAIN_NAME_SERVERS;
		*p_dhcp_opt++ = DHO_ROUTERS;
		*p_dhcp_opt++ = DHO_SUBNET_MASK;

		/*Create parametr "hostname"*/
		*p_dhcp_opt++ = DHO_HOST_NAME;
		*p_dhcp_opt++ = strlen(config->client_hostname);
		memcpy(p_dhcp_opt, config->client_hostname, strlen(config->client_hostname));
		p_dhcp_opt += strlen(config->client_hostname);

		/*Create parametr "dhcp-client name" (Vendor-Class)*/
		*p_dhcp_opt++ = DHO_VENDOR_CLASS_IDENTIFIER;
		*p_dhcp_opt++ = strlen(config->dhcp_client);
		memcpy(p_dhcp_opt, config->dhcp_client, strlen(config->dhcp_client));
		p_dhcp_opt += strlen(config->dhcp_client);
    }

    /*Create client-ID option*/
    *p_dhcp_opt++ = DHO_DHCP_CLIENT_IDENTIFIER;
    *p_dhcp_opt++ = 1 + ETH_ALEN;			/* Length HW-type + ETHER_ADDR_LEN == 7 */
    *p_dhcp_opt++ = HTYPE_ETHER;
    memcpy(p_dhcp_opt, ether_src_addr, ETH_ALEN);
    p_dhcp_opt += ETH_ALEN;

    /*End options*/
    *p_dhcp_opt++ = DHO_END;

    return  p_dhcp_opt - dhcp_data->options;
}


uint16_t set_dhcp_type(const struct dhcp_packet *request, const uint16_t new_type)
{
    uint8_t *option = (uint8_t *)request + sizeof (struct dhcp_packet) - DHCP_OPTION_LEN;
    const uint8_t * opt_end = (const uint8_t *)request + sizeof(struct dhcp_packet);
    uint8_t old_type;
    if(memcmp(option, magic_cookie, sizeof(magic_cookie)))  /* Exit if magic_cookie not found - */
            return -1;
    option += sizeof(magic_cookie);							 /* Start options field */
    while((option < opt_end) && (*option != 255))
    {
		if(*option == DHO_DHCP_MESSAGE_TYPE)
        {
			old_type = *(option + 2);
            *(option + 2) = new_type;
            return old_type;
        }
        else option += *(option + 1) + 2;
    }
    return 0;
}

int get_dhcp_option(const struct dhcp_packet *request, const uint16_t packet_len,
                        const int req_option, void * option_value, int value_size)
{
    /* Calculate start address for field "options" in DHCP packet */
    uint8_t *option = (uint8_t *)request + sizeof (struct dhcp_packet) - DHCP_OPTION_LEN;
    /* End options equal end packet */
    const uint8_t * opt_end = (const uint8_t *)request + packet_len;
    /* Check "Magic cookie" in first 4 bytes options-field */
    if(memcmp(option, magic_cookie, sizeof(magic_cookie)))
        return -1;
    option += sizeof(magic_cookie);
    int opt_len;

    while((option < opt_end) && (*option != DHO_END))
    {
    	opt_len = *(option + 1);
        if((option + opt_len) > opt_end)
        {
            printf("\nWARNING! Invalid value in DHCP-option length. Attempting DoS?\n");
            return -1;
        }

        if(*option == req_option)
        {
            if(opt_len > value_size)
            {
            	printf("\nWARNING! Option's length is more than was expected (opcode: %d opt_len: %d > expected_len: %d). Attempting DoS?\n",
            			*option, opt_len, value_size);
            	return -1;
            }

            memcpy(option_value, option + 2, opt_len);
            return *(option + 1);
        }
        else option += *(option + 1) + 2;
    }
    return 0;
}

