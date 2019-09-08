/*
 *  Copyright 2016 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "AccountConfigStore.h"

static NSString *const kUsernameKey = @"username_key";
static NSString *const kDisplaynameKey = @"displayname_key";
static NSString *const kAuthnameKey = @"authname_key";
static NSString *const kPasswordKey = @"password_key";
static NSString *const kDomainKey = @"domain_key";
static NSString *const kServerKey = @"server_key";
static NSString *const kProxyKey = @"proxy_key";
static NSString *const kRealmKey = @"realm_key";

NS_ASSUME_NONNULL_BEGIN
@interface AccountConfigStore () {
  NSUserDefaults *_storage;
}
@property(nonatomic, strong, readonly) NSUserDefaults *storage;
@end

@implementation AccountConfigStore

+ (void)setDefaultsForAccountConfig:(NSString *)username
                           authname:(NSString *)authname
                           password:(NSString *)password
                             server:(NSString *)server
                              proxy:(NSString *)proxy
                       displayname:(NSString *)displayname {
  NSMutableDictionary<NSString *, id> *defaultsDictionary = [@{
    kUsernameKey : username,
    kAuthnameKey : authname,
    kPasswordKey : password,
    kServerKey   : server,
    kProxyKey    : proxy,
    kDisplaynameKey : displayname
  } mutableCopy];

  [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDictionary];
}

- (NSUserDefaults *)storage {
  if (!_storage) {
    _storage = [NSUserDefaults standardUserDefaults];
  }
  return _storage;
}

- (NSString *)username {
  return [self.storage stringForKey:kUsernameKey];
}

- (void)setUsername:(NSString *)username {
  [self.storage setObject:username forKey:kUsernameKey];
  [self.storage synchronize];
}

- (NSString *)authname {
  return [self.storage stringForKey:kAuthnameKey];
}

- (void)setAuthname:(NSString *)authname {
  [self.storage setObject:authname forKey:kAuthnameKey];
  [self.storage synchronize];
}

- (NSString *)password {
  return [self.storage stringForKey:kPasswordKey];
}

- (void)setPassword:(NSString *)password {
  [self.storage setObject:password forKey:kPasswordKey];
  [self.storage synchronize];
}

- (NSString *)server {
  return [self.storage stringForKey:kServerKey];
}

- (void)setServer:(NSString *)server {
  [self.storage setObject:server forKey:kServerKey];
  [self.storage synchronize];
}

- (NSString *)proxy {
  return [self.storage stringForKey:kProxyKey];
}

- (void)setProxy:(NSString *)proxy {
  [self.storage setObject:proxy forKey:kProxyKey];
  [self.storage synchronize];
}

- (NSString *)displayname {
  return [self.storage stringForKey:kDisplaynameKey];
}

- (void)setDisplayname:(NSString *)displayname {
  [self.storage setObject:displayname forKey:kDisplaynameKey];
  [self.storage synchronize];
}

@end
NS_ASSUME_NONNULL_END
