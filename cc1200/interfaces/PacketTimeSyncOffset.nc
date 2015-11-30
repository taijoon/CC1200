
interface PacketTimeSyncOffset
{
    /**
     * @param 'message_t *ONE msg' message to examine.
     *
     * Returns TRUE if the current message should be timestamped.
     */
    async command bool isSet(message_t* msg);

    /**
     * @param 'message_t *ONE msg' message to examine.
     *
     * Returns the offset of where the timesync timestamp is sotred in a
     * CC1200 packet
     */
    async command uint8_t get(message_t* msg);

    /**
     * @param 'message_t *ONE msg' message to modify.
     *
     *  Sets the current message to be timestamped in the MAC layer.
     */
    async command void set(message_t* msg);

    /**
     * @param 'message_t *ONE msg' message to modify.
     *
     * Cancels any pending requests to timestamp the message in MAC.
     */
    async command void cancel(message_t* msg);
}
