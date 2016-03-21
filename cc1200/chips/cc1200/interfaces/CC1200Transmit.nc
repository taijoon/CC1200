
#include "message.h"

interface CC1200Transmit {

  /**
   * Send a message
   *
   * @param p_msg message to send.
   * @param useCca TRUE if this Tx should use clear channel assessments
   * @return SUCCESS if the request was accepted, FAIL otherwise.
   */
  async command error_t send( message_t* ONE p_msg, bool useCca );

  /**
   * Send the previous message again
   * @param useCca TRUE if this re-Tx should use clear channel assessments
   * @return SUCCESS if the request was accepted, FAIL otherwise.
   */
  async command error_t resend(bool useCca);

  /**
   * Cancel sending of the message.
   *
   * @return SUCCESS if the request was accepted, FAIL otherwise.
   */
  async command error_t cancel();

  /**
   * Signal that a message has been sent
   *
   * @param p_msg message to send.
   * @param error notifaction of how the operation went.
   */
  async event void sendDone( message_t* ONE_NOK p_msg, error_t error );

  /**
   * Modify the contents of a packet. This command can only be used
   * when an SFD capture event for the sending packet is signalled.
   *
   * @param offset in the message to start modifying.
   * @param buf to data to write
   * @param len of bytes to write
   * @return SUCCESS if the request was accepted, FAIL otherwise.
   */
  async command error_t modify( uint8_t offset, uint8_t* COUNT_NOK(len) buf, uint8_t len );

}

