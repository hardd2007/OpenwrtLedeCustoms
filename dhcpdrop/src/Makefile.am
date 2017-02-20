sbin_PROGRAMS = dhcdrop
dhcdrop_SOURCES = dhcdrop.c dhcp_functions.c net_functions.c
noinst_HEADERS = common_includes.h dhcdrop.h dhcdrop_types.h dhcp_functions.h dhcp.h net.h net_functions.h
dhcdrop_LDADD = -lpcap
if ENABLE_STATIC_BUILD
dhcdrop_LDFLAGS = -all-static
endif
