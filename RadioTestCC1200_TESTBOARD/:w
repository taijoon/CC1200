#TOSMAKE_PATH=". $TOSMAKE_PATH"

#COMPONENT=BlinkAppC
#COMPONENT=NoneAppC
#COMPONENT=RadioCountToLedsAppC
COMPONENT=OscilloscopeAppC
#COMPONENT=BaseStationC


PFLAGS += -DCC2420_DEF_CHANNEL=26
DEFAULT_LOCAL_GROUP=0x26

PFLAGS += -DCC1200_TEST

CC1200_TOSDIR=../cc1200
CFLAGS += -I. \
          -I$(CC1200_TOSDIR)/platforms/telosg/ \
          -I$(CC1200_TOSDIR)/platforms/telosg/chips/cc1200 \
          -I$(CC1200_TOSDIR)/platforms/telosg/chips/stm25p \
          -I$(CC1200_TOSDIR)/chips/cc1200 \
          -I$(CC1200_TOSDIR)/chips/cc1200/alarm \
          -I$(CC1200_TOSDIR)/chips/cc1200/control \
          -I$(CC1200_TOSDIR)/chips/cc1200/csma \
          -I$(CC1200_TOSDIR)/chips/cc1200/interfaces \
          -I$(CC1200_TOSDIR)/chips/cc1200/link \
          -I$(CC1200_TOSDIR)/chips/cc1200/lowpan \
          -I$(CC1200_TOSDIR)/chips/cc1200/lpl \
          -I$(CC1200_TOSDIR)/chips/cc1200/packet \
          -I$(CC1200_TOSDIR)/chips/cc1200/receive \
          -I$(CC1200_TOSDIR)/chips/cc1200/spi \
          -I$(CC1200_TOSDIR)/chips/cc1200/transmit \
          -I$(CC1200_TOSDIR)/chips/cc1200/unique \
          -I$(CC1200_TOSDIR)/chips/cc1200/security

CFLAGS += -I. \
          -I$(CC1200_TOSDIR)/system/

include $(MAKERULES)
