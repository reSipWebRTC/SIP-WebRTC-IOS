//
//  SipEngineManager.m
//  MicroVoice
//
//
#import "CommonTypes.h"

#import "SipEngineManager.h"
#import "sip_engine_types.hxx"

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <time.h>
#include <netdb.h>
#include <stdio.h>

#include "global_config.h"

static SipEngineManager* theSipEngineManager=nil;
static bool NetworkReachable = false;
static webrtc::rtcConfig rtc_config;
static VideoSize_t s_video_size = { 640, 480};
static float s_bitrate = 512.0;
static int s_fps = 15;

void networkReachabilityCallBack(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void * info)
{
	IVLog(@"Network connection flag [%x]",flags);
	
	SipEngineManager* lSipEngineMgr = (__bridge SipEngineManager*)info;
	SCNetworkReachabilityFlags networkDownFlags=kSCNetworkReachabilityFlagsConnectionRequired |kSCNetworkReachabilityFlagsConnectionOnTraffic | kSCNetworkReachabilityFlagsConnectionOnDemand;
    
	/*if ([[SipEngineManager instance] getSipEngine] != nil)
    {
		if ((flags == 0) | (flags & networkDownFlags)) {
			[[SipEngineManager instance] kickOffNetworkConnection];
			((__bridge SipEngineManager*)info)->connectivity = none;
            
            [[SipEngineManager instance] getRegistrationManager]->SetNetworkReachable(false);
            
            NetworkReachable = NO;
            IVLog(@"Network connectivity [DOWN] !");
		} else
        {
			Connectivity  newConnectivity = flags & kSCNetworkReachabilityFlagsIsWWAN ? wwan:wifi;
			if (lSipEngineMgr->connectivity == none) {
                //connectivity changed from none
                [[SipEngineManager instance] getRegistrationManager]->SetNetworkReachable(false);
                [[SipEngineManager instance] getRegistrationManager]->SetNetworkReachable(true);
                //TODO: 第一次设置网络可用，通知注册器启动所有账号注册
                IVLog(@"Network connectivity [UP] !");
                NetworkReachable = YES;
			} else if (lSipEngineMgr->connectivity != newConnectivity) {
                // connectivity has changed, need to foce register
                [[SipEngineManager instance] getRegistrationManager]->SetNetworkReachable(false);
                [[SipEngineManager instance] getRegistrationManager]->SetNetworkReachable(true);
                
                //TODO: 网络切换销毁所有旧注册，以及网络连接，重新注册所有账号
                NetworkReachable = YES;
                IVLog(@"Network connectivity now [Changed] !");
            }

            lSipEngineMgr->connectivity=newConnectivity;
            IVLog(@"New network connectivity  of type [%s]",(newConnectivity==wifi?"wifi":"wwan"));
		}
	}*/
}

@implementation SipEngineManager

@synthesize callDelegate;
@synthesize registrationDelegate;
@synthesize videoFrameInfoDelegate;

- (NSString*)machine
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char* name = (char*)malloc(size);
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    NSString* machine = [[NSString alloc] initWithUTF8String:name];
    free(name);
    
    return machine;
}

- (id)init
{
    if ((self = [super init])) {
    }
    sip_engine_ = nil;
    //event_observer_ = nil;
    current_call_ = nil;
    isInitialized = NO;
    return self;
}

- (BOOL)NetworkIsReachable
{
    return NetworkReachable;
}

- (VideoSize_t *)getVideoSize
{
    return  &s_video_size;
}

- (float)getBitrate
{
    return s_bitrate;
}

- (float)getFrameRate
{
    return s_fps;
}

- (BOOL)InCalling
{
    /*if(sip_engine_)
    {
        client::CallManager *call_manager = sip_engine_->GetCallManager();
        client::CallMap call_map;
        call_manager->GetCallMap(call_map);
        if(call_map.size() > 0)
        {
            client::Call* call = call_map.begin()->second;
            if(call->call_state() == client::kAnswered)
            {
                return YES;
            }
        }
    }*/

    return  NO;
}

