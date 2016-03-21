 
configuration UniqueSendC {
  provides {
    interface Send;
  }
  
  uses {
    interface Send as SubSend;
  }
}

implementation {
  components UniqueSendP,
      new StateC(),
      RandomC,
      CC1200PacketC,
      MainC;
      
  Send = UniqueSendP.Send;
  SubSend = UniqueSendP.SubSend;
  
  MainC.SoftwareInit -> UniqueSendP;
  
  UniqueSendP.State -> StateC;
  UniqueSendP.Random -> RandomC;
  UniqueSendP.CC1200PacketBody -> CC1200PacketC;
  
}

