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

#include "common_includes.h"
#include "net.h"
#include "dhcp.h"
#include "dhcdrop_types.h"
#include "net_functions.h"
#include "dhcp_functions.h"
#include "dhcdrop.h"

const char usage_message[] = "Usage:\n"
"dhcpdrop [-h] [-D] [-t] [-y] [-r] [-b] [-a] [-A] [-f] [-R] [-q]\n"
	"\t[-m <count>] [-c <count>] [-n <hostname>] [-N <clientname>]\n"
	"\t[-p <port>] [-P <port>] [-w <secs>] [-T <timeout>]\n"
	"\t[-M <max-hosts-scan>] [-l <MAC-address>] [-L <network>]\n"
	"\t[-S <network/mask>] [-F <from-IP>] [-s <server-IP>]\n"
	"\t[-C <"CHILDREN_TYPE" count (2 - 32)>] [<initial MAC address>]\n"
	"\t-i <interface-name|interface-index>\n";

const char keys[] = "\t-h - print this help message\n"
	"\t-D - list of available network interfaces.\n"
	"\t  Format - index:name.\n"
	"\t-t - test mode. Send DHCPDISCOVER and wait DHCPOFFER.\n"
	"\t  Exit with code 200 if DHCPOFFER is received.\n"
	"\t  Otherwise - exit with code 0.\n"
	"\t-y - answer 'yes' to all questions.\n"
	"\t-r - disable ethernet address randomize.\n"
	"\t-b - use flag 'broadcast' in DHCP message\n"
	"\t  (default: don't use flag broadcast).\n"
	"\t-a - always wait server('s) response\n"
	"\t  on default DHCP client port (68)\n"
	"\t-A - always wait server('s) response\n"
	"\t  from default DHCP server port (67)\n"
	"\t-f - flood mode. Generate DHCPDISCOVER flood.\n"
	"\t-R - send DHCPRELEASE from source MAC address specified\n"
	"\t  by <initial MAC address> and IP address specified\n"
	"\t  by option -F to server specified by option -s.\n"
	"\t-q - quiet mode.\n"
	"\t-m count - maximum number of attempts\n"
	"\t  to receive answer from DHCP server.\n"
	"\t-c count - maximum number of receiving addresses\n"
	"\t  from DHCP server (default: 255).\n"
	"\t-n hostname - value of DHCP-option 'HostName'\n"
	"\t  (default: 'DHCP-dropper').\n"
	"\t-N clientname - value of DHCP-option 'Vendor-Class'\n"
	"\t  (default: 'DHCP-dropper').\n"
	"\t-p port - set client port value.\n"
	"\t-P port - set server port value.\n"
	"\t-w seconds - set timeout after which the process will be\n"
	"\t  restarted when using agressive mode (see option -L)\n"
	"\t  (default: 60 secs).\n"
	"\t-T timeout - set timeout (of) waiting server response\n"
	"\t  in seconds (default: 3).\n"
	"\t-M max-hosts-scan - maximum number of hosts scanned if\n"
	"\t  agressive mode (is used) (option -L).\n"
	"\t-l MAC-address - ethernet address of DHCP server\n"
	"\t  which need(s) to (be) ignore(d). May be several servers.\n"
	"\t  Need option '-l' for each server.\n"
	"\t-L network - specify legal network(s) on interfase. May be\n"
	"\t  several networks. If this parameter is set, dhcdrop\n"
	"\t  uses agressive mode: it scans address range assigned\n"
	"\t  by DHCP server for searching hosts with incorrect addresses,\n"
	"\t  sends DHCPRELEASE to server from every found host after\n"
	"\t  this it restarts process of receiving addreses.\n"
	"\t-S network/mask - ARP-scan for network 'network' with network\n"
	"\t  mask 'mask' (CIDR notation). Source IP address for scanning\n"
	"\t  specified by option -F. If source IP is not set - using random\n"
	"\t  IP address from network address range.\n"
	"\t-F from-IP - source IP for scanning network or sending\n"
	"\t  DHCPRELEASE (see option -S and -R).\n"
	"\t-s server-IP - specify DHCP server IP address.\n"
	"\t  Used with option -R.\n"
	"\t-C count - "
#ifdef _WIN32
	"child thread"
#else
	"children"
#endif
		" number\n"
		"\t  (default: 0, minimal value: 2, maximum: 32).\n"
		"\t  Compatible only with flag '-f'.\n"
#ifdef _WIN32
	"\t  WARNING: not effectively under OS Windows.\n"
#endif
	"\t-i interface - defines network interface, can be name or\n"
		"\t  index (cannot be 'any'). For listing available\n"
		"\t  interfaces use option -D.\n";

const char ret_codes[] = "Program can exit with codes:\n"
"\t0   - Exit success. Illegal DHCP server not found.\n"
"\t10  - invalid user ID. You must be root for running programm.\n"
"\t20  - failed to set signal handler.\n"
"\t30  - configuration error. See usage.\n"
"\t40  - memory allocation error. Insufficient memory?\n"
"\t50  - error opening ethernet device.\n"
"\t51  - error listing devices.\n"
"\t60  - pcap filter overflow.\n"
"\t70  - pcap compile error.\n"
"\t80  - pcap set filter error.\n"
"\t90  - error sending packet.\n"
"\t100 - error getting packet.\n"
"\t110 - set non blocked mode error.\n"
"\t120 - invalid device.\n"
"\t200 - illegal DHCP server was found.\n";

const char leases_warning[] = "\nWARNING: Failed to take away all the IP addresses assigned by DHCP server.\n"
	"Perhaps DHCP server checks availability of IP addresses by sending ARP-request\n"
	"before assigning them. Try to restart dhcpdrop later. If it doesn't help\n"
	"try to disconnect problem hosts temporarily, then send manually DHCPRELEASE\n"
	"from address of this hosts (use option -R) and restart dhcdrop.\n";

const uint8_t broadcast_ether[] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};

int main (int argc, char **argv)
{
    struct config_params config;            /* Parametrs from command line */

    srand(time(0));
    atexit(cleanup);
	set_timer_handler(timeout);
	set_console_handler(int_sign);

    configure(argc, argv, &config);

    int ret = exec_action(&config);

    if(!config.quiet_mode && !config.test_mode)
    	printf("Finished.\n");

    return ret;
}

