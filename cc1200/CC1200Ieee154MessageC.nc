
#include "CC1200.h"
#ifdef TFRAMES_ENABLED
#error "The CC1200 Ieee 802.15.4 layer does not work with TFRAMES"
#endif

configuration CC1200Ieee154MessageC {
  provides {
    interface SplitControl;

    interface Resource as SendResource[uint8_t clientId];
    interface Ieee154Send;
    interface Receive as Ieee154Receive;

    interface Ieee154Packet;
    interface Packet;

    interface CC1200Packet;
    interface PacketAcknowledgements;
    interface LinkPacketMetadata;
    interface LowPowerListening;
    interface CC1200Config;
    interface PacketLink;
  }
}
implementation {

  components CC1200RadioC as Radio;
  components CC1200Ieee154MessageP as Msg;
  components CC1200PacketC;
  components CC1200ControlC;

  SendResource = Radio.Resource;
  Ieee154Receive = Msg;
  Ieee154Send = Msg;
  Ieee154Packet = Msg;
  Packet = Msg;
  CC1200Packet = CC1200PacketC;

  SplitControl = Radio;
  CC1200Packet = Radio;
  PacketAcknowledgements = Radio;
  LinkPacketMetadata = Radio;
  LowPowerListening = Radio;
  CC1200Config = CC1200ControlC;
  PacketLink = Radio;

  Msg.SubSend -> Radio.BareSend;
  Msg.SubReceive -> Radio.BareReceive;
#ifdef CC1200_IEEE154_RESOURCE_SEND
  Msg.Resource -> Radio.Resource[unique(RADIO_SEND_RESOURCE)];
#endif

  Msg.CC1200Packet -> CC1200PacketC;
  Msg.CC1200PacketBody -> CC1200PacketC;
  Msg.CC1200Config -> CC1200ControlC;

}
