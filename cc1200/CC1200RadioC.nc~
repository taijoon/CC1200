
#include "CC1200.h"

configuration CC1200RadioC {
  provides {
    interface SplitControl;

    interface Resource[uint8_t clientId];
    interface Send as BareSend;
    interface Receive as BareReceive;
    interface Packet as BarePacket;

    interface Send    as ActiveSend;
    interface Receive as ActiveReceive;

    interface CC1200Packet;
    interface PacketAcknowledgements;
    interface LinkPacketMetadata;
    interface LowPowerListening;
    interface PacketLink;

  }
}
implementation {

  components CC1200CsmaC as CsmaC;
  components UniqueSendC;
  components UniqueReceiveC;
  components CC1200TinyosNetworkC;
  components CC1200PacketC;
  components CC1200ControlC;
  
#if defined(LOW_POWER_LISTENING) || defined(ACK_LOW_POWER_LISTENING)
  components DefaultLplC as LplC;
#else
  components DummyLplC as LplC;
#endif

#if defined(PACKET_LINK)
  components PacketLinkC as LinkC;
#else
  components PacketLinkDummyC as LinkC;
#endif
  
  PacketLink = LinkC;
  LowPowerListening = LplC;
  CC1200Packet = CC1200PacketC;
  PacketAcknowledgements = CC1200PacketC;
  LinkPacketMetadata = CC1200PacketC;
  
  Resource = CC1200TinyosNetworkC;
  BareSend = CC1200TinyosNetworkC.Send;
  BareReceive = CC1200TinyosNetworkC.Receive;
  BarePacket = CC1200TinyosNetworkC.BarePacket;
  
  ActiveSend = CC1200TinyosNetworkC.ActiveSend;
  ActiveReceive = CC1200TinyosNetworkC.ActiveReceive;

  // SplitControl Layers
  SplitControl = LplC;
  LplC.SubControl -> CsmaC;
  
  // Send Layers
  CC1200TinyosNetworkC.SubSend -> UniqueSendC;
  UniqueSendC.SubSend -> LinkC;
  LinkC.SubSend -> LplC.Send;
  LplC.SubSend -> CsmaC;
  
  // Receive Layers
  CC1200TinyosNetworkC.SubReceive -> LplC;
  LplC.SubReceive -> UniqueReceiveC.Receive;
  UniqueReceiveC.SubReceive ->  CsmaC;
  
}
