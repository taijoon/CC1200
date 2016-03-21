
#include "message.h"

interface CC1200Receive {

  /**
   * Notification that an SFD capture has occured.
   *
   * @param time at which the capture happened.
   */
  async command void sfd( uint32_t time );

  /**
   * Notification that the packet has been dropped by the radio
   * (e.g. due to address rejection).
   */
  async command void sfd_dropped();

  /**
   * Signals that a message has been received.
   *
   * @param type of the message received.
   * @param message pointer to message received.
   */
  async event void receive( uint8_t type, message_t* ONE_NOK message );

}

