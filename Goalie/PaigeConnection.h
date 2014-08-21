//
//  PaigeConnection.h
//  Paraatheidsapp
//
//  Created by Stefan Kroon on 28-03-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeychainItemWrapper.h"

@interface PaigeConnection : NSObject {
    KeychainItemWrapper *_askAccountPassword;
    KeychainItemWrapper *_askAccountSession;
}

@property NSString *baseUrl;
@property NSString *deviceToken;
@property NSString *xSessionId;

@property NSString *username;
@property NSString *password;

- (id)initWithUrl:(NSString *)url;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password completionHandler:(void (^)(BOOL success))handler;
- (void)logout;
- (void)uploadDeviceToken:(NSString *)deviceToken;
    
+ (NSString *)md5:(NSString *)string;
- (void)sendRequest:(NSString *)urlPath
             method:(NSString *)method
         postString:(NSString *)postString
         expectJson:(BOOL)expectJson
            handler:(void (^)(NSHTTPURLResponse *httpResponse, NSString *responseString, id dictOrArray, NSError *error))handler;

- (void)sendJsonRequest:(NSString *)urlPath
               jsonDict:(NSDictionary *)jsonDict
             expectJson:(BOOL)expectJson
                handler:(void (^)(NSHTTPURLResponse *httpResponse, NSString *responseString, id dictOrArray, NSError *error))handler;


@end
