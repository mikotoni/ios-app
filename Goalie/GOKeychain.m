//
//  GOKeychain.m
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOKeychain.h"
#import "KeychainItemWrapper.h"
#import "GOTestFlight.h"

@implementation GOKeychain {
    KeychainItemWrapper *_senseAccount;
}

#if __has_feature(objc_arc)
#define CAST_TO_ID(value) ((__bridge id)value)
#else
#define CAST_TO_ID(value) ((id)value)
#endif

- (id)init {
    self = [super init];
    if(self) {
        _senseAccount = [[KeychainItemWrapper alloc] initWithIdentifier:@"Sense Account" accessGroup:nil];
        NSString *username = [_senseAccount objectForKey:CAST_TO_ID(kSecAttrAccount)];
        if(username)
            _username = [username copy];
        NSString *password = [_senseAccount objectForKey:CAST_TO_ID(kSecValueData)];
        if(password && ![password isEqualToString:@""])
            _password = [password copy];
    }
    return self;
}

- (void)storeUsername:(NSString *)username password:(NSString *)password {
    NSLog(@"Try to write username to the keychain. username:%@", username);
    [_senseAccount setObject:username forKey:CAST_TO_ID(kSecAttrAccount)];
    [_senseAccount setObject:password forKey:CAST_TO_ID(kSecValueData)];
    [_senseAccount setObject:CAST_TO_ID(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly) forKey:CAST_TO_ID(kSecAttrAccessible)];
    [_senseAccount writeToKeychain];
    self.username = username;
    self.password = password;
}

- (void)deletePassword {
    [_senseAccount setObject:@"" forKey:CAST_TO_ID(kSecValueData)];
    [_senseAccount writeToKeychain];
    self.password = nil;
}

- (bool)hasAutoLoginCredentials {
    NSString *username = [self username];
    NSString *password = [self password];
    if(username && password && ![username isEqualToString:@""] && ![password isEqualToString:@""]) {
        return YES;
    }
//    [TestFlight passCheckpoint:@"hasNoAutoLoginCredentials"];
    TFLog(@"hasNoAutoLoginCredentials username:%@ password-length:%d", username, [password length]);
    return NO;
}


@end
