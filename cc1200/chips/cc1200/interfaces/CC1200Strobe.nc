
#include "CC1200.h"

interface CC1200Strobe {

  /**
   * Send a command strobe to the register. The return value is the
   * CC1200 status register. Table 5 on page 27 of the CC1200
   * datasheet (v1.2) describes the contents of this register.
   * 
   * @return Status byte from the CC1200.
   */
  async command cc1200_status_t strobe();

}