- (Call *)getIncomingCall
{
    /*if(sip_engine_)
    {
        client::CallManager *call_manager = sip_engine_->GetCallManager();
        client::CallMap call_map;
        call_manager->GetCallMap(call_map);
        if(call_map.size() > 0)
        {
            client::Call* call = call_map.begin()->second;
            if(call->direction() == client::kIncoming
               && (call->call_state() == client::kNewCall || call->call_state() == client::kRinging))
            {
                return call;
            }
        }
    }*/
    
    return  NULL;
}

- (BOOL)HaveIncomingCall
{
    /*if(sip_engine_)
    {
        client::CallManager *call_manager = sip_engine_->GetCallManager();
        client::CallMap call_map;
        call_manager->GetCallMap(call_map);
        if(call_map.size() > 0)
        {
            client::Call* call = call_map.begin()->second;
            if(call->direction() == client::kIncoming
               && (call->call_state() == client::kNewCall || call->call_state() == client::kRinging))
            {
                return YES;
            }
        }
    }*/
    
    return  NO;
}

- (void)AnswerIncomingCall
{
    /*if(sip_engine_)
    {
        client::CallManager *call_manager = sip_engine_->GetCallManager();
        client::CallMap call_map;
        call_manager->GetCallMap(call_map);
        if(call_map.size() > 0)
        {
            client::Call* call = call_map.begin()->second;
            if(call->direction() == client::kIncoming && call->call_state() != client::kAnswered)
            {
                call->Accept();
            }
        }
    }*/
}