int exec_action(const struct config_params * config)
{
    int ret;

#ifndef _WIN32
    if(geteuid())
    {
        printf("Your EUID shoud be 0 (root) to run this program.\n"
        		"Currently your EUID is %u. Aborting.\n", geteuid());
        return ERR_EUID;
    }
#endif

	if(config->discover)
		interfaces_discover(0);

	if(!config->test_mode && !config->quiet_mode)
		printf("Using interface: '%s'\n", config->if_name);

	 if(config->flood)
    {
		printf("Sending DHCPDISCOVER flood. Press Ctrl+C to abort...\n");
		send_flood(config);
		return EXIT_SUCCESS;
    }

    /* Opening network device */
    pcap_t * pcap_socket = get_device(config);

	if(config->scanned_network)
	{
		scan_subnet(pcap_socket, config->from_ip, config->source_mac, config->scanned_network, config->scan_netmask);
		pcap_close(pcap_socket);
		return EXIT_SUCCESS;
	}

	if(config->send_dhcprelease)
	{
		printf("Send DHCPRELEASE from %s ", config->str_source_mac);
		printf("client IP %s ", iptos(config->from_ip));
		printf("to DHCP server %s\n", iptos(config->server_ip));
		ret = send_dhcp_release(pcap_socket, config, config->source_mac,
				config->server_ip, config->from_ip, rand());
		pcap_close(pcap_socket);
		return ret;
	}

    struct dhcp_packet server_response;
    uint16_t response_length;

    /* Searching DHCP server in the network */
    struct dhcp_packet_net_header net_header;
    ret = get_dhcp_server(config, pcap_socket, &net_header,
    		&server_response, &response_length);
    if(!ret)
    {
        pcap_close(pcap_socket);
        return EXIT_SUCCESS;	/* Illegal DHCP server not found */
    }

    if(ret != ILLEGAL_SERV_FOUND)
    	return ret;	/* Error occured */

    if(config->test_mode)	/* If test-mode - exit without dropping */
    {
        pcap_close(pcap_socket);
        return ILLEGAL_SERV_FOUND;
    }

    char str_srv_etheraddr[MAX_STR_MAC_LEN + 1];
    bzero(str_srv_etheraddr, sizeof(str_srv_etheraddr));
    etheraddr_bin_to_str(net_header.eth_head.ether_shost, str_srv_etheraddr);
    /* Drop server with ethernet address in 'str_srv_etheraddr' */
    int dropped = drop_dhcp_server(config, pcap_socket, str_srv_etheraddr);
    if(config->quiet_mode)
    	printf("%d adresses received from DHCP server.\n", dropped);

    if(legal_nets_list(get_count, 0))	/* If set - use agressive mode */
    {
    	if(!agressive_clean_leases(pcap_socket, config, &net_header,
    			&server_response, response_length))
    	{
    		if(hosts_list(get_count, 0, 0) > 1)
    		{
				/* Ask user: "Restart dropping? [y/n]" */
				char yN[2] = "n";	/* Default - don't restart */
				(config->yes)? yN[0] = 'y' : (printf("Restart dropping? [y/n] "), scanf("%s", yN));
				if((yN[0] == 'y') || (yN[0] == 'Y'))
				{
					printf("Restart dropping DHCP server after %d seconds timeout...\n", config->wait_before_restart);
					sleep(config->wait_before_restart);
					dropped = drop_dhcp_server(config, pcap_socket, str_srv_etheraddr);
					if(config->quiet_mode)
						printf("%d adresses received.\n", dropped);
					if((dropped < (hosts_list(get_count, 0, NULL) - 1 + 1)) && /* -1 - itself DHCP server,
																				 + 1 - start address */
							!config->quiet_mode)
						printf("%s\n", leases_warning);
				}
    		}
    	}
    }

    pcap_close(pcap_socket);

    return ILLEGAL_SERV_FOUND;
}

void configure(const int argc, char **argv, struct config_params * params)
{
    bzero(params, sizeof(struct config_params));
    params->rand_mac_always = 1;    		/* Default - randomize source ethernet address */
    params->max_attempts = MAX_ATTEMPTS;    /* If == 0 - exit */
    params->server_port = DEF_SERVER_PORT;
    params->client_port = DEF_CLIENT_PORT;
    params->max_hosts_scan = MAX_HOSTS_SCAN;
    params->wait_before_restart = WAIT_BEFORE_RERUN;

    if(argc < 2)
        usage(0);

    int i;
    int ret;

    for(i = 1; i < argc; ++i)
    {
        /* t y r f b h m i c n N C l p P a A T D L M w S F R s*/
        if(argv[i][0] == '-')
        {
            /*Parsing options without params*/
            if(strlen(argv[i]) > 2)
                usage(0);
            switch(argv[i][1])
            {
            case 't':
                params->test_mode = 1;
                continue;
            case 'y':
                params->yes = 1;
                continue;
            case 'r':
                params->rand_mac_always = 0;
                continue;
            case 'f':
                params->flood = 1;
                continue;
            case 'b':
                params->broadcast = 1;
                continue;
            case 'a':
                params->always_wait_to_68 = 1;
                continue;
            case 'A':
                params->always_wait_from_67 = 1;
                continue;
            case 'R':
            	params->send_dhcprelease = 1;
            	continue;
            case 'q':
            	params->quiet_mode = 1;
            	continue;
			case 'D':
				params->discover = 1;
				return;
            case 'h':
                usage(1);
                break;
            }
            if(i + 1 >= argc)
                            usage(0);
            if(argv[i + 1][0] == '-')
                            usage(0);

            /*Parsing options with params*/
            switch(argv[i][1])
            {
            case 'm':
                params->max_attempts = atoi(argv[i + 1]);
                if(params->max_attempts < 1)
                    usage(0);
                break;
            case 'i':
                params->if_name = argv[i + 1];
				if(atoi(params->if_name) > 0)
				{
					params->if_name = interfaces_discover(atoi(params->if_name));
					if(!params->if_name)
					{
						printf("Can't find device by index: '%s', use option '-D' for interface discover. Exit.\n",
							argv[i + 1]);
						exit(ERR_LISTING_DEV);
					}
				}
                break;
            case 'c':
                params->max_address_count = atoi(argv[i + 1]);
                if(params->max_address_count < 1)
                    usage(0);
                break;
            case 'n':
                if(strlen(argv[i + 1]) > (sizeof(params->client_hostname) - 1))
                {
                    printf("Client hostname too long.\n");
                    usage(0);
                }
                memcpy(params->client_hostname, argv[i + 1], strlen(argv[i + 1]));
                break;
            case 'N':
                if(strlen(argv[i + 1]) > (sizeof(params->dhcp_client) - 1))
                {
                    printf("DHCP client name too long.\n");
                    usage(0);
                }
                memcpy(params->dhcp_client, argv[i + 1], strlen(argv[i + 1]));
                break;
            case 'C':
                params->children_count = atoi(argv[i + 1]);
                if(params->children_count < 2 ||
                		params->children_count > MAX_CHILDREN)
                    usage(0);
                break;
            case 'p':
                params->client_port = atoi(argv[i + 1]);
                if(params->client_port < 1 || params->client_port > MAX_PORT_VALUE)
                {
                    printf("Invalid DHCP client port value: '%s'\n", argv[i + 1]);
                    usage(0);
                }
                break;
            case 'P':
                params->server_port = atoi(argv[i + 1]);
                if(params->server_port < 1 || params->server_port > MAX_PORT_VALUE)
                {
                    printf("Invalid DHCP server port value: '%s'\n", argv[i + 1]);
                    usage(0);
                }
                break;
            case 'l':
                if(strlen(argv[i + 1]) > 17)
                {
                    printf("Legal-server ethernet address too long.\n");
					usage(0);
                }
                if(!ignor_servers_list(add, argv[i + 1]))
                {
                    printf("Invalid legal-server ethernet address: '%s'\n", argv[i + 1]);
					usage(0);
                }
                break;
			case 'T':
				params->timeout = atoi(argv[i + 1]);
				if(params->timeout < 1)
				{
					printf("Invalid timeout value: '%s'\n", argv[i + 1]);
					usage(0);
				}
				break;
			case 'L':
			{
				if(strlen(argv[i + 1]) > MAX_IP4_ALEN) /* 3 = / + \d + d\. Sample: "/24" */
				{
					printf("Invalid legal network IP address: '%s'\n", argv[i + 1]);
					usage(0);
				}

				uint32_t net;
				if( ( net = inet_addr(argv[i + 1])) == INADDR_NONE)
				{
					printf("Invalid legal network IP address: '%s'\n", argv[i + 1]);
					usage(0);
				}

				legal_nets_list(add, &net);

				break;
			}
			case 'M':
				params->max_hosts_scan = atoi(argv[i + 1]);
				if(params->max_hosts_scan < 4)
				{
					printf("Invalid maximum hosts scan value: %s. Minimum - 4.\n", argv[i + 1]);
					usage(0);
				}
			break;
			case 'w':
				params->wait_before_restart = atoi(argv[i + 1]);
				if(params->wait_before_restart < 1)
				{
					printf("Invalid 'wait before rerun' value: %s\n", argv[i + 1]);
					usage(0);
				}
				break;
			case 'S':
			{
				char network[MAX_IP4_ALEN + 3 + 1]; /* 3 - CIDR mask (/24 e.g.) 1 - \0 */
				bzero(network, sizeof(network));

				if(strlen(argv[i + 1]) > (sizeof(network) - 1))
				{
					printf("Invalid network for scanning: %s - too long.\n", argv[i + 1]);
					usage(0);
				}

				strncpy(network, argv[i + 1], strlen(argv[i + 1]));

				char * mask = strrchr(network, '/');
				if(!mask)
				{
					printf("Invalid network for scanning: %s - netmask not specified.\n", network);
					usage(0);
				}

				*mask = '\0';	/* Split network and netmask strings */
				++mask;

				if( (params->scanned_network = inet_addr(network)) == INADDR_NONE)
				{
					printf("Invalid network IP address for scanning: %s\n", network);
					usage(0);
				}

				params->scan_netmask = atoi(mask);
				if( (params->scan_netmask < 0) || (params->scan_netmask > 30))
				{
					printf("Invalid netmask length: %s. Minimum - 0, maximum - 30.\n", mask);
					usage(0);
				}

				int bit_pos;
				uint32_t netmask = 0;
				for(bit_pos = 0; bit_pos < (32 - params->scan_netmask) ; ++bit_pos)
					netmask |= 1 << bit_pos;
				params->scan_netmask = htonl(~netmask);

				break;
			}
			case 'F':
			{
				if( (params->from_ip = inet_addr(argv[i + 1])) == INADDR_NONE)
				{
					printf("Invalid source IP address: %s\n", argv[i + 1]);
					usage(0);
				}
				break;
			}
            case 's':
            {
				if( (params->server_ip = inet_addr(argv[i + 1])) == INADDR_NONE)
				{
					printf("Invalid server IP address: %s\n", argv[i + 1]);
					usage(0);
				}
            	break;
            }
            default:
                    usage(0);
                break;
            }
            ++i;
        }
        else
        {
            if(strlen(argv[i]) > (sizeof(params->str_source_mac) - 1) )
            {
                printf("Length source MAC address too long. Exit.\n");
				usage(0);
            }
            if(strlen(params->str_source_mac))
				usage(0);               /*Ethernet address already set*/
            replace_semicolons(argv[i]);
            strncat(params->str_source_mac, argv[i], MAX_STR_MAC_LEN);
        }
    }

    if(params->flood && params->test_mode)
    {
        printf("Error: option '-f' (flood) not compatible with option '-t' (test mode).\n");
        usage(0);
    }

    if(params->children_count && ! params->flood)
    {
        printf("Error: option '-C' (children count) compatible only with option '-f' (flood).\n");
        usage(0);
    }

    if(params->max_address_count > 255 && !params->rand_mac_always && !params->flood)
    {
        printf("Error: Option 'max address count' can't be greatest then 255 if you use option -r\n");
        usage(0);
    }

    if(!params->if_name)
        usage(0);

	if(!strcmp("any", params->if_name))
	{
		printf("Can't drop DHCP server on 'any' device! Exit.\n");
		exit(ERR_CONFIG);
	}

	if( params->send_dhcprelease && (!params->server_ip ||
			!params->from_ip || !strlen(params->str_source_mac)) )
	{
		printf("You must specify server IP address (use option -s), client IP address (use option -F)\n"
				"\tand MAC address for sending DHCPRELEASE.\n");
		usage(0);
	}

    /* If not set initial MAC - set random value */
    if(!strlen(params->str_source_mac))
    	rand_ether_addr(params->str_source_mac);
	ret = etheraddr_str_to_bin(params->str_source_mac, params->source_mac);
	if(!ret)
	{
		printf("Invalid parametrs in etheraddr_str_to_bin(). Aborting programm!");
		abort();
	}
	if(ret < 0)
	{
		printf("Invalid source MAC address: '%s'\n", params->str_source_mac);
		usage(0);
	}

    if(! *params->client_hostname)
        strncat(params->client_hostname, DEF_HOSTNAME, sizeof(params->client_hostname) - 1);
    if(! *params->dhcp_client)
        strncat(params->dhcp_client, DEF_DHCPCLIENT, sizeof(params->dhcp_client) - 1);
    if( !params->max_address_count && !params->flood)
        params->max_address_count = MAX_ADDR_COUNT;
	if( !params->timeout)
		params->timeout = DEF_TIMEOUT;
    return;
}

