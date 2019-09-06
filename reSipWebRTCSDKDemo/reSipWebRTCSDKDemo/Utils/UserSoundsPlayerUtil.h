//
//  UserSoundsPlayer.h
//  VideoChat
//

#import <Foundation/Foundation.h>

/*
 type:
 0：通话
 1：短信
 2：通话被保持
 3：呼叫中
 4：通知通话
 */
typedef enum
{
    kRingingTone,
    kMessageTone,
    kHoldTone,
    kCallingTone,
    kBackgroundCallTone,
} RingTones;

@interface UserSoundsPlayerUtil : NSObject
{
    AVAudioPlayer *ringPlayer;
}

+(UserSoundsPlayerUtil*)instance;

@property (retain, nonatomic) NSTimer* vibrateTimer;

-(void)playRinging;

-(void)playCalling;

-(BOOL)stopSoundPlay;

-(BOOL)playSoundOfType:(int)type looping:(BOOL)looping;

-(BOOL)playVibrate:(BOOL)looping;

-(void)playSound:(NSString*)filename;

@end
