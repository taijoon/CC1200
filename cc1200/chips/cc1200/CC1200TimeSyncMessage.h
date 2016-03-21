
#ifndef __TIMESYNCMESSAGE_H__
#define __TIMESYNCMESSAGE_H__

#ifndef AM_TIMESYNCMSG
#define AM_TIMESYNCMSG 0x3D
#endif

// this value is sent in the air
typedef nx_uint32_t timesync_radio_t;

typedef nx_struct timesync_footer_t
{
	nx_am_id_t type;
  timesync_radio_t timestamp;
} timesync_footer_t;


#endif//__TIMESYNCMESSAGE_H__