/*
	If num == 0 - show all available interfaces and exit from programm.
	Else - return name of interface by number 'num'
*/
char * interfaces_discover(const int num)
{
	if(!num)
		printf("Available interfaces:\n");

	char errbuf[PCAP_ERRBUF_SIZE];
	pcap_if_t *dev_list_start = 0, * dev_ptr = 0;
	char * if_name = 0;
    int32_t ret = pcap_findalldevs(&dev_list_start, errbuf);

    if(ret == -1)
    {
        printf("Error: %s\n", errbuf);
        exit(ERR_LISTING_DEV);
    }

    if(!dev_list_start)
    {
        printf("Error.\n");
        exit(ERR_LISTING_DEV);
    }

	int i = 1;
    for(dev_ptr = dev_list_start; dev_ptr; dev_ptr = dev_ptr->next)
	{
		if(num)
		{
			if(!strcmp("any", dev_ptr->name))
				continue;
			if((i == num))
			{
				if_name = (char *) calloc(strlen(dev_ptr->name) + 1, sizeof(char));
				if(!if_name)
				{
					printf("Can't allocate memory for interface '%s'. Quit.\n", dev_ptr->name);
					exit(ERR_MEMORY);
				}
				strncpy(if_name, dev_ptr->name, strlen(dev_ptr->name));
				pcap_freealldevs(dev_list_start);
				return if_name;

			}
			++i;
		}
		else
		{
			if(strcmp("any", dev_ptr->name))
			{
				printf("%d:", i++);
				ifprint(dev_ptr);
			}
		}
	}

	pcap_freealldevs(dev_list_start);

	if(num)	/* Suitable device not found */
		return 0;

	exit(ERR_CONFIG);
}

void send_flood(const struct config_params * params)
{
	int i;
	int ret_code;
	struct flood_params par;
	par.config = params;
#ifdef	_WIN32
	HANDLE		threads[MAX_THREADS_COUNT]; /* Array of threads for DHCP senders */
	DWORD 		th_id[MAX_THREADS_COUNT];	/* Array of threads identifiers */
	par.flood_threads = threads;
	par.threads_ids = th_id;
#endif

	if(params->children_count < 2)
	{
		if( (ret_code = start_flood((void*) &par) ) )
			exit(ret_code);
		return;
	}
#ifdef _WIN32
	printf("WARNING: multithread flood not effectively under OS Windows!\n");
#endif
	printf("Create %d "CHILDREN_TYPE" for flood.\n", params->children_count);
	for( i = 0; i < params->children_count; ++i)
		new_child(&par, i);
	printf("Waiting for all "CHILDREN_TYPE".\n");
	wait_children(&par);
	return;
}

