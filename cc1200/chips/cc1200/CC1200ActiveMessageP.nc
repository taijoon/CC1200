
#include <Ieee154.h> 
#include "CC1200.h"

module CC1200ActiveMessageP @safe() {
  provides {
    interface AMSend[am_id_t id];
    interface Receive[am_id_t id];
    interface Receive as Snoop[am_id_t id];
    interface AMPacket;
    interface Packet;
    interface SendNotifier[am_id_t id];
    interface RadioBackoff[am_id_t id];
  }
  
  uses {
    interface Send as SubSend;
    interface Receive as SubReceive;
    interface CC1200Packet;
    interface CC1200PacketBody;
    interface CC1200Config;
    interface ActiveMessageAddress;
    interface RadioBackoff as SubBackoff;

    interface Resource as RadioResource;
    interface Leds;
  }
}
implementation {
  uint16_t pending_length;
  message_t * ONE_NOK pending_message = NULL;
  /***************** Resource event  ****************/
  event void RadioResource.granted() {
    uint8_t rc;
    cc1200_header_t* header = call CC1200PacketBody.getHeader( pending_message );

    signal SendNotifier.aboutToSend[header->type](header->dest, pending_message);
    rc = call SubSend.send( pending_message, pending_length );
    if (rc != SUCCESS) {
      call RadioResource.release();
      signal AMSend.sendDone[header->type]( pending_message, rc );
    }
  }

  /***************** AMSend Commands ****************/
  command error_t AMSend.send[am_id_t id](am_addr_t addr,
					  message_t* msg,
					  uint8_t len) {
    cc1200_header_t* header = call CC1200PacketBody.getHeader( msg );
    
    if (len > call Packet.maxPayloadLength()) {
      return ESIZE;
    }
    
    header->type = id;
    header->dest = addr;
    header->destpan = call CC1200Config.getPanAddr();
    header->src = call AMPacket.address();
    header->fcf |= ( 1 << IEEE154_FCF_INTRAPAN ) |
      ( IEEE154_ADDR_SHORT << IEEE154_FCF_DEST_ADDR_MODE ) |
      ( IEEE154_ADDR_SHORT << IEEE154_FCF_SRC_ADDR_MODE ) ;
    header->length = len + CC1200_SIZE;
    
    //if (call RadioResource.immediateRequest() == SUCCESS) {
      //error_t rc = SUCCESS;
      //signal SendNotifier.aboutToSend[id](addr, msg);
      
      call SubSend.send( msg, len );
      return SUCCESS;
      //rc = call SubSend.send( msg, len );
      //if (rc != SUCCESS) {
        //call RadioResource.release();
      //}

      //return rc;
    //} else {
      //pending_length  = len;
      //pending_message = msg;
      //return call RadioResource.request();
    //}
  }

  command error_t AMSend.cancel[am_id_t id](message_t* msg) {
    return call SubSend.cancel(msg);
  }

  command uint8_t AMSend.maxPayloadLength[am_id_t id]() {
    return call Packet.maxPayloadLength();
  }

  command void* AMSend.getPayload[am_id_t id](message_t* m, uint8_t len) {
    return call Packet.getPayload(m, len);
  }

  /***************** AMPacket Commands ****************/
  command am_addr_t AMPacket.address() {
    return call ActiveMessageAddress.amAddress();
  }
 
  command am_addr_t AMPacket.destination(message_t* amsg) {
    cc1200_header_t* header = call CC1200PacketBody.getHeader(amsg);
    return header->dest;
  }
 
  command am_addr_t AMPacket.source(message_t* amsg) {
    cc1200_header_t* header = call CC1200PacketBody.getHeader(amsg);
    return header->src;
  }

  command void AMPacket.setDestination(message_t* amsg, am_addr_t addr) {
    cc1200_header_t* header = call CC1200PacketBody.getHeader(amsg);
    header->dest = addr;
  }

  command void AMPacket.setSource(message_t* amsg, am_addr_t addr) {
    cc1200_header_t* header = call CC1200PacketBody.getHeader(amsg);
    header->src = addr;
  }

  command bool AMPacket.isForMe(message_t* amsg) {
    return (call AMPacket.destination(amsg) == call AMPacket.address() ||
	    call AMPacket.destination(amsg) == AM_BROADCAST_ADDR);
  }

  command am_id_t AMPacket.type(message_t* amsg) {
    cc1200_header_t* header = call CC1200PacketBody.getHeader(amsg);
    return header->type;
  }

  command void AMPacket.setType(message_t* amsg, am_id_t type) {
    cc1200_header_t* header = call CC1200PacketBody.getHeader(amsg);
    header->type = type;
  }
  
  command am_group_t AMPacket.group(message_t* amsg) {
    return (call CC1200PacketBody.getHeader(amsg))->destpan;
  }

  command void AMPacket.setGroup(message_t* amsg, am_group_t grp) {
    // Overridden intentionally when we send()
    (call CC1200PacketBody.getHeader(amsg))->destpan = grp;
  }

  command am_group_t AMPacket.localGroup() {
    return call CC1200Config.getPanAddr();
  }
  

  /***************** Packet Commands ****************/
  command void Packet.clear(message_t* msg) {
    memset(call CC1200PacketBody.getHeader(msg), 0x0, sizeof(cc1200_header_t));
    memset(call CC1200PacketBody.getMetadata(msg), 0x0, sizeof(cc1200_metadata_t));
  }
  
  command uint8_t Packet.payloadLength(message_t* msg) {
    return (call CC1200PacketBody.getHeader(msg))->length - CC1200_SIZE;
  }
  
  command void Packet.setPayloadLength(message_t* msg, uint8_t len) {
    (call CC1200PacketBody.getHeader(msg))->length  = len + CC1200_SIZE;
  }
  
  command uint8_t Packet.maxPayloadLength() {
    return call SubSend.maxPayloadLength();
  }
  
  command void* Packet.getPayload(message_t* msg, uint8_t len) {
    return call SubSend.getPayload(msg, len);
  }

  
  /***************** SubSend Events ****************/
  event void SubSend.sendDone(message_t* msg, error_t result) {
    call RadioResource.release();
    signal AMSend.sendDone[call AMPacket.type(msg)](msg, result);
  }

  
  /***************** SubReceive Events ****************/
  event message_t* SubReceive.receive(message_t* msg, void* payload, uint8_t len) {
    
    if (call AMPacket.isForMe(msg)) {
      return signal Receive.receive[call AMPacket.type(msg)](msg, payload, len);
    }
    else {
      return signal Snoop.receive[call AMPacket.type(msg)](msg, payload, len);
    }
  }
  

  /***************** ActiveMessageAddress Events ****************/
  async event void ActiveMessageAddress.changed() {
  }
  
  /***************** CC1200Config Events ****************/
  event void CC1200Config.syncDone( error_t error ) {
  }
  
  
  /***************** RadioBackoff ***********************/

  async event void SubBackoff.requestInitialBackoff(message_t *msg) {
    signal RadioBackoff.requestInitialBackoff[(TCAST(cc1200_header_t* ONE,
        (uint8_t*)msg + offsetof(message_t, data) - sizeof(cc1200_header_t)))->type](msg);
  }

  async event void SubBackoff.requestCongestionBackoff(message_t *msg) {
    signal RadioBackoff.requestCongestionBackoff[(TCAST(cc1200_header_t* ONE,
        (uint8_t*)msg + offsetof(message_t, data) - sizeof(cc1200_header_t)))->type](msg);
  }
  async event void SubBackoff.requestCca(message_t *msg) {
    // Lower layers than this do not configure the CCA settings
    signal RadioBackoff.requestCca[(TCAST(cc1200_header_t* ONE,
        (uint8_t*)msg + offsetof(message_t, data) - sizeof(cc1200_header_t)))->type](msg);
  }

  async command void RadioBackoff.setInitialBackoff[am_id_t amId](uint16_t backoffTime) {
    call SubBackoff.setInitialBackoff(backoffTime);
  }
  
  /**
   * Must be called within a requestCongestionBackoff event
   * @param backoffTime the amount of time in some unspecified units to backoff
   */
  async command void RadioBackoff.setCongestionBackoff[am_id_t amId](uint16_t backoffTime) {
    call SubBackoff.setCongestionBackoff(backoffTime);
  }

      
  /**
   * Enable CCA for the outbound packet.  Must be called within a requestCca
   * event
   * @param ccaOn TRUE to enable CCA, which is the default.
   */
  async command void RadioBackoff.setCca[am_id_t amId](bool useCca) {
    call SubBackoff.setCca(useCca);
  }
  
  /***************** Defaults ****************/
  default event message_t* Receive.receive[am_id_t id](message_t* msg, void* payload, uint8_t len) {
    return msg;
  }
  
  default event message_t* Snoop.receive[am_id_t id](message_t* msg, void* payload, uint8_t len) {
    return msg;
  }

  default event void AMSend.sendDone[uint8_t id](message_t* msg, error_t err) {
    call RadioResource.release();
  }

  default event void SendNotifier.aboutToSend[am_id_t amId](am_addr_t addr, message_t *msg) {
  }
  default async event void RadioBackoff.requestInitialBackoff[am_id_t id](
      message_t *msg) {
  }

  default async event void RadioBackoff.requestCongestionBackoff[am_id_t id](
      message_t *msg) {
  }
  
  default async event void RadioBackoff.requestCca[am_id_t id](
      message_t *msg) {
  }
  
}
