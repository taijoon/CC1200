
#warning "*** USING PACKET LINK LAYER"

configuration PacketLinkC {
  provides {
    interface Send;
    interface PacketLink;
  }
  
  uses {
    interface Send as SubSend;
  }
}

implementation {

  components PacketLinkP,
      CC1200PacketC,
      RandomC,
      new StateC() as SendStateC,
      new TimerMilliC() as DelayTimerC;
  
  PacketLink = PacketLinkP;
  Send = PacketLinkP.Send;
  SubSend = PacketLinkP.SubSend;
  
  PacketLinkP.SendState -> SendStateC;
  PacketLinkP.DelayTimer -> DelayTimerC;
  PacketLinkP.PacketAcknowledgements -> CC1200PacketC;
  PacketLinkP.CC1200PacketBody -> CC1200PacketC;

}