int get_dhcp_server(const struct config_params * config,	/* Configuration parametrs. Can't be NULL */
		pcap_t * pcap_socket,						/* Pointer to pcap device. Can't be NULL */
		struct dhcp_packet_net_header * net_header,	/* Can't be NULL */
		struct dhcp_packet * server_response,		/* Function store DHCP response server here, */
													/* can't be NULL */
		uint16_t * response_length)
{
	if(!pcap_socket || !server_response)
		return ERR_ABNORMAL;

    char filter[PCAP_FILTER_LEN + 1];                      /* filter for pcap_setfilter */
    char str_ether_addr[MAX_STR_MAC_LEN + 1];

    bzero(filter, sizeof(filter));

    /* Create and set DHCP filter */
	int ret;
	if( (ret = make_serverdiscover_filter(filter, sizeof(filter) - 1, config, config->str_source_mac)) )
	{
		printf("Can't create DHCP filter.\n");
		exit(ret);
	}
	/*printf("Filter: %s\n", filter);*/
	if( (ret = set_pcap_filter(pcap_socket, filter)) )
	{
		printf("Can't set DHCP filter.\n");
		exit(ret);
	}

	int packet_len;

	int i;
	uint32_t xid = rand();
	for(i = 0; i < config->max_attempts; ++ i)
	{
		/* Sending DHCPDISCOVER */
		if( (ret = send_dhcp_discover(pcap_socket, config, 0, xid)) )
			return ret;
		/* and waiting DHCPOFFER */
		ret = get_dhcp_response(pcap_socket, config->timeout, DHCPOFFER, xid,
				net_header, server_response, &packet_len);
		if(!ret)	/* DHCP server responded */
		{
			struct in_addr ip;
			/* Trying to decode DHCP response */
            if((ret = get_dhcp_option(server_response, packet_len,
                    DHO_DHCP_SERVER_IDENTIFIER, (void*)&ip.s_addr, sizeof(ip.s_addr))) < 1)
            {
				printf("Can't get DHCP server ID option!\n");
				continue;
            }

            if(ret < 0)
                continue;	/* Possible DoS */

            if(config->test_mode)
            {
                printf("DHCP SRV: %s ", inet_ntoa(ip));
                ip.s_addr = net_header->ip_header.saddr;
                printf("(IP-hdr: %s) SRV ether: ", inet_ntoa(ip));
                print_ether(net_header->eth_head.ether_shost);
                printf(", YIP: %s\n", inet_ntoa(server_response->yiaddr));
            }
            else
        	{
                /* Convert server ethernet address to string */
                bzero(str_ether_addr, sizeof(str_ether_addr));
            	etheraddr_bin_to_str(net_header->eth_head.ether_shost, str_ether_addr);
                /* Print DHCP-info from packet */
                printf("Got response from server %s ", inet_ntoa(ip));
                ip.s_addr = net_header->ip_header.saddr;
                printf("(IP-header %s), server ethernet address: ", inet_ntoa(ip));
                print_ether(net_header->eth_head.ether_shost);
                printf(", ");
                uint32_t lease_time;
                if(get_dhcp_option(server_response, packet_len, DHO_DHCP_LEASE_TIME,
                		(void*)&lease_time, sizeof(lease_time)) > 0)
    				printf("lease time: %.2gh (%us)\n", (float)ntohl(lease_time)/3600, ntohl(lease_time));

                decode_dhcp(server_response, packet_len);

				/* Ask user: "Drop him? [y/n]" */
				char yN[2] = "n";	/* Default - don't drop */
				(config->yes)? yN[0] = 'y' : (printf("Drop him? [y/n] "), scanf("%s", yN));
				if((yN[0] != 'y') && (yN[0] != 'Y'))	/* Don't drop this server */
				{
					/*Add DHCP server ethernet address in ignored list*/
					ignor_servers_list(add, str_ether_addr);

					/* Reinit PCAP filter */
					if( (ret = make_serverdiscover_filter(filter, sizeof(filter) - 1,
							config, config->str_source_mac)) )
					{
						printf("Can't create DHCP filter.\n");
						exit(ret);
					}
					/*printf("Filter: %s\n", filter);*/
					if( (ret = set_pcap_filter(pcap_socket, filter)) )
					{
						printf("Can't set DHCP filter.\n");
						exit(ret);
					}

					/* Reinit DHCP server search loop */
					i = -1;
					if(!config->quiet_mode)
						printf("Searching next server...\n");
					continue;
				}
				*response_length = packet_len;
        	}
			break;
		}

		if(ret > 0)
			exit(ret);	/* Fatal error occured */

		if(!config->quiet_mode)
			printf("Wait DHCPOFFER timeout. Resending DHCPDISCOVER.\n");
	}

	if(ret < 0)	/* DHCPDISCOVER timeout. Illegal server not found. */
		return 0;

    return ILLEGAL_SERV_FOUND;
}

int drop_dhcp_server(const struct config_params * config, pcap_t * pcap_socket,
		const char * srv_etheraddr)
{
    char filter[PCAP_FILTER_LEN + 1];	/* filter for pcap_setfilter */
    uint8_t bin_src_etheraddr[ETH_ALEN];
	char str_src_etheraddr[MAX_STR_MAC_LEN + 1];
	struct dhcp_packet_net_header net_header;
	struct dhcp_packet dhcp_resp;

    bzero(str_src_etheraddr, sizeof(str_src_etheraddr));

	strncat(str_src_etheraddr, config->str_source_mac, sizeof(str_src_etheraddr) - 1);
	etheraddr_str_to_bin(str_src_etheraddr, bin_src_etheraddr);

	int ret;
	int i;
	int j;
	int packet_len;
	uint32_t xid;
	int grab_ip_count = 0;

	/* Send DHCPDISCOVER(s) and wait response from DHCP server */
	for(i = config->max_attempts; i > 0;)
	{
		bzero(filter, sizeof(filter));
		/* Create and set filter for DHCP transaction */
		if( (ret = make_serverdrop_filter(filter, sizeof(filter) - 1, config,
				str_src_etheraddr, srv_etheraddr)) )
		{
			printf("Can't create pcap filter for dropping DHCP server! Exit.\n");
			exit(ret);
		}

		if( (ret = set_pcap_filter(pcap_socket, filter)) )
		{
			printf("Can't set DHCP filter.\n");
			exit(ret);
		}

		xid = rand();
		/* Sending DHCPDISCOVER */
		if( (ret = send_dhcp_discover(pcap_socket, config, bin_src_etheraddr, xid)) )
			exit(ret);

		/* and waiting DHCPOFFER */
		ret = get_dhcp_response(pcap_socket, config->timeout, DHCPOFFER, xid,
				&net_header, &dhcp_resp, &packet_len);

		if(!ret)	/* DHCP server responded */
		{
			uint32_t server_id;
			if((ret = get_dhcp_option(&dhcp_resp, packet_len,
					DHO_DHCP_SERVER_IDENTIFIER, (void*)&server_id, sizeof(server_id))) < 1)
			{
				printf("Can't get DHCP server ID option!\n");
				continue;
			}
			if(ret < 0)
				continue;	/* Possible DoS */

			/* Trying to receive offered IP address */
			for(j = 0; j < config->max_attempts; ++j)
			{
				/* Sendig DHCPREQUEST */
				if( (ret = send_dhcp_request(pcap_socket, config, bin_src_etheraddr,
						server_id, dhcp_resp.yiaddr.s_addr, xid)) )
					exit(ret);

				/* and waiting DHCPACK */
				ret = get_dhcp_response(pcap_socket, config->timeout, DHCPACK, xid,
						&net_header, &dhcp_resp, &packet_len);
				if(!ret)	/* DHCP server responded */
				{
					++grab_ip_count;
					if(!config->quiet_mode)
					{
						printf("%d. ", grab_ip_count);
						decode_dhcp(&dhcp_resp, packet_len);
					}

					bzero(str_src_etheraddr, sizeof(str_src_etheraddr));

					if(config->rand_mac_always)
					{
						rand_ether_addr(str_src_etheraddr);
						etheraddr_str_to_bin(str_src_etheraddr, bin_src_etheraddr);
					}
					else
					{
						++bin_src_etheraddr[ETH_ALEN - 1];
						etheraddr_bin_to_str(bin_src_etheraddr, str_src_etheraddr);
					}

					i = config->max_attempts;
					goto get_next_ip;
				}

				if(ret > 0)
					exit(ret);	/* Fatal error occured */

				if(!config->quiet_mode)
					printf("Wait DHCPACK timeout. Resending DHCPREQUEST.\n");
			}
		}

		if(ret > 0)
			exit(ret);	/* Fatal error occured */

		if(!config->quiet_mode)
			printf("Wait DHCPOFFER timeout. Resending DHCPDISCOVER.\n");
		--i;

get_next_ip:;
		if(grab_ip_count >= config->max_address_count)
			break;
	}
	return grab_ip_count;
}

