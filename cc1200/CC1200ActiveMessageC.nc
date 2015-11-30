
#include "CC1200.h"
#include "AM.h"
#include "Ieee154.h"

#ifdef IEEE154FRAMES_ENABLED
#error "CC1200 AM layer cannot work when IEEE 802.15.4 frames only are used"
#endif

configuration CC1200ActiveMessageC {
  provides {
    interface SplitControl;
    interface AMSend[am_id_t id];
    interface Receive[am_id_t id];
    interface Receive as Snoop[am_id_t id];
    interface AMPacket;
    interface Packet;
    interface CC1200Packet;
    interface PacketAcknowledgements;
    interface LinkPacketMetadata;
    interface RadioBackoff[am_id_t amId];
    interface LowPowerListening;
    interface PacketLink;
    interface SendNotifier[am_id_t amId];
  }
}
implementation {
  enum {
    CC1200_AM_SEND_ID     = unique(RADIO_SEND_RESOURCE),
  };

  components CC1200RadioC as Radio;
  components CC1200ActiveMessageP as AM;
  components ActiveMessageAddressC;
  components CC1200CsmaC as CsmaC;
  components CC1200ControlC;
  components CC1200PacketC;
  
  SplitControl = Radio;
  RadioBackoff = AM;
  Packet = AM;
  AMSend = AM;
  SendNotifier = AM;
  Receive = AM.Receive;
  Snoop = AM.Snoop;
  AMPacket = AM;
  PacketLink = Radio;
  LowPowerListening = Radio;
  CC1200Packet = Radio;
  PacketAcknowledgements = Radio;
  LinkPacketMetadata = Radio;
  
  // Radio resource for the AM layer
  AM.RadioResource -> Radio.Resource[CC1200_AM_SEND_ID];
  AM.SubSend -> Radio.ActiveSend;
  AM.SubReceive -> Radio.ActiveReceive;

  AM.ActiveMessageAddress -> ActiveMessageAddressC;
  AM.CC1200Packet -> CC1200PacketC;
  AM.CC1200PacketBody -> CC1200PacketC;
  AM.CC1200Config -> CC1200ControlC;
  
  AM.SubBackoff -> CsmaC;

  components LedsC;
  AM.Leds -> LedsC;
}
