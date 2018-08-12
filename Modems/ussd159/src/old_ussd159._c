
/* ussd159 - a program to send USSD codes using Huawei E159 modems
 *
 * Copyright (C) 2010, 2011 Piotr Durlej
 * http://www.durlej.net/
 *
 */

#include <termios.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>
#include <errno.h>
#include <err.h>

static void at_drain(void);
static void at_simple(const char *cmd);
static void at_wok(void);
static void encira(char *buf, size_t bsz, const char *str);
static void at_wcusd(char *buf, size_t bsz);
static int  dx2(const char *p);
static void decira(char *buf);
static void sig_alrm(int nr);
static void usage(int st) __attribute__((noreturn));

static const char *	ussd = NULL;
static const char *	port = "/dev/cuaU1";
static FILE *		port_file_r, *port_file_w;
static struct termios	port_oti;
static int		port_fd;
static int		timeout = 10;
static int		vflag;

extern char *__progname;

static void strip_crlf(char *s)
{
	char *p;
	
	p = strchr(s, '\r');
	if (p)
		*p = 0;
	
	p = strchr(s, '\n');
	if (p)
		*p = 0;
}

static void at_drain(void)
{
	static char junk[256];
	
	int fl;
	
	fl = fcntl(port_fd, F_GETFL);
	fcntl(port_fd, F_SETFL, fl | O_NDELAY);
	while (read(port_fd, junk, sizeof junk) > 0);
	fcntl(port_fd, F_SETFL, fl);
	
#if __linux
	fflush(port_file_r);
#else
	fpurge(port_file_r);
#endif
}

static void at_command(const char *cmd)
{
	if (vflag)
		warnx("at_command: sending \"%s\"", cmd);
	
	fprintf(port_file_w, "%s\r\n", cmd);
	fflush(port_file_w);
}

static void at_simple(const char *cmd)
{
	at_command(cmd);
	at_wok();
	usleep(100000);
}

static void at_wok(void)
{
	char buf[256];
	char *p;
	
	warnx("at_wok...");
	errno = 0;
	while (fgets(buf, sizeof buf, port_file_r))
	{
		strip_crlf(buf);
		
		if (vflag)
			warnx("at_wok: got \"%s\"", buf);
		if (!strcmp(buf, "OK"))
		{
			if (vflag)
				warnx("at_wok: done");
			return;
		}
	}
	err(1, "%s", port);
}

static void encira(char *buf, size_t bsz, const char *str)
{
	const char *sp;
	char *dp;
	int sh;
	int v;
	
	dp = buf;
	sp = str;
	sh = 0;
	
	while (*sp)
	{
		if (dp + 2 > buf + bsz)
			errx(1, "USSD too long");
		
		v  = sp[0] >> sh;
		v |= (unsigned)sp[1] << (7 - sh);
		sprintf(dp, "%02x", v & 255);
		dp += 2;
		sp++;
		
		if (++sh > 7)
		{
			sh = 0;
			sp++;
		}
	}
}

static void at_wcusd(char *buf, size_t bsz)
{
	char rbuf[bsz + 64];
	char *p0, *p1;
	int v;
	
	warnx("at_wcusd...");
	while (fgets(rbuf, sizeof rbuf, port_file_r))
	{
		strip_crlf(rbuf);
		
		if (vflag)
			warnx("at_wcusd: got \"%s\"", rbuf);
		
		if (strncmp(rbuf, "+CUSD: ", 7))
			continue;
		
		p0 = strchr(rbuf, '\"');
		if (p0 == NULL)
			goto bad_resp;
		p0++;
		
		p1 = strchr(p0, '\"');
		if (p1 == NULL)
			goto bad_resp;
		
		if (p1 - p0 >= bsz)
			errx(1, "%s: response too long", port);
		memcpy(buf, p0, p1 - p0);
		buf[p1 - p0] = 0;
		
		warnx("at_wcusd: done");
		return;
	}
	err(1, "%s", port);
bad_resp:
	errx(1, "%s: bad +CUSD response", port);
}

static int dx2(const char *p)
{
	int v;
	
	if (!isxdigit(p[0]) || !isxdigit(p[1]))
		return -1;
	
	if (isdigit(p[0]))
		v = p[0] - '0';
	else
		v = 10 + toupper(p[0]) - 'A';
	v <<= 4;
	
	if (isdigit(p[1]))
		v |= p[1] - '0';
	else
		v |= 10 + toupper(p[1]) - 'A';
	
	return v;
}

static void decira(char *buf)
{
	const char *sp;
	char *dp;
	int sh;
	int c;
	int v;
	
	if (vflag)
		warnx("decira: buf = \"%s\"",buf);
	dp = buf;
	sh = 0;
	c  = 0;
	for (sp = buf; *sp; sp += 2)
	{
		v = dx2(sp);
		if (sp == dp)
			dp[0] = 0;
		
		c |= v << sh;
		*dp++ = c & 127;
		c = v >> (7 - sh);
		
		if (++sh > 7)
		{
			sp -= 2;
			sh  = 0;
		}
	}
	if (sh)
		*dp++ = c & 127;
	*dp = 0;
}

static void sig_alrm(int nr)
{
#define MSG	": Operation timed out\n"
	write(2, __progname, strlen(__progname));
	write(2, ": ", 2);
	write(2, port, strlen(port));
	write(2, MSG, sizeof MSG - 1);
	_exit(1);
#undef MSG
}

static void setup(void)
{
	struct termios ti;
	int fd;
	
	if (tcgetattr(port_fd, &ti))
		err(1, "%s: tcgetattr", port);
	port_oti = ti;
	
	ti.c_lflag &= ~ICANON;
	if (tcsetattr(port_fd, TCSANOW, &ti))
		err(1, "%s: tcsetattr", port);
}

static void usage(int st)
{
	fprintf(stderr, "usage: %s [-v] [-p PORT] [-t TIMEOUT] -u USSD\n",
		__progname);
	exit(st);
}

int main(int argc, char **argv)
{
	char buf[1024];
	char *p;
	int c;
	
	while (c = getopt(argc, argv, "p:u:t:v"), c > 0)
		switch (c)
		{
		case 'p':
			port = optarg;
			break;
		case 'u':
			ussd = optarg;
			break;
		case 't':
			timeout = atoi(optarg);
			break;
		case 'v':
			vflag = 1;
			break;
		default:
			usage(1);
		}
	if (optind < argc)
		usage(1);
	if (ussd == NULL)
		usage(1);
	
	signal(SIGALRM, sig_alrm);
	alarm(timeout);
	
	if (vflag)
		warnx("opening port %s", port);
	
	port_fd = open(port, O_RDWR);
	if (port_fd < 0)
		err(1, "%s", port);
	
	if (vflag)
		warnx("port opened");
	setup();
	
	port_file_r = fdopen(port_fd, "r");
	if (port_file_r == NULL)
		err(1, "fdopen", port);
	
	port_file_w = fdopen(port_fd, "w");
	if (port_file_w == NULL)
		err(1, "fdopen", port);
	
	at_drain();
	
	at_simple("ate0");
	at_simple("at+cmgf=0");
	at_simple("at+cscs=\"IRA\"");
	
	encira(buf, sizeof buf, ussd);
	
	if (asprintf(&p, "at+cusd=1,\"%s\",15", buf) < 0)
		err(1, "asprintf");
	at_command(p);
	at_wcusd(buf, sizeof buf);
	alarm(0);
	
	decira(buf);
	puts(buf);
	return 0;
}