int agressive_clean_leases(pcap_t * pcap_socket,
		const struct config_params * config, struct dhcp_packet_net_header * srv_net_header,
		const struct dhcp_packet * srv_resp, uint16_t resp_len)
{
	if(!config->quiet_mode)
		printf("Trying to use agressive mode.\n");

	uint32_t	server_netmask;

	if(get_dhcp_option(srv_resp, resp_len, DHO_SUBNET_MASK, &server_netmask, sizeof(server_netmask)) < 1)
	{
		printf("Can't get netmask from DHCP packet.\n");
		return -1;
	}

	int lnets_count = legal_nets_list(get_count, 0);
	uint32_t lnet, i;
	for(i = 0; i < lnets_count; ++i)
	{
		lnet = legal_nets_list(by_index, &i);
		if((srv_resp->yiaddr.s_addr & server_netmask) ==
			(lnet & server_netmask))
		{
			printf("Can't use argessive mode because the network assigned "
					"by DHCP server and the legal network are the same: %s/%d & ",
					iptos(srv_resp->yiaddr.s_addr & server_netmask), to_cidr(server_netmask));
			printf("%s/%d\n", iptos(lnet & server_netmask), to_cidr(server_netmask));
			return -1;
		}
	}


	/* Searching hosts in illegal network */

	uint32_t start_ip = ntohl(srv_resp->yiaddr.s_addr & server_netmask);

	if(!start_ip)
	{
		printf("Invalid IP address in DHCP server response: %s\n", inet_ntoa(srv_resp->yiaddr));
		return -1;
	}

	uint32_t end_ip = start_ip + (~ntohl(server_netmask));

	/* Check IP address range length */
	if((end_ip - start_ip) > config->max_hosts_scan)
	{
		printf("Too long IP address scan range: %d. Maximum allowed scans: %d. "
				"Use option -M for change this value.\n",
				end_ip - start_ip, config->max_hosts_scan);
		return -1;
	}

	if(!config->quiet_mode)
	{
		printf("Starting ARP scanning network in range: %s - ", iptos(htonl(start_ip)));
		printf("%s...\n", iptos(htonl(end_ip)));
	}

	int ret = arp_scan(pcap_socket, start_ip, end_ip,
			srv_resp->yiaddr.s_addr, srv_resp->chaddr);

	if(ret)
		exit(ret);

	/* Now we have list of hosts with IP adresses assigned by illegal DHCP server */
	int hosts_count = hosts_list(get_count, 0, NULL);
	if(hosts_count < 2)	/* Hosts with invalid IP addresses not found. 1 - itself DHCP server */
	{
		if(!config->quiet_mode)
			printf("Hosts with invalid IP addresses not found.\n");
		return 0;
	}

	char ether_addr[MAX_STR_MAC_LEN + 1];
	bzero(ether_addr, sizeof(ether_addr));
	uint8_t bin_ethaddr[ETH_ALEN];
	uint32_t ip;

	printf("Illegal DHCP server perhaps assigned IP adresses to the following hosts:\n");
	for(i = 0; i < hosts_count; ++i)
	{
		ip = hosts_list(by_index, i, bin_ethaddr);
		etheraddr_bin_to_str(bin_ethaddr, ether_addr);
		printf("%d. Received ARP-reply from: %s (%s)%s", i + 1, ether_addr, iptos(ip),
				((ip == srv_net_header->ip_header.saddr) &&
					!memcmp(srv_net_header->eth_head.ether_shost, bin_ethaddr, ETH_ALEN)
				)? " - itself DHCP server.\n" : "\n");
	}

	printf("Sending DHCPRELEASE for invalid clients:\n");
	for(i = 0; i < hosts_count; ++i)
	{
		ip = hosts_list(by_index, i, bin_ethaddr);
		if((ip == srv_net_header->ip_header.saddr) &&
				!memcmp(srv_net_header->eth_head.ether_shost, bin_ethaddr, ETH_ALEN))
			continue;
		etheraddr_bin_to_str(bin_ethaddr, ether_addr);
		printf("Send DHCPRELEASE for host %s (%s).\n", ether_addr, iptos(ip));
		if( (ret = send_dhcp_release(pcap_socket, config, bin_ethaddr,
				srv_net_header->ip_header.saddr, ip, rand())) )
			exit(ret);
		sleep(2);
	}

	return 0;
}

void scan_subnet(pcap_t * pcap_socket, uint32_t from_ip, const uint8_t * from_eth,
		const uint32_t network, const uint32_t netmask)
{
	uint32_t start_ip = ntohl(network & netmask);
	uint32_t end_ip = start_ip + (~ntohl(netmask));

	printf("Starting ARP-scanning for subnet %s/%d.\n", iptos(htonl(start_ip & ntohl(netmask))),
			to_cidr(netmask));

	printf("IP address range %s - ", iptos(htonl(start_ip)));
	printf("%s.\n", iptos(htonl(end_ip)));

	if(!from_ip)
	{
		from_ip = htonl(start_ip + ((uint32_t) rand() % (end_ip - start_ip)));
		printf("WARNING: Source IP is not set (use option -F).\n"
				"Using random value for source IP address: %s\n", iptos(from_ip));
	}

	int ret = arp_scan(pcap_socket, start_ip, end_ip, from_ip, from_eth);

	/* Now we have list of hosts with IP adresses assigned by illegal DHCP server */
	int hosts_count = hosts_list(get_count, 0, NULL);
	char ether_addr[MAX_STR_MAC_LEN + 1];
	bzero(ether_addr, sizeof(ether_addr));
	uint8_t bin_ethaddr[ETH_ALEN];
	uint32_t ip;
	int i;

	for(i = 0; i < hosts_count; ++i)
	{
		ip = hosts_list(by_index, i, bin_ethaddr);
		etheraddr_bin_to_str(bin_ethaddr, ether_addr);
		printf("%d. Received ARP-reply from: %s (%s).\n", i + 1, ether_addr, iptos(ip));
	}

	if(ret)
		exit(ret);
}

int arp_scan(pcap_t * pcap_socket, const uint32_t start_range, const uint32_t end_range,
		uint32_t from_ip, const uint8_t * from_ether)
{
	int ret;

	/* Set PCAP filter for receiving ARP packets for host 'from_ether'*/
	char str_from_ether[MAX_STR_MAC_LEN + 1];
	static char filter[PCAP_FILTER_LEN + 1];

	bzero(filter, sizeof(filter));
	bzero(str_from_ether, sizeof(str_from_ether));

	etheraddr_bin_to_str(from_ether, str_from_ether);

	if( (ret = make_arp_filter(filter, sizeof(filter) - 1, str_from_ether)) )
	{
		printf("Can't create ARP filter. Error code: %d.\n", ret);
		return ret;
	}

	if( (ret = set_pcap_filter(pcap_socket, filter)) )
	{
		printf("Can't set ARP filter.\n");
		return ret;
	}

	hosts_list(flush, 0, 0);

	/* Scanning network */
	int l;
	for(l = 0; l < 2; ++l)
	{
		uint32_t ip;
		for(ip = start_range; ip <= end_range; ++ip)
		{
			if( (ret = send_arpreq(pcap_socket, htonl(ip), from_ip, from_ether)) )
			{
				printf("Sending ARP packet error! Code: %d.\n", ret);
				return ret;
			}

			usleep(60);

			if( (ret = get_arpresps(pcap_socket, 0)) )
			{
				printf("Get ARP packet error! Code: %d.\n", ret);
				return ret;
			}
		}
	}
	/* Waiting for slow hosts */
	if( (ret = get_arpresps(pcap_socket, 2)) )
	{
		printf("Get ARP packet error! Code: %d.\n", ret);
		return ret;
	}

	return 0;
}

int get_arpresps(pcap_t * pcap_socket, int timeout)
{
    uint8_t	ether_packet[DHCP_MTU_MAX];
    struct arp_packet_net_header * arp_header;

	time_t timeout_time;
	int		one_packet_timeout = timeout ? 1 : 0;
	if(timeout)
		timeout_time = time(0) + timeout;

	int ret;
	while(1)
	{
		if( (ret = get_packet(pcap_socket, ether_packet, one_packet_timeout)) < 0)
			return ERR_GETPACKET;

		if(ret)
		{
			arp_header = (struct arp_packet_net_header *) ether_packet;
			if(arp_header->arp_head.arp_oper == ARP_OP_RESP)
			{
				struct arp_data * arp_d = (struct arp_data *)
					(ether_packet + sizeof(struct arp_packet_net_header));
				hosts_list(add, arp_d->from_ip, arp_d->from_ether);
			}
		}

		if(!timeout)
			break;

		if(time(0) == timeout_time)
			break;
	}

	return 0;
}

