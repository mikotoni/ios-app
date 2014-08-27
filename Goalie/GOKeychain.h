//
//  GOKeychain.h
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kGOKeychainUsername = @"username";
static NSString * const kGOKeychainPassword = @"password";

@interface GOKeychain : NSObject

@property NSString *username;
@property NSString *password;

- (void)storeUsername:(NSString *)username password:(NSString *)password;
- (void)deletePassword;
- (bool)hasAutoLoginCredentials;
    
@end
