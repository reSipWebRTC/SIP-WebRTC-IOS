/*
 *  Copyright 2016 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>

#import <WebRTC/RTCVideoCodecInfo.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Model class for user defined CallConfig.
 *
 * Handles storing the CallConfig and provides default values if CallConfig is not
 * set. Also provides list of available options for different CallConfig. Stores
 * for example video codec, video resolution and maximum bitrate.
 */
@interface CallParams : NSObject

/**
 * Returns array of available capture resoultions.
 *
 * The capture resolutions are represented as CallConfig in the following format
 * [width]x[height]
 */
- (NSArray<NSString *> *)availableVideoResolutions;

/**
 * Returns current video resolution CallConfig.
 * If no resolution is in store, default value of 640x480 is returned.
 * When defaulting to value, the default is saved in store for consistency reasons.
 */
- (NSString *)currentVideoResolutionConfigFromStore;
- (int)currentVideoResolutionWidthFromStore;
- (int)currentVideoResolutionHeightFromStore;

/**
 * Stores the provided video resolution string into the store.
 *
 * If the provided resolution is no part of the available video resolutions
 * the store operation will not be executed and NO will be returned.
 * @param resolution the string to be stored.
 * @return YES/NO depending on success.
 */
- (BOOL)storeVideoResolutionConfig:(NSString *)resolution;

/**
 * Returns array of available video codecs.
 */
- (NSArray<RTCVideoCodecInfo *> *)availableVideoCodecs;

/**
 * Returns current video codec setting from store if present or default (H264) otherwise.
 */
- (RTCVideoCodecInfo *)currentVideoCodecConfigFromStore;

/**
 * Stores the provided video codec CallConfig into the store.
 *
 * If the provided video codec is not part of the available video codecs
 * the store operation will not be executed and NO will be returned.
 * @param videoCodec settings the string to be stored.
 * @return YES/NO depending on success.
 */
- (BOOL)storeVideoCodecConfig:(RTCVideoCodecInfo *)videoCodec;

/**
 * Returns current max bitrate CallConfig from store if present.
 */
- (nullable NSNumber *)currentMaxBitrateConfigFromStore;

/**
 * Returns current video fps CallConfig from store if present.
 */
- (nullable NSNumber *)currentVideoFpsConfigFromStore;

/**
 * Stores the provided bitrate value into the store.
 *
 * @param bitrate NSNumber representation of the max bitrate value.
 */
- (void)storeMaxBitrateConfig:(nullable NSNumber *)bitrate;

/**
 * Stores the provided fps value into the store.
 *
 * @param fps NSNumber representation of the video fps value.
 */
- (void)storeVideoFpsConfig:(nullable NSNumber *)fps;

/**
 * Returns current audio only CallConfig from store if present or default (NO) otherwise.
 */
- (BOOL)currentAudioOnlyConfigFromStore;

/**
 * Stores the provided audio only setting into the store.
 *
 * @param audioOnly the boolean value to be stored.
 */
- (void)storeAudioOnlyConfig:(BOOL)audioOnly;

/**
 * Returns current create AecDump setting from store if present or default (NO) otherwise.
 */
- (BOOL)currentCreateAecDumpConfigFromStore;

/**
 * Stores the provided create AecDump setting into the store.
 *
 * @param createAecDump the boolean value to be stored.
 */
- (void)storeCreateAecDumpConfig:(BOOL)createAecDump;

/**
 * Returns current CallConfig whether to use manual audio config from store if present or default (YES)
 * otherwise.
 */
- (BOOL)currentUseManualAudioConfigFromStore;

/**
 * Stores the provided use manual audio config CallConfig into the store.
 *
 * @param useManualAudioConfig the boolean value to be stored.
 */
- (void)storeUseManualAudioConfig:(BOOL)useManualAudioConfig;

- (void)addIceServer:(NSString *)serverUrl
            username:(nullable NSString *)username
            credential:(nullable NSString *)credential;

@property(nonatomic, strong) NSMutableArray *iceServers;

@property(nonatomic, assign) BOOL isDebug;

@property(nonatomic, assign) BOOL isVideoCall;

@property(nonatomic, assign) BOOL isInvisibilityCall;

@end
NS_ASSUME_NONNULL_END
