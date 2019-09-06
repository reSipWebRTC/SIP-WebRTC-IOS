/*
 *  Copyright 2016 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "CallConfig+Private.h"
#import "CallConfigStore.h"

#import <WebRTC/RTCCameraVideoCapturer.h>
#import <WebRTC/RTCDefaultVideoEncoderFactory.h>
#import <WebRTC/RTCMediaConstraints.h>

NS_ASSUME_NONNULL_BEGIN

@interface CallConfig () {
  CallConfigStore *_callConfigStore;
}
@end

@implementation CallConfig

- (NSArray<NSString *> *)availableVideoResolutions {
  NSMutableSet<NSArray<NSNumber *> *> *resolutions =
      [[NSMutableSet<NSArray<NSNumber *> *> alloc] init];
  for (AVCaptureDevice *device in [RTCCameraVideoCapturer captureDevices]) {
    for (AVCaptureDeviceFormat *format in
         [RTCCameraVideoCapturer supportedFormatsForDevice:device]) {
      CMVideoDimensions resolution =
          CMVideoFormatDescriptionGetDimensions(format.formatDescription);
      NSArray<NSNumber *> *resolutionObject = @[ @(resolution.width), @(resolution.height) ];
      [resolutions addObject:resolutionObject];
    }
  }

  NSArray<NSArray<NSNumber *> *> *sortedResolutions =
      [[resolutions allObjects] sortedArrayUsingComparator:^NSComparisonResult(
                                    NSArray<NSNumber *> *obj1, NSArray<NSNumber *> *obj2) {
        NSComparisonResult cmp = [obj1.firstObject compare:obj2.firstObject];
        if (cmp != NSOrderedSame) {
          return cmp;
        }
        return [obj1.lastObject compare:obj2.lastObject];
      }];

  NSMutableArray<NSString *> *resolutionStrings = [[NSMutableArray<NSString *> alloc] init];
  for (NSArray<NSNumber *> *resolution in sortedResolutions) {
    NSString *resolutionString =
        [NSString stringWithFormat:@"%@x%@", resolution.firstObject, resolution.lastObject];
    [resolutionStrings addObject:resolutionString];
  }

  return [resolutionStrings copy];
}

- (NSString *)currentVideoResolutionConfigFromStore {
  [self registerStoreDefaults];
  return [[self callConfigStore] videoResolution];
}

- (BOOL)storeVideoResolutionConfig:(NSString *)resolution {
  if (![[self availableVideoResolutions] containsObject:resolution]) {
    return NO;
  }
  [[self callConfigStore] setVideoResolution:resolution];
  return YES;
}

- (NSArray<RTCVideoCodecInfo *> *)availableVideoCodecs {
  return [RTCDefaultVideoEncoderFactory supportedCodecs];
}

- (RTCVideoCodecInfo *)currentVideoCodecConfigFromStore {
  [self registerStoreDefaults];
  NSData *codecData = [[self callConfigStore] videoCodec];
  return [NSKeyedUnarchiver unarchiveObjectWithData:codecData];
}

- (BOOL)storeVideoCodecConfig:(RTCVideoCodecInfo *)videoCodec {
  if (![[self availableVideoCodecs] containsObject:videoCodec]) {
    return NO;
  }
  NSData *codecData = [NSKeyedArchiver archivedDataWithRootObject:videoCodec];
  [[self callConfigStore] setVideoCodec:codecData];
  return YES;
}

- (nullable NSNumber *)currentMaxBitrateConfigFromStore {
  [self registerStoreDefaults];
  return [[self callConfigStore] maxBitrate];
}

- (void)storeMaxBitrateConfig:(nullable NSNumber *)bitrate {
  [[self callConfigStore] setMaxBitrate:bitrate];
}

- (BOOL)currentAudioOnlyConfigFromStore {
  return [[self callConfigStore] audioOnly];
}

- (void)storeAudioOnlyConfig:(BOOL)audioOnly {
  [[self callConfigStore] setAudioOnly:audioOnly];
}

- (BOOL)currentCreateAecDumpConfigFromStore {
  return [[self callConfigStore] createAecDump];
}

- (void)storeCreateAecDumpConfig:(BOOL)createAecDump {
  [[self callConfigStore] setCreateAecDump:createAecDump];
}

- (BOOL)currentUseManualAudioConfigFromStore {
  return [[self callConfigStore] useManualAudioConfig];
}

- (void)storeUseManualAudioConfig:(BOOL)useManualAudioConfig {
  [[self callConfigStore] setUseManualAudioConfig:useManualAudioConfig];
}

#pragma mark - Testable

- (CallConfigStore *)callConfigStore {
  if (!_callConfigStore) {
    _callConfigStore = [[CallConfigStore alloc] init];
    [self registerStoreDefaults];
  }
  return _callConfigStore;
}

- (int)currentVideoResolutionWidthFromStore {
  NSString *resolution = [self currentVideoResolutionConfigFromStore];

  return [self videoResolutionComponentAtIndex:0 inString:resolution];
}

- (int)currentVideoResolutionHeightFromStore {
  NSString *resolution = [self currentVideoResolutionConfigFromStore];
  return [self videoResolutionComponentAtIndex:1 inString:resolution];
}

#pragma mark -

- (NSString *)defaultVideoResolutionConfig {
  return [self availableVideoResolutions].firstObject;
}

- (RTCVideoCodecInfo *)defaultVideoCodecConfig {
  return [self availableVideoCodecs].firstObject;
}

- (int)videoResolutionComponentAtIndex:(int)index inString:(NSString *)resolution {
  if (index != 0 && index != 1) {
    return 0;
  }
  NSArray<NSString *> *components = [resolution componentsSeparatedByString:@"x"];
  if (components.count != 2) {
    return 0;
  }
  return components[index].intValue;
}

- (void)registerStoreDefaults {
  NSData *codecData = [NSKeyedArchiver archivedDataWithRootObject:[self defaultVideoCodecConfig]];
  [CallConfigStore setDefaultsForVideoResolution:[self defaultVideoResolutionConfig]
                                       videoCodec:codecData
                                          bitrate:nil
                                        audioOnly:NO
                                    createAecDump:NO
                             useManualAudioConfig:YES];
}

@end
NS_ASSUME_NONNULL_END
