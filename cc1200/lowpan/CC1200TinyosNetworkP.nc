
#include "CC1200.h"
#include "Ieee154.h"

module CC1200TinyosNetworkP @safe() {
  provides {
    interface Resource[uint8_t client];

    interface Send as BareSend;
    interface Receive as BareReceive;

    interface Send as ActiveSend;
    interface Receive as ActiveReceive;

    interface Packet as BarePacket;
  }
  
  uses {
    interface Send as SubSend;
    interface Receive as SubReceive;
    interface CC1200Packet;
    interface CC1200PacketBody;
    interface ResourceQueue as Queue;
  }
}

implementation {

  enum {
    OWNER_NONE = 0xff,
    TINYOS_N_NETWORKS = uniqueCount("RADIO_SEND_RESOURCE"),
  } state;

  enum {
    CLIENT_AM,
    CLIENT_BARE,
  } m_busy_client;

  norace uint8_t resource_owner = OWNER_NONE, next_owner;

  command error_t ActiveSend.send(message_t* msg, uint8_t len) {
    call CC1200Packet.setNetwork(msg, TINYOS_6LOWPAN_NETWORK_ID);
    m_busy_client = CLIENT_AM;
    return call SubSend.send(msg, len);
  }

  command error_t ActiveSend.cancel(message_t* msg) {
    return call SubSend.cancel(msg);
  }

  command uint8_t ActiveSend.maxPayloadLength() {
    return call SubSend.maxPayloadLength();
  }

  command void* ActiveSend.getPayload(message_t* msg, uint8_t len) {
    if (len <= call ActiveSend.maxPayloadLength()) {
      return msg->data;
    } else {
      return NULL;
    }
  }
  /***************** BarePacket Commands ****************/
  command void BarePacket.clear(message_t *msg) {
    memset(msg, 0, sizeof(message_t));
  }

  command uint8_t BarePacket.payloadLength(message_t *msg) {
    cc1200_header_t *hdr = call CC1200PacketBody.getHeader(msg);
    return hdr->length + 1 - MAC_FOOTER_SIZE;
  }

  command void BarePacket.setPayloadLength(message_t* msg, uint8_t len) {
    cc1200_header_t *hdr = call CC1200PacketBody.getHeader(msg);
    hdr->length = len - 1 + MAC_FOOTER_SIZE;
  }

  command uint8_t BarePacket.maxPayloadLength() {
    return TOSH_DATA_LENGTH + sizeof(cc1200_header_t);
  }

  command void* BarePacket.getPayload(message_t* msg, uint8_t len) {

  }
  /***************** Send Commands ****************/
  command error_t BareSend.send(message_t* msg, uint8_t len) {
    call BarePacket.setPayloadLength(msg, len);
    m_busy_client = CLIENT_BARE;
    return call SubSend.send(msg, 0);
  }

  command error_t BareSend.cancel(message_t* msg) {
    return call SubSend.cancel(msg);
  }

  command uint8_t BareSend.maxPayloadLength() {
    return call BarePacket.maxPayloadLength();
  }

  command void* BareSend.getPayload(message_t* msg, uint8_t len) {
#ifndef TFRAMES_ENABLED                      
    cc1200_header_t *hdr = call CC1200PacketBody.getHeader(msg);
    return hdr;
#else
    // you really can't use BareSend with TFRAMES
#endif
  }
  
  /***************** SubSend Events *****************/
  event void SubSend.sendDone(message_t* msg, error_t error) {
    if (m_busy_client == CLIENT_AM) {
      signal ActiveSend.sendDone(msg, error);
    } else {
      signal BareSend.sendDone(msg, error);
    }
  }

  /***************** SubReceive Events ***************/
  event message_t *SubReceive.receive(message_t *msg, void *payload, uint8_t len) {
    uint8_t network = call CC1200Packet.getNetwork(msg);

    if(!(call CC1200PacketBody.getMetadata(msg))->crc) {
      return msg;
    }
#ifndef TFRAMES_ENABLED
    if (network == TINYOS_6LOWPAN_NETWORK_ID) {
      return signal ActiveReceive.receive(msg, payload, len);
    } else {
      return signal BareReceive.receive(msg, 
                                        call BareSend.getPayload(msg, len), 
                                        len + sizeof(cc1200_header_t));
    }
#else
    return signal ActiveReceive.receive(msg, payload, len);
#endif
  }

  /***************** Resource ****************/
  // SDH : 8-7-2009 : testing if there's more then one client allows
  // the compiler to eliminate most of the logic when there's only one
  // client.
  task void grantTask() {


    if (TINYOS_N_NETWORKS > 1) {
      if (resource_owner == OWNER_NONE && !(call Queue.isEmpty())) {
        resource_owner = call Queue.dequeue();

        if (resource_owner != OWNER_NONE) {
          signal Resource.granted[resource_owner]();
        }
      }
    } else {
      if (next_owner != resource_owner) {
        resource_owner = next_owner;
        signal Resource.granted[resource_owner]();
      }
    }
  }

  async command error_t Resource.request[uint8_t id]() {

    post grantTask();

    if (TINYOS_N_NETWORKS > 1) {
      return call Queue.enqueue(id);
    } else {
      if (id == resource_owner) {
        return EALREADY;
      } else {
        next_owner = id;
        return SUCCESS;
      }
    }
  }

  async command error_t Resource.immediateRequest[uint8_t id]() {
    if (resource_owner == id) return EALREADY;

    if (TINYOS_N_NETWORKS > 1) {
      if (resource_owner == OWNER_NONE && call Queue.isEmpty()) {
        resource_owner = id;
        return SUCCESS;
      }
      return FAIL;
    } else {
      resource_owner = id;
      return SUCCESS;
    }
  }
  async command error_t Resource.release[uint8_t id]() {
    if (TINYOS_N_NETWORKS > 1) {
      post grantTask();
    }
    resource_owner = OWNER_NONE;
    return SUCCESS;
  }
  async command bool Resource.isOwner[uint8_t id]() {
    return (id == resource_owner);
  }

  /***************** Defaults ****************/
  default event message_t *BareReceive.receive(message_t *msg, void *payload, uint8_t len) {
    return msg;
  }
  default event void BareSend.sendDone(message_t *msg, error_t error) {

  }
  default event message_t *ActiveReceive.receive(message_t *msg, void *payload, uint8_t len) {
    return msg;
  }
  default event void ActiveSend.sendDone(message_t *msg, error_t error) {

  }
  default event void Resource.granted[uint8_t client]() {
    call Resource.release[client]();
  }

}