/*设置网络状态监听代理*/
- (void)setProxyReachability{
    
    const char *nodeName="8.8.8.8";
    
    if (proxyReachability) {
        IVLog(@"Cancelling old network reachability");
        SCNetworkReachabilityUnscheduleFromRunLoop(proxyReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFRelease(proxyReachability);
        proxyReachability = nil;
    }
    
    proxyReachability=SCNetworkReachabilityCreateWithName(nil, nodeName);		
    proxyReachabilityContext.info=(__bridge void *)self;
    //initial state is network off should be done as soon as possible
    SCNetworkReachabilityFlags flags;
    if (!SCNetworkReachabilityGetFlags(proxyReachability, &flags)) {
        IVLog(@"Cannot get reachability flags");
    };
    
    CFRunLoopRef main_run_loop = [[NSRunLoop mainRunLoop] getCFRunLoop];
    
    networkReachabilityCallBack(proxyReachability,flags,(__bridge void *)self);
    
    if (!SCNetworkReachabilitySetCallback(proxyReachability, (SCNetworkReachabilityCallBack)networkReachabilityCallBack,&proxyReachabilityContext)){
        IVLog(@"Cannot register reachability cb");
    };
    
    if(!SCNetworkReachabilityScheduleWithRunLoop(proxyReachability, main_run_loop, kCFRunLoopDefaultMode)){
        IVLog(@"Cannot register schedule reachability cb");
    };
    
}

/*初始化SIP引擎*/
- (void)Initialize
{
    if(isInitialized)
        return;
    
    //self.simplePingHelper = [[FFSimplePingHelper alloc] initWithHostName:@"www.apple.com"];
    //[self.simplePingHelper startPing];
    
    connectivity=none;
    signal(SIGPIPE, SIG_IGN);

    //sip_engine_ = [SipEngine instance];
    //registrationManager_ = [sip_engine_ getRegistrationManager];
    //callManager_ = [sip_engine_ getCallManager];
    [self setProxyReachability];
    
    sip_engine_ = [SipEngine instance];
    registrationManager_ = [sip_engine_ getRegistrationManager];
    callManager_ = [sip_engine_ getCallManager];
    
    isInitialized = YES;
}

- (void)SetLoudspeakerStatus:(bool)yesno
{
    //client::RTCVoiceEngine *voice_engine = [self getRTCVoiceEngine];
    //voice_engine->SetLoudspeakerStatus(yesno);
}

- (void)runNetworkConnection {
	CFWriteStreamRef writeStream;
	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.168.0.200", 15000, nil, &writeStream);
	CFWriteStreamOpen (writeStream);
	const char* buff="hello";
	CFWriteStreamWrite (writeStream,(const UInt8*)buff,strlen(buff));
	CFWriteStreamClose (writeStream);
}	

- (void)kickOffNetworkConnection {
	/*start a new thread to avoid blocking the main ui in case of peer host failure*/
	[NSThread detachNewThreadSelector:@selector(runNetworkConnection) toTarget:self withObject:nil];
}


-(void)setDefaults:(NSString *)plist {
    
    //get the plist location from the settings bundle
    NSString *settingsPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle"];
    NSString *plistPath = [settingsPath stringByAppendingPathComponent:plist];
    
    //get the preference specifiers array which contains the settings
    NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
    
    //use the shared defaults object
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //for each preference item, set its default if there is no value set
    for(NSDictionary *item in preferencesArray) {
        
        //get the item key, if there is no key then we can skip it
        NSString *key = [item objectForKey:@"Key"];
        if (key) {
            
            //check to see if the value and default value are set
            //if a default value exists and the value is not set, use the default
            id value = [defaults objectForKey:key];
            id defaultValue = [item objectForKey:@"DefaultValue"];
            if(defaultValue && !value) {
                [defaults setObject:defaultValue forKey:key];
            }
        }
    }
    
    //write the changes to disk
    [defaults synchronize];
}

/*加载配置*/
/*- (void)LoadConfig
{
    BOOL webrtc_mode_enabled = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"enable_webrtc_mode"];
    NSString *username = (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"sip_user_name"];
    NSString *authname = (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"sip_auth_name"];
    NSString *password = (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"sip_password"];
    NSString *domain = (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"sip_domain"];
    NSString *proxy = (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"sip_proxy"];
    BOOL sip_enable_proxy = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"sip_enable_proxy"];
    NSString *transport = (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"sip_transport"];
    NSString *expire = (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"sip_expire"];
    NSString *display_name  = (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"sip_display_name"];
    NSString *apns_token = (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"apns_token"];
    BOOL enable_push_notification = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"enable_push_notification"];
    
    if(username && domain && password)
    {
        //[self DeRegisterSipAccount];

        [self createAccount:username
                        authname:([authname length] > 0? authname: nil)
                        password:password
                          server:domain
                           proxy:sip_enable_proxy? proxy : nil
                       transport:transport
                   supportWebrtc:webrtc_mode_enabled
                          expire:[expire integerValue]
                    display_name:display_name
         push_notification:enable_push_notification
                      apns_token:apns_token];
    }
    
    NSString *video_size = (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"video_size"];
    if(video_size && [video_size length] > 0)
    {
        if([video_size isEqualToString:@"qvga"])
        {
            s_video_size.width = 320;
            s_video_size.height = 240;
            s_bitrate = 256.0f;
            s_fps = 15;
        }else if([video_size isEqualToString:@"cif"])
        {
            s_video_size.width = 352;
            s_video_size.height = 288;
            s_bitrate = 384.0f;
            s_fps = 15;
        }else if([video_size isEqualToString:@"vga"])
        {
            s_video_size.width = 640;
            s_video_size.height = 480;
            s_bitrate = 512.0f;
            s_fps = 17;
        }else if([video_size isEqualToString:@"hd"]){
            s_video_size.width = 1280;
            s_video_size.height = 720;
            s_bitrate = 1024.0f;
            s_fps = 20;
        }
    }else{
        s_video_size.width = 640;
        s_video_size.height = 480;
        s_bitrate = 512.0f;
        s_fps = 17;
    }
    
    NSString* stun_server =  (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"ice_stun_server"];
    
    if(stun_server && [stun_server length] > 0)
    {
        NSArray *array = [stun_server componentsSeparatedByString:@":"]; //从字符:中分隔成2个元素的数组
        if(array.count > 1)
        {
            strcpy(rtc_config.media_options.stun_server, [((NSString *)[array objectAtIndex:0]) UTF8String]);
            rtc_config.media_options.stun_server_port = [((NSString *)[array objectAtIndex:1]) integerValue];
        }else
        {
            strcpy(rtc_config.media_options.stun_server, [stun_server UTF8String]);
            rtc_config.media_options.stun_server_port = DEFAULT_STUN_PORT;
        }
    }
    
    NSString* turn_server =  (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"ice_turn_server"];
    NSString* turn_username =  (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"ice_turn_username"];
    NSString* turn_password =  (NSString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"ice_turn_password"];
    
    if((turn_server && [turn_server length]) > 0 && (turn_username && [turn_username length] > 0))
    {
        NSArray *array = [stun_server componentsSeparatedByString:@":"]; //从字符:中分隔成2个元素的数组
        if(array.count > 1)
        {
            strcpy(rtc_config.media_options.turn_server, [((NSString *)[array objectAtIndex:0]) UTF8String]);
            rtc_config.media_options.turn_server_port = [((NSString *)[array objectAtIndex:1]) integerValue];
        }else {
            strcpy(rtc_config.media_options.turn_server, [turn_server UTF8String]);
            rtc_config.media_options.turn_server_port = DEFAULT_STUN_PORT;
        }
        
        
        if(turn_username && [turn_username length] > 0)
        {
            strcpy(rtc_config.media_options.turn_username, [turn_username UTF8String]);
        }
        
        
        if(turn_password && [turn_password length] > 0)
        {
            strcpy(rtc_config.media_options.turn_password, [turn_password UTF8String]);
        }
    }else {
     
        strcpy(rtc_config.media_options.turn_server, "");
        rtc_config.media_options.turn_server_port = 0;
        strcpy(rtc_config.media_options.turn_username, "");
        strcpy(rtc_config.media_options.turn_password, "");
    }
    
    
    //Set Audio Codecs
    {
        std::string audio_codecs;
        BOOL audio_codecs_isac = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"audio_codecs_isac"];
        if(audio_codecs_isac)
        {
            audio_codecs += "isac";
        }
        BOOL audio_codecs_opus = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"audio_codecs_opus"];
        if(audio_codecs_opus)
        {
            if(audio_codecs.length() > 0 )
                audio_codecs += ",";
            audio_codecs += "opus";
        }
        BOOL audio_codecs_g722 = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"audio_codecs_g722"];
        if(audio_codecs_g722)
        {
            if(audio_codecs.length() > 0 )
                audio_codecs += ",";
            audio_codecs += "g722";
        }
        BOOL audio_codecs_g729 = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"audio_codecs_g729"];
        if(audio_codecs_g729)
        {
            if(audio_codecs.length() > 0 )
                audio_codecs += ",";
            audio_codecs += "g729";
        }
        BOOL audio_codecs_gsm = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"audio_codecs_gsm"];
        if(audio_codecs_gsm)
        {
            if(audio_codecs.length() > 0 )
                audio_codecs += ",";
            audio_codecs += "GSM";
        }
        BOOL audio_codecs_ilbc = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"audio_codecs_ilbc"];
        if(audio_codecs_ilbc)
        {
            if(audio_codecs.length() > 0 )
                audio_codecs += ",";
            audio_codecs += "ILBC";
        }
        BOOL audio_codecs_pcmu = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"audio_codecs_pcmu"];
        if(audio_codecs_pcmu)
        {
            if(audio_codecs.length() > 0 )
                audio_codecs += ",";
            audio_codecs += "PCMU";
        }
        BOOL audio_codecs_pcma = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"audio_codecs_pcma"];
        if(audio_codecs_pcma)
        {
            if(audio_codecs.length() > 0 )
                audio_codecs += ",";
            audio_codecs += "PCMA";
        }
        
        IVLog(@"Set Audio Codecs : %s",audio_codecs.c_str());
        
        strcpy(rtc_config.media_options.audio_codecs, audio_codecs.c_str());
    }
    
    //Set Video Codecs
    {
        std::string video_codecs;
        BOOL video_codecs_vp8 = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"video_codecs_vp8"];
        if(video_codecs_vp8)
        {
            video_codecs += "VP8";
        }
        BOOL video_codecs_vp9 = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"video_codecs_vp9"];
        if(video_codecs_vp9)
        {
            if(video_codecs.length() > 0 )
                video_codecs += ",";
            video_codecs += "VP9";
        }
        BOOL video_codecs_h264 = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"video_codecs_h264"];
        if(video_codecs_h264)
        {
            if(video_codecs.length() > 0 )
                video_codecs += ",";
            video_codecs += "H264";
        }
        BOOL video_codecs_red = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"video_codecs_red"];
        if(video_codecs_red)
        {
            if(video_codecs.length() > 0 )
                video_codecs += ",";
            video_codecs += "red";
        }
        BOOL video_codecs_ulpfec = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"video_codecs_ulpfec"];
        if(video_codecs_ulpfec)
        {
            if(video_codecs.length() > 0 )
                video_codecs += ",";
            video_codecs += "ulpfec";
        }
        BOOL video_codecs_rtx = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"video_codecs_rtx"];
        if(video_codecs_rtx)
        {
            if(video_codecs.length() > 0 )
                video_codecs += ",";
            video_codecs += "rtx";
        }
        
        IVLog(@"Set Video Codecs : %s",video_codecs.c_str());
        
        strcpy(rtc_config.media_options.video_codecs, video_codecs.c_str());
    }
}*/

- (void)Terminate
{
	[mIterateTimer invalidate];
	
	if (sip_engine_) {
		
		//sip_engine_->Terminate();
				
		//if(event_observer_){
			//delete event_observer_;
			//event_observer_ = nil;
		//}

        //client::SipEngineFactory::Delete(sip_engine_);
	}

    SCNetworkReachabilityUnscheduleFromRunLoop(proxyReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    CFRelease(proxyReachability);
    proxyReachability=nil;
}

+(SipEngineManager*)instance {
	if (theSipEngineManager==nil) {
		theSipEngineManager = [[SipEngineManager alloc] init];
	}
	return theSipEngineManager;
}

- (SipEngine*)getSipEngine{
	return sip_engine_;
}

- (CallManager*)getCallManager
{
    return [sip_engine_ getCallManager];
}

- (RegistrationManager*)getRegistrationManager
{
    return [sip_engine_ getRegistrationManager];
}

- (void)setSipEngineRegistrationDelegate:(id<SipEngineUIRegistrationDelegate>)delegate
{
    [[self getRegistrationManager] registerUIRegistrationDelegate:delegate];
}

- (void)setSipEngineCallDelegate:(id<SipEngineUICallDelegate>)delegate
{
    [[self getCallManager] registerUICallStateDelegate:delegate];
}

/*-(client::SipProfileManager*) getSipProfileManager
{
    return sip_engine_->GetSipProfileManager();
}

-(client::RTCVoiceEngine*) getRTCVoiceEngine
{
    client::MediaEngine* media_engine = sip_engine_->GetMediaEngine();
    return media_engine->GetRTCVoiceEngine();
}

-(client::RTCVideoEngine*) getRTCVideoEngine
{
    client::MediaEngine* media_engine = sip_engine_->GetMediaEngine();
    return media_engine->GetRTCVideoEngine();
}*/

- (Account *)createAccount
{
    return [registrationManager_ createAccount];
}
               
- (void)RefreshSipRegister
{
    /*client::SipProfileManager *profile_manager = sip_engine_->GetSipProfileManager();
    client::RegistrationManager *registration_manager = sip_engine_->GetRegistrationManager();
    client::SipProfile *profile = profile_manager->selectSipProfile(DEFAULT_SIP_PROFILE);
    registration_manager->RefreshRegistration(profile);*/
}

- (Call *)createCall:(int)accId
{
    return [[self getCallManager] createCall:accId];
}

- (void)TerminateCall
{
    /*client::CallManager *call_manager = [self getCallManager];
    client::CallMap call_map;
    if(call_manager->GetCallMap(call_map))
    {
        client::CallMap::iterator it = call_map.begin();
        while (it != call_map.end())
        {
            client::Call *call = it->second;
            call->Hangup();
            it++;
        }
    }*/
    current_call_ = nil;
}

+(void)doScheduleNotification:(NSString*)from types:(ScheduleNotificationType)type content:(NSString*)content
{
	UILocalNotification* alarm = [[UILocalNotification alloc] init];
	
	UIApplication* theApp = [UIApplication sharedApplication];
	NSArray*    oldNotifications = [theApp scheduledLocalNotifications];
	
	if ([oldNotifications count] > 0)
		[theApp cancelAllLocalNotifications];

	NSDate *fireDate = [NSDate dateWithTimeInterval:1 sinceDate:[NSDate dateWithTimeIntervalSinceNow:0]];

	if (alarm)
	{
		alarm.fireDate = fireDate;
		alarm.timeZone = [NSTimeZone defaultTimeZone];
        NSString* alertBody = nil;
        
        UInt32 audioRouteOverride  = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
        
        //[[UserSoundsPlayerUtil instance] playVibrate:YES];
        
        if (type == kNotifyAudioCall) {
            //incoming call 
            alertBody =[NSString  stringWithFormat:@"%@ %@", NSLocalizedString(@"Incoming Call",@""),from];
            alarm.alertAction = NSLocalizedString(@"Answer",@"");
        }else if (type == kNotifyVideoCall) {
            alertBody =[NSString  stringWithFormat:NSLocalizedString(@"Incoming Video Call %@",@""),from];
            alarm.alertAction = NSLocalizedString(@"Answer",@"");
        }

        alarm.alertBody = alertBody;
		alarm.hasAction = YES;
        if (type == kNotifyAudioCall || type == kNotifyVideoCall)
        {
            //incoming call
            alarm.soundName = DEFAULT_RING_TONE_LONG;
        }

        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:type],    @"type", 
                              from,                             @"from",
                              nil];
        [alarm setUserInfo:dict];
		[theApp scheduleLocalNotification:alarm];
	}
}



