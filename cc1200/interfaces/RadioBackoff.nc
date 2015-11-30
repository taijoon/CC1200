 
interface RadioBackoff {

  /**
   * Must be called within a requestInitialBackoff event
   * @param backoffTime the amount of time in some unspecified units to backoff
   */
  async command void setInitialBackoff(uint16_t backoffTime);
  
  /**
   * Must be called within a requestCongestionBackoff event
   * @param backoffTime the amount of time in some unspecified units to backoff
   */
  async command void setCongestionBackoff(uint16_t backoffTime);
  
  /**
   * Enable CCA for the outbound packet.  Must be called within a requestCca
   * event
   * @param ccaOn TRUE to enable CCA, which is the default.
   */
  async command void setCca(bool ccaOn);


  /**  
   * Request for input on the initial backoff
   * Reply using setInitialBackoff(..)
   * @param msg pointer to the message being sent
   */
  async event void requestInitialBackoff(message_t * ONE msg);
  
  /**
   * Request for input on the congestion backoff
   * Reply using setCongestionBackoff(..)
   * @param msg pointer to the message being sent
   */
  async event void requestCongestionBackoff(message_t * ONE msg);
  
  /**
   * Request for input on whether or not to use CCA on the outbound packet.
   * Replies should come in the form of setCca(..)
   * @param msg pointer to the message being sent
   */
  async event void requestCca(message_t * ONE msg);
}