int send_arpreq(pcap_t * pcap_socket, const uint32_t to_ip,
		const uint32_t from_ip, const uint8_t * from_ether)
{
	static struct arp_data arp_d;

	memcpy(arp_d.from_ether, from_ether, ETH_ALEN);
	arp_d.from_ip = from_ip;

	memcpy(arp_d.to_ether, broadcast_ether, ETH_ALEN);
	arp_d.to_ip = to_ip;

	if(!send_packet(pcap_socket, arp_packet, (uint8_t *) &arp_d, sizeof(arp_d), 0, from_ether, 0))
	{
        pcap_close(pcap_socket);
        return ERR_SENDPACKET;
	}
	return 0;
}

#ifdef	_WIN32
BOOL WINAPI int_sign(DWORD signal)
#else
int int_sign(int32_t signal)
#endif
{
    if(signal == INTERRUPT_SIGNAL)
    {
        printf("Interrupted. Quit.\n");
        exit(EXIT_SUCCESS);
    }
	return 0;
}

#ifdef _WIN32
unsigned __stdcall start_flood( void* arg )
#else
int start_flood( void* arg )
#endif
{
	flood_params_ptr par_ptr = (flood_params_ptr) arg;
    int j = 0, i;
    int ret;

    uint8_t src_ether[ETH_ALEN];

    int packets_count = par_ptr->config->max_address_count + ((par_ptr->config->max_address_count)? 0 : 1 );

    memcpy(src_ether, par_ptr->config->source_mac, sizeof(src_ether));

    pcap_t * pcap_socket = get_device(par_ptr->config);

	while( j < packets_count )
    {	/* Sending DHCDISCOVER */
		if( (ret = send_dhcp_discover(pcap_socket, par_ptr->config, src_ether, 0)) )
			return ret;

        usleep(CAP_TIMEOUT);

        if(par_ptr->config->rand_mac_always)  /* Randomize source ethernet address for next DHCPDISCOVER */
        {
        	src_ether[0] = 0;
            for(i = 1; i < 6; ++i)
            	src_ether[i] = rand();
        }
        if(par_ptr->config->max_address_count)
            ++j;
    }
    pcap_close(pcap_socket);
    return 0;
}


void new_child(const struct flood_params * p, const int child_num)
{
#ifdef _WIN32
	printf("Create thread #%d.\n", child_num + 1);
	p->flood_threads[child_num] = (HANDLE)_beginthreadex(NULL, 0, start_flood, (void*) p, 0,
		(uint32_t *) &p->threads_ids[child_num]);

#else
	int pid;
	pid = fork();
	if(pid)
		printf("Create child #%d with pid %d.\n", child_num + 1, pid);
	else
	{   /* Generate flood from child processes */
		exit(start_flood((void*) p));
	}

#endif
}

void wait_children(const struct flood_params * p)
{
#ifdef	_WIN32
	WaitForMultipleObjects(p->config->children_count, (HANDLE*) p->flood_threads, 1, INFINITE);
#else
	int32_t pid;
	while( (pid = wait(0)) != -1)
		printf("Child with pid %d finished.\n", pid);
#endif
	return;
}

int send_dhcp_discover(pcap_t * pcap_socket, const struct config_params * config,
	uint8_t * src_ether, const uint32_t xid)
{
	/* Create DHCPDISCOVER */
	struct dhcp_packet dhcp_req;

	int dhcp_opt_len = make_dhcp_req(&dhcp_req, DHCPDISCOVER, src_ether ? src_ether : config->source_mac,
			0, 0, xid, config);
    int snd_data_len = sizeof(struct dhcp_packet) - DHCP_OPTION_LEN + dhcp_opt_len;
    if(snd_data_len < BOOTP_MIN_LEN)
        snd_data_len = BOOTP_MIN_LEN;

    /* Send DHCPDISCOVER to DHCP server */
    if(!send_packet(pcap_socket, dhcp_packet, (uint8_t*) &dhcp_req,
    		snd_data_len, config, src_ether ? src_ether : config->source_mac, 0))
    {
    	printf("Can't send packet: %s\n", pcap_geterr(pcap_socket));
        pcap_close(pcap_socket);
        return ERR_SENDPACKET;
    }

    return 0;
}

int make_serverdiscover_filter(char * out_filter, const int max_filter_len,
		const struct config_params * config, const char * src_etheraddr)
{
	if(!out_filter || !config)
		return ERR_ABNORMAL;

	/* Adding in pcap-filter all ignored servers */
	struct ignored_mac_node * ign_ptr = ignor_servers_list(get_top, 0);

    snprintf(out_filter, max_filter_len + 1,
			STR_SERVERDISCOVER_FILTER, src_etheraddr,
            (config->always_wait_from_67)? DEF_SERVER_PORT : config->server_port,
            (config->always_wait_to_68)? DEF_CLIENT_PORT : config->client_port
        );

	while(ign_ptr)
	{
		if(strlen(" and not ether src host ") +
			strlen(ign_ptr->mac_addr) +
			strlen(out_filter) > max_filter_len)
		{
			printf("Error! Filter owerflow.\n");
			return ERR_FILTER_OWERFLOW;
		}

		strncat(out_filter, " and not ether src host ", max_filter_len - strlen(out_filter));
		strncat(out_filter, ign_ptr->mac_addr,  max_filter_len - strlen(out_filter));
		ign_ptr = ign_ptr->next;
	}

	return 0;
}

int make_arp_filter(char * out_filter, const int max_filter_len, const char * src_etheraddr)
{
	if(!out_filter)
		return ERR_ABNORMAL;

	static const char arp_filter[] = "arp and ether dst ";

	if((strlen(arp_filter) + strlen(src_etheraddr)) > max_filter_len)
		return -1;

	strncpy(out_filter, arp_filter, max_filter_len);
	strncat(out_filter, src_etheraddr, max_filter_len - strlen(out_filter));

	return 0;
}

int make_serverdrop_filter(char * out_filter, const int max_filter_len,
		const struct config_params * config,
		const char * src_etheraddr, const char * server_ethaddr)
{
	if(!out_filter || !config || !src_etheraddr || !server_ethaddr)
		return ERR_ABNORMAL;

    snprintf(out_filter, max_filter_len + 1, STR_SERVERDROP_FILTER, src_etheraddr,
            (config->always_wait_from_67)? DEF_SERVER_PORT : config->server_port,
            (config->always_wait_to_68)? DEF_CLIENT_PORT : config->client_port,
            server_ethaddr);

    return 0;
}


int set_pcap_filter(pcap_t * pcap_socket, char * filter_expression)
{
    struct bpf_program fp;
    if(pcap_compile(pcap_socket, &fp, filter_expression, 1, 0) == -1)
    {
        printf("pcap_compile error: %s\nFilter expression is: '%s'\n",
        		pcap_geterr(pcap_socket), filter_expression);
        pcap_close(pcap_socket);
        return ERR_PCAP_COMPILE;
    }

    if(pcap_setfilter(pcap_socket, &fp) == -1)
    {
        perror("pcap_setfilter");
        pcap_close(pcap_socket);
        return ERR_PCAP_SETFILTER;
    }

    pcap_freecode(&fp);

    return 0;
}

int send_dhcp_request(pcap_t * pcap_socket, const struct config_params * config,
	uint8_t * src_ether,	/* Pseudo-client source ethernet address. Can't be NULL */
    const uint32_t server_ip_address,	/* DHCP server IP address. Can't be NULL */
    const uint32_t req_ip_addr,			/* Required client IP address. Can't be NULL */
    const int32_t xid
)
{
	if(!pcap_socket || !config || !src_ether || !server_ip_address || !req_ip_addr)
		return ERR_ABNORMAL;

	/* Create DHCPREQUEST */
	struct dhcp_packet dhcp_req;

	int dhcp_opt_len = make_dhcp_req(&dhcp_req, DHCPREQUEST, src_ether,
			server_ip_address, req_ip_addr, xid, config);

    int snd_data_len = sizeof(struct dhcp_packet) - DHCP_OPTION_LEN + dhcp_opt_len;
    if(snd_data_len < BOOTP_MIN_LEN)
        snd_data_len = BOOTP_MIN_LEN;

    /* Send DHCPREQUEST to DHCP server */
    if(!send_packet(pcap_socket, dhcp_packet, (uint8_t*) &dhcp_req,
    		snd_data_len, config, src_ether ? src_ether : config->source_mac, 0))
    {
    	printf("Can't send packet: %s\n", pcap_geterr(pcap_socket));
        pcap_close(pcap_socket);
        return ERR_SENDPACKET;
    }

    return 0;
}

