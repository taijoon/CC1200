#COMPONENT=BlinkAppC
#COMPONENT=TestCc1200AppC
COMPONENT=OscilloscopeAppC
PFLAGS += -DCC2420_DEF_CHANNEL=26
DEFAULT_LOCAL_GROUP=0x26

CFLAGS += -I./cc1200
CFLAGS += -I./cc1200/alarm
CFLAGS += -I./cc1200/control
CFLAGS += -I./cc1200/csma
CFLAGS += -I./cc1200/interfaces
CFLAGS += -I./cc1200/link
CFLAGS += -I./cc1200/lowpan
CFLAGS += -I./cc1200/lpl
CFLAGS += -I./cc1200/packet
CFLAGS += -I./cc1200/receive
CFLAGS += -I./cc1200/spi
CFLAGS += -I./cc1200/transmit
CFLAGS += -I./cc1200/unique
CFLAGS += -I./cc1200/security
include $(MAKERULES)
