/*
 * os_dependens.h
 *
 *  Created on: 30.07.2009
 *      Author: Chebotarev Roman
 */

#ifndef MAIN_INCLUDES_H_
#define MAIN_INCLUDES_H_

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <pcap.h>               /* if this gives you an error try pcap/pcap.h */

#ifndef _WIN32

#include <arpa/inet.h>
#include <sys/wait.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <signal.h>
#include <time.h>
#include <arpa/inet.h>

#endif



#ifdef	_WIN32

#define bzero(x, y)						ZeroMemory(x, y)
#define	sleep(x)						Sleep(x * 1000)
#define	pcap_inject						pcap_sendpacket
#define set_timer_handler(on_timer)
#define	timer_start(ms, on_timer)		timeSetEvent(ms * 1000,\
								10, (LPTIMECALLBACK) on_timer,\
								0, TIME_ONESHOT )
#define timer_stop(t)					timeKillEvent(t)
#define	set_console_handler(handler)	SetConsoleCtrlHandler(handler, 1);
#define INTERRUPT_SIGNAL				CTRL_C_EVENT
#define	CHILDREN_TYPE					"threads"

#else

#define set_console_handler(handler) \
	if(signal(SIGINT, (void*)handler) == SIG_ERR) \
	{ \
		perror("signal"); \
		exit(ERR_SIGNAL); \
	}

#define set_timer_handler(on_timer) \
	if(signal(SIGALRM, (void*)on_timer) == SIG_ERR) \
	{ \
		perror("signal"); \
		exit(ERR_SIGNAL); \
	}
#define	timer_start(x, on_timer)		alarm(x)
#define timer_stop(t)					alarm(0)
#define INTERRUPT_SIGNAL				SIGINT
#define	CHILDREN_TYPE					"children"

#endif

#endif /* MAIN_INCLUDES_H_ */