int send_dhcp_release(pcap_t * pcap_socket, const struct config_params * config,
	const uint8_t * src_ether,	/* Pseudo-client source ethernet address. Can't be NULL */
    const uint32_t server_ip_address,	/* DHCP server IP address. Can't be NULL */
    const uint32_t cl_ip_addr,			/* Released client IP address. Can't be NULL */
    const int32_t xid
)
{
	if(!pcap_socket || !config || !src_ether || !server_ip_address || !cl_ip_addr)
		return ERR_ABNORMAL;

	/* Create DHCPREQUEST */
	struct dhcp_packet dhcp_req;

	int dhcp_opt_len = make_dhcp_req(&dhcp_req, DHCPRELEASE, src_ether,
			server_ip_address, cl_ip_addr, xid, config);

    int snd_data_len = sizeof(struct dhcp_packet) - DHCP_OPTION_LEN + dhcp_opt_len;
    if(snd_data_len < BOOTP_MIN_LEN)
        snd_data_len = BOOTP_MIN_LEN;

    /* Send DHCPREQUEST to DHCP server */
    if(!send_packet(pcap_socket, dhcp_packet, (uint8_t*) &dhcp_req,
    		snd_data_len, config, src_ether ? src_ether : config->source_mac, server_ip_address))
    {
    	printf("Can't send packet: %s\n", pcap_geterr(pcap_socket));
        pcap_close(pcap_socket);
        return ERR_SENDPACKET;
    }

    return 0;
}

int get_dhcp_response(pcap_t * pcap_socket, const int timeout, const uint8_t resp_type,
		const uint32_t xid, struct dhcp_packet_net_header * net_header,
		struct dhcp_packet * response, int * dhcp_data_len)
{
    uint8_t	ether_packet[DHCP_MTU_MAX];
    struct dhcp_packet_net_header * dhcp_net_header;
	struct	dhcp_packet *dhcp_resp;
	uint8_t dhcp_msg_type;

	const int max_errors = 10;
	int	errors = 0;

    while(1)
    {
    	if(errors == max_errors)
    		break;

		int ret = get_packet(pcap_socket, ether_packet, timeout);

		if(ret < 0)
			return ERR_GETPACKET;

		if(!ret)
			return -1;	/* Timeout - server not respond */

		/* Analysing packet */
		dhcp_net_header = (struct dhcp_packet_net_header *) ether_packet;
		dhcp_resp = (struct dhcp_packet *) (ether_packet + sizeof(struct dhcp_packet_net_header));

		*dhcp_data_len = ntohs(dhcp_net_header->udp_header.len)
		- sizeof(struct udphdr);	/* UDP data length equal DHCP-packet length */

		if(*dhcp_data_len > DHCP_MAX_LEN)
		{
			printf("UDP data len too long (%u bytes)! Attempting DoS?\n", *dhcp_data_len);
			++errors;
			continue;
		}

		if(
				(dhcp_resp->op != BOOTREPLY) ||
				(get_dhcp_option(dhcp_resp, *dhcp_data_len, DHO_DHCP_MESSAGE_TYPE,
						(void*)&dhcp_msg_type, sizeof(dhcp_msg_type)) < 1) ||
				(dhcp_msg_type != resp_type) ||
				(dhcp_resp->xid != xid)
				)
		{
			++errors;
			continue;
		}

		memcpy(net_header, ether_packet, sizeof(struct dhcp_packet_net_header));
		memcpy(response, dhcp_resp, *dhcp_data_len);
	    return 0;
    }

    return -1;
}


struct ignored_mac_node * ignor_servers_list(enum list_operations operation, char * ether_addr)
{
	if(ether_addr)
	{
		replace_semicolons(ether_addr);
		int hex;
		if(sscanf(ether_addr, "%x:%x:%x:%x:%x:%x",
				&hex, &hex, &hex, &hex, &hex, &hex) < 6)	/* Invalid format! */
			return 0;
	}

	static struct ignored_mac_node * ignored_list_top = 0;

	switch(operation)
	{
	case add:
		{
			if(!ether_addr || (strlen(ether_addr) < MIN_STR_MAC_LEN))
				return 0;

			struct ignored_mac_node * new_node =
				(struct ignored_mac_node *) malloc(sizeof(struct ignored_mac_node));

			if(! new_node)
			{
				printf("Can't allocate memory for legal DHCP server ethernet address! Exit.");
				exit(ERR_MEMORY);
			}

			bzero(new_node, sizeof(struct ignored_mac_node));
			strncpy(new_node->mac_addr, ether_addr, sizeof(new_node->mac_addr) - 1);
			new_node->next = ignored_list_top;
			ignored_list_top = new_node;
			return ignored_list_top;
		}
		break;
	case rem:
		{
			struct ignored_mac_node * node_ptr = ignored_list_top;
			while(node_ptr)
			{
				if(!strncmp(node_ptr->mac_addr, ether_addr, sizeof(node_ptr->mac_addr) - 1))
				{
					struct ignored_mac_node * removed = node_ptr;
					node_ptr = node_ptr->next;
					free(removed);
					return ignored_list_top;
				}
				else
					node_ptr = node_ptr->next;
			}
		}
		break;
	case get_top:
		return ignored_list_top;
	case search:
		{
			struct ignored_mac_node * node_ptr = ignored_list_top;
			while(node_ptr)
				if(!strncmp(node_ptr->mac_addr, ether_addr, sizeof(node_ptr->mac_addr) - 1))
					return ignored_list_top;
				else
					node_ptr = node_ptr->next;
		}
		break;
	case flush:
		{
			struct ignored_mac_node * next_node;
			while(ignored_list_top)
			{
				next_node = ignored_list_top->next;
				free(ignored_list_top);
				ignored_list_top = next_node;
			}
			return ignored_list_top;
		}
		break;
	default:
		break;
	}
	return 0;
}

uint32_t legal_nets_list(enum list_operations operation, const uint32_t * value)
{
	static uint32_t * legal_nets = 0;
	static int count = 0;
	static int capacity = 0;

	switch(operation)
	{
	case get_count:
		return count;
	case add:
		if(!capacity)
		{
			capacity = 4;
			if( !(legal_nets = (uint32_t *) malloc(sizeof(uint32_t) * capacity)) )
			{
				printf("Can't allocate memory for legal networks! Exit.\n");
				exit(ERR_MEMORY);
			}
		}

		if(count == capacity)
		{
			capacity *= 2;
			if( !(legal_nets = (uint32_t*) realloc(legal_nets, capacity)))
			{
				printf("Can't reallocate memory for legal networks! Exit.\n");
				exit(ERR_MEMORY);
			}
		}

		legal_nets[count] = *value;
		++count;
		break;
	case by_index:
		return legal_nets[*value];
	case flush:
		count = 0;
		capacity = 0;
		if(legal_nets)
			free(legal_nets);
		break;
	default:
		printf("Unknown operation on legal nets.\n");
		break;
	}
	return count;
}