//**********************BG mode management*************************///////////
- (void)enterBackgroundMode {
    
    if(!sip_engine_)
        return;
    
    //进入后台模式
    [self RefreshSipRegister];

    //register keepalive
    if ([[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
        IVLog(@"keepalive handler");
        //kick up network cnx, just in case
        [self kickOffNetworkConnection];
        [self RefreshSipRegister];
    }]) {
        IVLog(@"keepalive handler succesfully registered");
    } else {
        IVLog(@"keepalive handler cannot be registered");
    }
	
    //wait for registration answer
    int i=0;
    while (i++ < 40) {
        //sip_engine_->RunEventLoop();
        usleep(100000);
    }
    
     IVLog(@"Enter to background mode !");
}

- (void)becomeActive {
    
    if (proxyReachability){
		SCNetworkReachabilityFlags flags=0;
		if (!SCNetworkReachabilityGetFlags(proxyReachability, &flags)) {
			IVLog(@"Cannot get reachability flags, re-creating reachability context.");
            [self setProxyReachability];
		}else{
			networkReachabilityCallBack(proxyReachability, flags,(__bridge void *)self);
			if (flags==0){
				/*workaround iOS bug: reachability API cease to work after some time.*/
				/*when flags==0, either we have no network, or the reachability object lies. To workaround, create a new one*/
                [self setProxyReachability];
			}
		}
    }else{
        IVLog(@"No proxy reachability context created !");
    }
    
    //if(sip_engine_) [self RefreshSipRegister];
}

@end
