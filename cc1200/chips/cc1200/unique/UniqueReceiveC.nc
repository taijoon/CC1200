 
configuration UniqueReceiveC {
  provides {
    interface Receive;
    interface Receive as DuplicateReceive;
  }
  
  uses {
    interface Receive as SubReceive;
  }
}

implementation {
  components UniqueReceiveP,
      CC1200PacketC,
      MainC;
  
  Receive = UniqueReceiveP.Receive;
  DuplicateReceive = UniqueReceiveP.DuplicateReceive;
  SubReceive = UniqueReceiveP.SubReceive;
      
  MainC.SoftwareInit -> UniqueReceiveP;
  
  UniqueReceiveP.CC1200PacketBody -> CC1200PacketC;
  
}

