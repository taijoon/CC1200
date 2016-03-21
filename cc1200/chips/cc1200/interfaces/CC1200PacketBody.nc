interface CC1200PacketBody {

  /**
   * @return pointer to the cc1200_header_t of the given message
   */
  async command cc1200_header_t * ONE getHeader(message_t * ONE msg);


  /**
   * @return pointer to the payload region of the message, after any headers
   *    works with extended addressing mode
   */
  async command uint8_t * getPayload( message_t* msg);  
  /**
   * @return pointer to the cc1200_metadata_t of the given message
   */
  async command cc1200_metadata_t * ONE getMetadata(message_t * ONE msg);
  
}

