/*
 *  global_config.h
 *  MicroVoice
 *
 */

#define ENABLED_DEBUG 1
#define ENABLED_UI_DEBUG 1

#define DEFAULT_TURN_USERNAME "700"
#define DEFAULT_TURN_PASSWORD "700"

#define DEFAULT_STUN_SERVER "112.124.62.164:19302"
#define DEFAULT_TURN_SERVER "112.124.62.164:19302"

#define DEFAULT_SIP_PROFILE "main_profile"

#define DEFAULT_USERDB_NAME "user.db"
#define DEFAULT_USERPREFS_NAME "preferences.db"
#define DEFAULT_STUN_PORT 19302

#if defined(__arm64__)
#define PLATFORM_TYPE "64bit"
#else
#define PLATFORM_TYPE "32bit"
#endif

