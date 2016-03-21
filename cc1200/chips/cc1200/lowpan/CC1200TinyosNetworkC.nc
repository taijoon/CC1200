 
#include "CC1200.h"
#include "Ieee154.h"

configuration CC1200TinyosNetworkC {
  provides {
    interface Resource[uint8_t clientId];
    interface Send;
    interface Receive;

    interface Send as ActiveSend;
    interface Receive as ActiveReceive;

    interface Packet as BarePacket;
  }
  
  uses {
    interface Receive as SubReceive;
    interface Send as SubSend;
  }
}

implementation {

  enum {
    TINYOS_N_NETWORKS = uniqueCount(RADIO_SEND_RESOURCE),
  };

  components MainC;
  components CC1200TinyosNetworkP;
  components CC1200PacketC;
  components new FcfsResourceQueueC(TINYOS_N_NETWORKS);

  CC1200TinyosNetworkP.BareSend = Send;
  CC1200TinyosNetworkP.BareReceive = Receive;
  CC1200TinyosNetworkP.BarePacket = BarePacket;
  CC1200TinyosNetworkP.SubSend = SubSend;
  CC1200TinyosNetworkP.SubReceive = SubReceive;
  CC1200TinyosNetworkP.Resource = Resource;
  CC1200TinyosNetworkP.ActiveSend = ActiveSend;
  CC1200TinyosNetworkP.ActiveReceive = ActiveReceive;

  CC1200TinyosNetworkP.CC1200Packet -> CC1200PacketC;
  CC1200TinyosNetworkP.CC1200PacketBody -> CC1200PacketC;
  CC1200TinyosNetworkP.Queue -> FcfsResourceQueueC;

  MainC.SoftwareInit -> FcfsResourceQueueC;
}

