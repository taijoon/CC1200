
#include <Timer.h>
#include <AM.h>
#include "CC1200TimeSyncMessage.h"

configuration CC1200TimeSyncMessageC
{
    provides
    {
        interface SplitControl;
        interface Receive[am_id_t id];
        interface Receive as Snoop[am_id_t id];
        interface Packet;
        interface AMPacket;
        interface PacketAcknowledgements;
        interface LowPowerListening;
    
        interface TimeSyncAMSend<T32khz, uint32_t> as TimeSyncAMSend32khz[am_id_t id];
        interface TimeSyncPacket<T32khz, uint32_t> as TimeSyncPacket32khz;

        interface TimeSyncAMSend<TMilli, uint32_t> as TimeSyncAMSendMilli[am_id_t id];
        interface TimeSyncPacket<TMilli, uint32_t> as TimeSyncPacketMilli;
    }
}

implementation
{
        components CC1200TimeSyncMessageP, CC1200ActiveMessageC, CC1200PacketC, LedsC;

        TimeSyncAMSend32khz = CC1200TimeSyncMessageP;
        TimeSyncPacket32khz = CC1200TimeSyncMessageP;

        TimeSyncAMSendMilli = CC1200TimeSyncMessageP;
        TimeSyncPacketMilli = CC1200TimeSyncMessageP;

        Packet = CC1200TimeSyncMessageP;
        // use the AMSenderC infrastructure to avoid concurrent send clashes
        components new AMSenderC(AM_TIMESYNCMSG);
        CC1200TimeSyncMessageP.SubSend -> AMSenderC;
      	CC1200TimeSyncMessageP.SubAMPacket -> AMSenderC;
        CC1200TimeSyncMessageP.SubPacket -> AMSenderC;

        CC1200TimeSyncMessageP.PacketTimeStamp32khz -> CC1200PacketC;
        CC1200TimeSyncMessageP.PacketTimeStampMilli -> CC1200PacketC;
        CC1200TimeSyncMessageP.PacketTimeSyncOffset -> CC1200PacketC;
        components Counter32khz32C, new CounterToLocalTimeC(T32khz) as LocalTime32khzC, LocalTimeMilliC;
        LocalTime32khzC.Counter -> Counter32khz32C;
        CC1200TimeSyncMessageP.LocalTime32khz -> LocalTime32khzC;
        CC1200TimeSyncMessageP.LocalTimeMilli -> LocalTimeMilliC;
        CC1200TimeSyncMessageP.Leds -> LedsC;

        components ActiveMessageC;
        SplitControl = CC1200ActiveMessageC;
        PacketAcknowledgements = CC1200ActiveMessageC;
        LowPowerListening = CC1200ActiveMessageC;
        
        Receive = CC1200TimeSyncMessageP.Receive;
        Snoop = CC1200TimeSyncMessageP.Snoop;
        AMPacket = CC1200TimeSyncMessageP;
        CC1200TimeSyncMessageP.SubReceive -> ActiveMessageC.Receive[AM_TIMESYNCMSG];
        CC1200TimeSyncMessageP.SubSnoop -> ActiveMessageC.Snoop[AM_TIMESYNCMSG];
}
