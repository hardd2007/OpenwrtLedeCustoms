CC = gcc
STRIP = strip
#CFLAGS = -O2
EXE = sms_tool

OBJS = pdu.o ucs2_to_utf8.o

all: $(EXE)

$(EXE): sms_main.o pdu.o pdu_decoder.o ucs2_to_utf8
	$(CC) $(CFLAGS) ucs2_to_utf8.o pdu.o pdu_decoder.o -o pdu_decoder
	$(CC) $(CFLAGS) sms_main.o $(OBJS) -o $(EXE)

sms_main.o:
	$(CC) $(CFLAGS) sms_main.c -c
	
pdu_lib: force_look
	cd pdu_lib; CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) $(MFLAGS)
	
clean:
	rm -rf *.o sms_tool pdu_decoder
	
strip:
	$(STRIP) -s sms_tool

pdu.o:
	$(CC) $(CFLAGS) -c pdu.c
	
pdu_decoder.o:
	$(CC) $(CFLAGS) -c pdu_decoder.c
	
ucs2_to_utf8:
	$(CC) $(CFLAGS) -c ucs2_to_utf8.c
	
pdu_decoder: pdu.o pdu_decoder.o ucs2_to_utf8
	$(CC) $(CFLAGS) ucs2_to_utf8.o pdu.o pdu_decoder.o -o pdu_decoder
	
force_look:
	true
	