int	hosts_list(enum list_operations operation, uint32_t ip_addr, uint8_t * ether_addr)
{
	struct invalid_host
	{
		uint8_t 	ether_addr[ETH_ALEN];
		uint32_t	ip_addr;
	};

	static struct invalid_host * hosts_list = 0;
	static int count = 0;
	static int capacity = 0;

	switch(operation)
	{
	case get_count:
		return count;
	case add:
	{
		int i;
		for(i = 0; i < count; ++i)
			if(!memcmp(hosts_list[i].ether_addr, ether_addr, sizeof(hosts_list[i].ether_addr)) &&
					(hosts_list[i].ip_addr == ip_addr))	/* Dupe */
				return 0;

		if(!capacity)
		{
			capacity = 4;
			if(! (hosts_list = (struct invalid_host* ) malloc(sizeof(struct invalid_host) * capacity)) )
			{
				printf("Can't allocate memory for invalid hosts list! Exit.\n");
				exit(ERR_MEMORY);
			}
		}

		if(count == capacity)
		{
			capacity *= 2;
			if( !(hosts_list = (struct invalid_host *) realloc(hosts_list, sizeof(struct invalid_host) * capacity)))
			{
				printf("Can't reallocate memory for invalid hosts list! Exit.\n");
				exit(ERR_MEMORY);
			}
		}

		memcpy(hosts_list[count].ether_addr, ether_addr, sizeof(hosts_list[count].ether_addr));
		hosts_list[count].ip_addr = ip_addr;
		++count;
	}
	break;
	case by_index:
		if( (ip_addr < 0) || (ip_addr > (count - 1)) )
			return -1;

		memcpy(ether_addr, hosts_list[ip_addr].ether_addr, sizeof(hosts_list[ip_addr].ether_addr));
		return hosts_list[ip_addr].ip_addr;
	case flush:
		capacity = 0;
		count = 0;
		if(hosts_list)
			free(hosts_list);
		break;
	default:
		printf("Unknown operations on invalid hostst list.\n");
		break;
	}

	return 0;
}

void cleanup(void)
{
	ignor_servers_list(flush, 0);
	legal_nets_list(flush, 0);
	hosts_list(flush, 0, 0);
}


int decode_dhcp(const struct dhcp_packet * packet, const uint16_t packet_len)
{
    uint8_t dhcp_msg_type;
    switch(packet->op)
    {
        case BOOTREQUEST:   printf("Got BOOTREQUEST("); break;
        case BOOTREPLY:     printf("Got BOOTREPLY ("); break;
        default:            printf("Unknown message type: %u\n", packet->op); return 0;
    }
    if(get_dhcp_option(packet, packet_len, DHO_DHCP_MESSAGE_TYPE,
    		(void*)&dhcp_msg_type, sizeof(dhcp_msg_type)) < 1)
    {
        printf("Error: Can't get DHCP message type.\n");
        return 0;
    }

    switch(dhcp_msg_type)
    {
        case DHCPDISCOVER:	printf("DHCPDISCOVER) "); break;
        case DHCPOFFER:		printf("DHCPOFFER) "); break;
        case DHCPREQUEST:	printf("DHCPREQUEST) "); break;
        case DHCPDECLINE:	printf("DHCPDECLINE) "); break;
        case DHCPACK:		printf("DHCPACK) "); break;
        case DHCPNAK:		printf("DHCPNAK) "); break;
        case DHCPRELEASE:	printf("DHCPRELEASE) "); break;
        case DHCPINFORM:	printf("DHCPINFORM) "); break;
        default:			printf("Unknown DHCP message type: %u)\n", dhcp_msg_type);
    }

    if(packet->flags && htons(BOOTP_BROADCAST))
		printf("flags: BROADCAST ");
    printf("for client ether: ");
    print_ether(packet->chaddr);

	uint32_t netmask = 0;
    printf(" You IP: %s", inet_ntoa(packet->yiaddr));
    if(get_dhcp_option(packet, packet_len, DHO_SUBNET_MASK, (void*)&netmask, sizeof(netmask)) < 1)
		printf("\n");
	else
		printf("/%d\n", to_cidr(netmask));

    return dhcp_msg_type;
}

void usage(const char help)
{
    (help)? printf("%s\n%s\n%s", usage_message, keys, ret_codes) : printf("%s", usage_message);
    printf("\n%s\n", COPYRIGHT HOMEPAGE);
    if(!help)
        printf("Use option -h for help. Exit.\n");
    exit(ERR_CONFIG);
}

/* Convert network mask to CIDR notation */
uint32_t to_cidr(uint32_t mask)
{
	mask = ntohl(mask);
	int i;
	for(i = 0; i < 33; ++i)
		if(mask & (1 << i))
			break;
	return (i == 33)? 0 : 32 - i;
}

/* Convert a numeric IP address to a string */
char *iptos(const uint32_t in)
{
	static char output[IPTOSBUFFERS][3*4 + 3 + 1];
	static short which;
	uint8_t *p;

	p = (uint8_t *)&in;
	which = (which + 1 == IPTOSBUFFERS ? 0 : which + 1);
	snprintf(output[which], sizeof(output), "%d.%d.%d.%d", p[0], p[1], p[2], p[3]);
	return output[which];
}

void ifprint(const pcap_if_t *dev)
{
  pcap_addr_t *pcap_addr;
  /* Name */
  printf("%s", dev->name);
  /* Description */
  if (dev->description)
    printf("\n  descr: %s", dev->description);
  /* IP addresses */
  for(pcap_addr = dev->addresses; pcap_addr; pcap_addr = pcap_addr->next)
  {
	if(!pcap_addr->addr)
		continue;
	switch(pcap_addr->addr->sa_family)
	{
		case AF_INET:
			if (pcap_addr->addr)
				printf("\n  iaddr: %s", iptos(((struct sockaddr_in *)pcap_addr->addr)->sin_addr.s_addr));
			if (pcap_addr->netmask)
				printf("/%d ", to_cidr(((struct sockaddr_in *)pcap_addr->netmask)->sin_addr.s_addr));
			if (pcap_addr->broadaddr)
				printf(" bcast: %s",iptos(((struct sockaddr_in *)pcap_addr->broadaddr)->sin_addr.s_addr));
			if (pcap_addr->dstaddr)
				printf(" dst addr: %s",iptos(((struct sockaddr_in *)pcap_addr->dstaddr)->sin_addr.s_addr));
			break;
		case AF_INET6:
		break;

		default:
		break;
		}
  }
  printf("\n");
}

inline int etheraddr_bin_to_str(const uint8_t * bin_addr, char * str_addr)
{
	if(!bin_addr || !str_addr)
		return 0;
     snprintf(str_addr, MAX_STR_MAC_LEN + 1, "%02x:%02x:%02x:%02x:%02x:%02x",
                    bin_addr[0], bin_addr[1], bin_addr[2], bin_addr[3], bin_addr[4], bin_addr[5]);
	return 1;
}

int etheraddr_str_to_bin(const char * str_addr, uint8_t * bin_addr)
{
	if(!str_addr || !bin_addr)
		return 0;

	static char ether_addr[MAX_STR_MAC_LEN + 1];	/* Non-const buffer for strtok */
	bzero(ether_addr, sizeof(ether_addr));
	strncpy(ether_addr, str_addr, sizeof(ether_addr) - 1);

	int i = 0;
	int byte;
	char * bytePtr = strtok(ether_addr, ":-");
	while(bytePtr)
	{
		if(i > 5)
			return -1;	/* Ethernet address consist from 6 bytes! */

		if(strlen(bytePtr) > 2)
			return -1;	/* Too long digit */

		if(sscanf(bytePtr, "%02x", &byte) < 1)
			return -1;	/* Invalid HEX digit */

		bin_addr[i++] = (uint8_t) byte;
		bytePtr = strtok(NULL, ":-");
	}
	if(i < 6)
		return -1; ;	/* Ethernet address consist from 6 bytes! */
	return 1;
}

inline void replace_semicolons(char * str_ether)
{
	char * p = str_ether;
	while(*p)
	{
		if(*p == '-')
			*p = ':';
		++p;
	}
}

inline void print_ether(const uint8_t * ether_addr)
{
	int i;
	for(i = 0; i < ETH_ALEN; ++i)
		printf((i == (ETH_ALEN - 1) ) ? "%02X" :"%02X:", ether_addr[i]);
}

inline void rand_ether_addr(char * str_mac_addr) /* Minimal size of str_mac_addr must be STR_MAC_LEN (18) */
{
    /* Fill first byte */
    strncat(str_mac_addr, "00:", 3);
    char * p = str_mac_addr + strlen(str_mac_addr);
    int i;
    for(i = 0; i < 5; ++i, p +=3) /* Randomize next 5 bytes */
		snprintf(p, 4, (i < 4)? ("%02X:") : "%02X", (int)(rand() & 0xFF));
    return;
}
