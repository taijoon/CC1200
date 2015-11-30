
#include "CC1200.h"
#include "IEEE802154.h"

configuration CC1200CsmaC {

  provides interface SplitControl;
  provides interface Send;
  provides interface Receive;
  provides interface RadioBackoff;

}

implementation {

  components CC1200CsmaP as CsmaP;
  RadioBackoff = CsmaP;
  SplitControl = CsmaP;
  Send = CsmaP;
  
  components CC1200ControlC;
  CsmaP.Resource -> CC1200ControlC;
  CsmaP.CC1200Power -> CC1200ControlC;

  components CC1200TransmitC;
  CsmaP.SubControl -> CC1200TransmitC;
  CsmaP.CC1200Transmit -> CC1200TransmitC;
  CsmaP.SubBackoff -> CC1200TransmitC;

  components CC1200ReceiveC;
  Receive = CC1200ReceiveC;
  CsmaP.SubControl -> CC1200ReceiveC;

  components CC1200PacketC;
  CsmaP.CC1200Packet -> CC1200PacketC;
  CsmaP.CC1200PacketBody -> CC1200PacketC;
  
  components RandomC;
  CsmaP.Random -> RandomC;

  components new StateC();
  CsmaP.SplitControlState -> StateC;
  
  components LedsC as Leds;
  CsmaP.Leds -> Leds;
  
}
