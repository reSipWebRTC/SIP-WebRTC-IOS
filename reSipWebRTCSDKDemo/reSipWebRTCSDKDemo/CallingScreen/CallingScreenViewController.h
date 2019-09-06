//
//  CallingScreenViewController.h
//  VideoChat
//

#import <UIKit/UIKit.h>
#import "ARDVideoCallView.h"
#import <WebRTC/RTCLogging.h>
#import <WebRTC/RTCVideoTrack.h>
#import "Call.h"

@class RTCVideoRendererAdapter;

@interface VideoRenderIosView : UIView
@end

@interface CallingScreenViewController : UIViewController
{
    BOOL useFrontFaceingCamera;
    NSTimer *vid_img_timer;
    int remote_video_width;
    int remote_video_height;
    Call *current_call_;
    
    enum ARDVideoCallingMode mode_;
    BOOL in_calling_;
}

-(void)setCurrentCall:(Call *) call;

-(BOOL)isVideoCalling:(Call *) call;

-(void)setCallingStatusLabel:(NSString *)text;

-(void)setCallingMode:(enum ARDVideoCallingMode)mode;

-(void)stopCallingUI;

- (void)startVideo;

- (void)stopVideo;

- (void)pauseVideoCall;

- (void)resumeVideoCall;

+ (CallingScreenViewController*)instance;

@property (retain, nonatomic) NSDate* startDate;
@end
