TARGET=ussd159
SOURCES=$(wildcard *.c)
OBJECTS=$(SOURCES:%.c=%.o)
STRIP = strip

all: $(TARGET)

$(OBJECTS): $(SOURCES)

$(TARGET): $(OBJECTS)
	$(CC) -o $(TARGET) $(LDFLAGS) $(OBJECTS) $(LOADLIBES) $(LDLIBS)

clean:
	$(RM) $(OBJECTS) $(TARGET)

.PHONY: all clean

strip:
	$(STRIP) -s ussd159