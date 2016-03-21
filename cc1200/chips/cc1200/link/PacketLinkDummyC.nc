 
configuration PacketLinkDummyC {
  provides {
    interface Send;
    interface PacketLink;
  }
  
  uses {
    interface Send as SubSend;
  }
}

implementation {
  components PacketLinkDummyP,
      CC1200RadioC;
  
  PacketLink = PacketLinkDummyP;
  Send = SubSend;
  
  PacketLinkDummyP.PacketAcknowledgements -> CC1200RadioC;
  
}

