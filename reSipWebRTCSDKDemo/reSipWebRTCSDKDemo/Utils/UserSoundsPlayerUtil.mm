//
//  UserSoundsPlayer.m
//  VideoChat
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioSession.h>
#import <AVFoundation/AVAudioPlayer.h>

#import "CommonTypes.h"

#import "UserSoundsPlayerUtil.h"

static UserSoundsPlayerUtil* the_instance_ = nil;

@implementation UserSoundsPlayerUtil

@synthesize vibrateTimer;

+(UserSoundsPlayerUtil*)instance
{
    @synchronized(the_instance_)
    {
        if (!the_instance_) {
            the_instance_ = [[UserSoundsPlayerUtil alloc] init];
        }
        return the_instance_;
    }
}

-(void)playRinging{
    [self playSoundOfType:kRingingTone looping:
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000
     YES
#else
     NO
#endif
     ];
}

- (void)playCalling
{
    [self playSoundOfType:kCallingTone looping:
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000
     YES
#else
     NO
#endif
     ];
}


+(AVAudioPlayer*) initPlayerWithPath:(NSString*)path{
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], path]];
    
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error] ;
    if (player == nil){
        IVLog(@"Failed to create audio player(%@): %@", path, error);
    }
    
    return player;
}

- (BOOL)playSoundOfType:(int)type looping:(BOOL)looping
{
    BOOL speakerSwitch = YES;
    
    if(ringPlayer)
    {
        [ringPlayer stop];
        ringPlayer = nil;
    }
    
    if(!ringPlayer){
        NSString* soundname = nil;
        switch (type) {
            case kRingingTone:
                soundname = DEFAULT_RING_TONE;
                break;
            case kMessageTone:
                soundname = DEFAULT_MESSAGE_TONE;
                break;
            case kHoldTone:
                soundname = DEFAULT_HOLDEd_TONE;
                break;
            case kCallingTone:
                soundname = DEFAULT_CALLING_TONE;
                //speakerSwitch = NO;
                break;
            case kBackgroundCallTone:
                soundname = DEFAULT_RING_TONE_LONG;
            default:
                break;
        }
        if (!soundname) {
            return NO;
        }
        ringPlayer = [UserSoundsPlayerUtil initPlayerWithPath:soundname] ;
        
    }
    
    if(ringPlayer){
        
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
        UInt32 audioRouteOverride;
        if (speakerSwitch) {
            audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        }else {
            audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
        }
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
        ringPlayer.numberOfLoops = looping ? -1 : 0;
        [ringPlayer setMeteringEnabled:YES];
        [ringPlayer prepareToPlay];
        [ringPlayer play];
        
        return YES;
    }
    return NO;
}

- (void)playVibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (BOOL)playVibrate:(BOOL)looping
{
    if (self.vibrateTimer && self.vibrateTimer.isValid)
    {
        [vibrateTimer invalidate];
        self.vibrateTimer = nil;
    }

    self.vibrateTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(playVibrate) userInfo:nil repeats:looping];
    [vibrateTimer fire];
    return YES;
}

-(BOOL) stopSoundPlay
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.vibrateTimer && self.vibrateTimer.isValid)
    {
        [vibrateTimer invalidate];
        self.vibrateTimer = nil;
    }
    if(ringPlayer && ringPlayer.playing)
    {
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
        UInt32 audioRouteOverride = FALSE;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
        
        [ringPlayer stop];
    }
    return YES;
}

void completionCallback(SystemSoundID  ssID,
                        void* clientData)
{
    
}

- (void)playSound:(NSString*)filename {
    // Get the main bundle for the app
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    CFBundleRef mainBundle;
    SystemSoundID soundFileObject;
    CFURLRef soundFileURLRef;
    mainBundle = CFBundleGetMainBundle ();
    
    soundFileURLRef  = CFBundleCopyResourceURL(mainBundle,
                                               (CFStringRef)filename,
                                               CFSTR ("wav"),
                                               NULL
                                               );
    
    
    
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID (
                                      soundFileURLRef,
                                      &soundFileObject
                                      );
    // Add sound completion callback
    AudioServicesAddSystemSoundCompletion (soundFileObject, NULL, NULL,
                                           completionCallback,
                                           (__bridge void*) self);
    // Play the audio
    AudioServicesPlaySystemSound(soundFileObject);
    
    CFRelease(soundFileURLRef);
    //[self vibrate];
}

@end
