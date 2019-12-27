//
//  CommonTypes.h
//  VideoChat
//

#ifndef VideoChat_CommonTypes_h
#define VideoChat_CommonTypes_h

#import "global_config.h"
#import <objc/NSObject.h>

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]


#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)) : NO)

#define iPhone6plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define contactHeadBlueColor RGBCOLOR(14,108,230)
#define buttonBlueColor RGBCOLOR(14,105,224)
#define voiceCallBackGroundBlueColor RGBCOLOR(13,93,195)
#define buttonGreenColor RGBCOLOR(41,210,63)
#define buttonRedColor RGBCOLOR(246,34,59)
#define kContactsCellHeight 50.0f
#define kRecentCellHeight 50.0f
#define kMarginVertical 17

#define kDefaultButtonPadding (iPhone4? 10 : 16)
#define kCleanActionButtonSize  (iPhone4? 32 : 42)
#define kDefaultButtonSize (iPhone4? 64 : 74)
#define kActionButtonSize 48
#define kLocalVideoViewWidth  90
#define kLocalVideoViewHeight  120
#define kLocalVideoViewPadding  12
#define kContactHeadButtonSize (kDefaultButtonSize * 1.5)
#define kNumberOfPages 2

#define ACTION_HANGUP  1101
#define ACTION_MUTE 1102
#define ACTION_SWITCH_CAMERA 1103
#define ACTION_VOICE_ANSWER  1104
#define ACTION_VIDEO_ANSWER  1105
#define ACTION_SWITCH_SPEAKER 1106
#define ACTION_SWITCH_CAMERA_OFF 1107
#define ACTION_SELECT_CONTACTS 1108
#define ACTION_KEYBOARD_HIDDEN 1109
#define ACTION_KEYBOARD_SHOW 1110

#define ACTION_ADD_CONTACT 100
#define ACTION_DEL_NUNMBER 101
#define ACTION_MAKE_AUDIO_CALL 13
#define ACTION_MAKE_VIDEO_CALL 14
#define ACTION_MAKE_GSM_CALL 15
#define ACTION_MAKE_SMS 16

#define DEFAULT_RING_TONE_LONG  @"ringtone_long.wav"
#define DEFAULT_RING_TONE       @"ringtone.wav"
#define DEFAULT_MESSAGE_TONE    @"message.wav"
#define DEFAULT_HOLDEd_TONE     @"hold_tone.wav"
#define DEFAULT_CALLING_TONE    @"outbound_ringback_tone.wav"

#define KNotificationOutgoingCall @"KNotificationOutgoingCall"

#define IVLog(format, ...)  NSLog((@"%@" format), @"UI | ", ##__VA_ARGS__)

@interface DeviceManager : NSObject 
+(NSString *)getDeviceVersion;
+(NSString *)getPlatformString;
@end

#endif
