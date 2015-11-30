 
#include "CC1200.h"
#include "IEEE802154.h"

module CC1200Ieee154MessageP {

  provides {
    interface Ieee154Send;
    interface Receive as Ieee154Receive;
    interface Ieee154Packet;
    interface Packet;
  }
  
  uses {
    interface Send as SubSend;
    interface Receive as SubReceive;
    interface CC1200Packet;
    interface CC1200PacketBody;
    interface CC1200Config;
#ifdef CC1200_IEEE154_RESOURCE_SEND
    interface Resource;
#endif
  }
}
implementation {
  message_t *m_pending_msg;
  enum {
    EXTRA_OVERHEAD = sizeof(cc1200_header_t) - offsetof(cc1200_header_t, network),
  };

  /***************** Ieee154Send Commands ****************/
  command error_t Ieee154Send.send(ieee154_saddr_t addr,
                                   message_t* msg,
                                   uint8_t len) {
    cc1200_header_t* header = call CC1200PacketBody.getHeader( msg );

    header->length = len + CC1200_SIZE - EXTRA_OVERHEAD;
    header->dest = addr;
    header->destpan = call CC1200Config.getPanAddr();
    header->src = call CC1200Config.getShortAddr();
    header->fcf = ( 1 << IEEE154_FCF_INTRAPAN ) |
      ( IEEE154_ADDR_SHORT << IEEE154_FCF_DEST_ADDR_MODE ) |
      ( IEEE154_ADDR_SHORT << IEEE154_FCF_SRC_ADDR_MODE ) ;

#ifdef CC1200_IEEE154_RESOURCE_SEND
    if (call Resource.isOwner())
      return EBUSY;

    if (call Resource.immediateRequest() == SUCCESS) {
      error_t rc;
      rc = call SubSend.send( msg, header->length - 1 );
      if (rc != SUCCESS) {
        call Resource.release();
      }
      return rc;
    } else {
      m_pending_msg = msg;
      return call Resource.request();
    }
#else
    return call SubSend.send( msg, header->length - 1 );
#endif
  }

#ifdef CC1200_IEEE154_RESOURCE_SEND
  event void Resource.granted() {
    error_t rc;
    cc1200_header_t* header = call CC1200PacketBody.getHeader( m_pending_msg );
    rc = call SubSend.send(m_pending_msg, header->length - 1);
    if (rc != SUCCESS) {
      call Resource.release();
      signal Ieee154Send.sendDone(m_pending_msg, rc);
    }
  }
#endif

  command error_t Ieee154Send.cancel(message_t* msg) {
    return call SubSend.cancel(msg);
  }

  command uint8_t Ieee154Send.maxPayloadLength() {
    return call Packet.maxPayloadLength();
  }

  command void* Ieee154Send.getPayload(message_t* m, uint8_t len) {
    return call Packet.getPayload(m, len);
  }

  event message_t *SubReceive.receive(message_t *msg, void *payload, uint8_t len) {
    return signal Ieee154Receive.receive(msg,
                                         call Packet.getPayload(msg, 0),
                                         call Packet.payloadLength(msg));
  }

  /***************** Ieee154Packet Commands ****************/
  command ieee154_saddr_t Ieee154Packet.address() {
    return call CC1200Config.getShortAddr();
  }
 
  command ieee154_saddr_t Ieee154Packet.destination(message_t* msg) {
    cc1200_header_t* header = call CC1200PacketBody.getHeader(msg);
    return header->dest;
  }
 
  command ieee154_saddr_t Ieee154Packet.source(message_t* msg) {
    cc1200_header_t* header = call CC1200PacketBody.getHeader(msg);
    return header->src;
  }

  command void Ieee154Packet.setDestination(message_t* msg, ieee154_saddr_t addr) {
    cc1200_header_t* header = call CC1200PacketBody.getHeader(msg);
    header->dest = addr;
  }

  command void Ieee154Packet.setSource(message_t* msg, ieee154_saddr_t addr) {
    cc1200_header_t* header = call CC1200PacketBody.getHeader(msg);
    header->src = addr;
  }

  command bool Ieee154Packet.isForMe(message_t* msg) {
    return (call Ieee154Packet.destination(msg) == call Ieee154Packet.address() ||
	    call Ieee154Packet.destination(msg) == IEEE154_BROADCAST_ADDR);
  }

  command ieee154_panid_t Ieee154Packet.pan(message_t* msg) {
    return (call CC1200PacketBody.getHeader(msg))->destpan;
  }

  command void Ieee154Packet.setPan(message_t* msg, ieee154_panid_t grp) {
    // Overridden intentionally when we send()
    (call CC1200PacketBody.getHeader(msg))->destpan = grp;
  }

  command ieee154_panid_t Ieee154Packet.localPan() {
    return call CC1200Config.getPanAddr();
  }


  /***************** Packet Commands ****************/
  command void Packet.clear(message_t* msg) {
    memset(call CC1200PacketBody.getHeader(msg), sizeof(cc1200_header_t) - EXTRA_OVERHEAD, 0);
    memset(call CC1200PacketBody.getMetadata(msg), sizeof(cc1200_metadata_t), 0);
  }
  
  command uint8_t Packet.payloadLength(message_t* msg) {
    return (call CC1200PacketBody.getHeader(msg))->length - CC1200_SIZE + EXTRA_OVERHEAD;
  }
  
  command void Packet.setPayloadLength(message_t* msg, uint8_t len) {
    (call CC1200PacketBody.getHeader(msg))->length  = len + CC1200_SIZE - EXTRA_OVERHEAD;
  }
  
  command uint8_t Packet.maxPayloadLength() {
    return TOSH_DATA_LENGTH + EXTRA_OVERHEAD;
  }
  
  command void* Packet.getPayload(message_t* msg, uint8_t len) {
    return msg->data - EXTRA_OVERHEAD;
  }

  
  /***************** SubSend Events ****************/
  event void SubSend.sendDone(message_t* msg, error_t result) {
#ifdef CC1200_IEEE154_RESOURCE_SEND
    call Resource.release();
#endif
    signal Ieee154Send.sendDone(msg, result);
  }

  /***************** CC1200Config Events ****************/
  event void CC1200Config.syncDone( error_t error ) {
  }

  default event void Ieee154Send.sendDone(message_t *msg, error_t e) {

  }
}
