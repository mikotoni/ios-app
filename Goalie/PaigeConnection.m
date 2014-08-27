//
//  PaigeConnection.m
//  Paraatheidsapp
//
//  Created by Stefan Kroon on 28-03-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "PaigeConnection.h"
#import "CommonCrypto/CommonDigest.h"

#if __has_feature(objc_arc)
#define CAST_TO_ID(value) ((__bridge id)value)
#else
#define CAST_TO_ID(value) ((id)value)
#endif

#define API_VERSION 1

#if API_VERSION == 1
    // API v1
    static NSString *usernameParamName = @"uuid";
    static NSString *passwordParamName = @"pass";
    static NSString *uploadPath = @"timeout/deviceToken/";
    static NSString *deviceTokenJsonParam = @"deviceToken";
#else
    // API v2
    static NSString *usernameParamName = @"username";
    static NSString *passwordParamName = @"password";
    static NSString *uploadPath = @"setAPNSKey";
    static NSString *deviceTokenJsonParam = @"key";
#endif

@implementation PaigeConnection

+ (NSString *)md5:(NSString *)string {
    const char *cStr = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH+1];
    CC_MD5(cStr, strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[ 0], result[ 1], result[ 2], result[ 3],
            result[ 4], result[ 5], result[ 6], result[ 7],
            result[ 8], result[ 9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

- (id)initWithUrl:(NSString *)url {
    self = [super init];
    if(self) {
        _baseUrl = url;

        _askAccountSession = [[KeychainItemWrapper alloc] initWithIdentifier:@"Session" accessGroup:nil];
        NSString *xSessionId = [_askAccountSession objectForKey:CAST_TO_ID(kSecValueData)];
        if(!xSessionId || [xSessionId isEqualToString:@""])
            _xSessionId = nil;
        else {
            _xSessionId = [xSessionId copy];
            NSURL *url = [NSURL URLWithString:_baseUrl];
            NSDictionary *cookieDict = [NSDictionary dictionaryWithObjectsAndKeys:@"X-SESSION_ID", NSHTTPCookieName, _xSessionId, NSHTTPCookieValue, [url host], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
            NSHTTPCookie *sessionCookie = [NSHTTPCookie cookieWithProperties:cookieDict ];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:sessionCookie];
        }

        _askAccountPassword = [[KeychainItemWrapper alloc] initWithIdentifier:@"Ask Account" accessGroup:nil];
        NSString *username = [_askAccountPassword objectForKey:CAST_TO_ID(kSecAttrAccount)];
        if(username)
            _username = [username copy];
        NSString *password = [_askAccountPassword objectForKey:CAST_TO_ID(kSecValueData)];
        if(password)
            _password = [password copy];

    }
    return self;
}

- (void)sendRequest:(NSString *)urlPath method:(NSString *)method postString:(NSString *)postString expectJson:(BOOL)expectJson handler:(void (^)(NSHTTPURLResponse *httpResponse, NSString *responseString, id dictOrArray, NSError *error))handler {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.baseUrl, urlPath]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
	if(method)
		[request setHTTPMethod:method];
	if(postString)
		[request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];

	NSLog(@"Http Request: %@", [request description]);
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		BOOL skipHandler = NO;
		NSString *responseString = nil;
		NSDictionary *jsonDict = nil;
		NSHTTPURLResponse *httpResponse =
			([response isKindOfClass:[NSHTTPURLResponse class]] ? (id)response : nil);
		if(data) {
			responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
#if !__has_feature(objc_arc)
			[responseString autorelease];
#endif
		}
		if(httpResponse) {
			NSInteger statusCode = [httpResponse statusCode];
			NSLog(@"HttpResponse status code: %d", statusCode);
			switch(statusCode) {
				case 200: {
										if(expectJson && responseString) {
											NSLog(@"Received json: %@", responseString);
											NSError *jsonError = nil;
											jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
											if(jsonError) {
												NSLog(@"Json parse error");
												//error = [jsonError retain];
											}
										}
										break;
									}
				case 403: {
										if(self.username && self.password) {
											[self loginWithUsername:self.username password:self.password completionHandler:^(BOOL success) {
												if(success) {
													[self sendRequest:urlPath method:method postString:postString expectJson:expectJson handler:^(NSHTTPURLResponse *httpResponse, NSString *responseString, id dictOrArray, NSError *error) {
														handler(httpResponse, responseString, dictOrArray, error);
													}];
												}
												else {
													handler(httpResponse, responseString, jsonDict, error);
												}
											}];
											skipHandler = YES;
										}
										break;
									}
				default: {
									 break;
								 }
			}
		}
		if(!skipHandler)
			handler(httpResponse, responseString, jsonDict, error);
	}];
}

- (void)sendJsonRequest:(NSString *)urlPath
               jsonDict:(NSDictionary *)jsonDict
             expectJson:(BOOL)expectJson
                handler:(void (^)(NSHTTPURLResponse *httpResponse, NSString *responseString, id dictOrArray, NSError *error))handler {
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self sendRequest:@"states/" method:@"POST" postString:jsonString expectJson:expectJson handler:^(NSHTTPURLResponse *httpResponse, NSString *responseString, id dictOrArray, NSError *error) {
        handler(httpResponse, responseString, dictOrArray, error);
    }];
    
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completionHandler:(void (^)(BOOL))handler {
    self.username = username;
    self.password = password;
    NSString *md5password = [[self class] md5:password];
    NSString *baseUrl = self.baseUrl;
    
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:@"%@login?%@=%@&%@=%@&verification=none",
                   baseUrl,
                   usernameParamName,
                   [[username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"],
                   passwordParamName,
                   md5password]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse *httpResponse = ([response isKindOfClass:[NSHTTPURLResponse class]] ? (id)response : nil);
        BOOL succes = NO;
        
        if(httpResponse && [httpResponse statusCode] == 200 && data) {
            NSError *jsonError = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            self.xSessionId = [dict objectForKey:@"X-SESSION_ID"];
            if(self.xSessionId) {
                succes = YES;
                NSString *username = self.username;
                NSString *password = self.password;
                NSLog(@"Try to write username to the keychain. username:%@", username);
                [_askAccountPassword setObject:username forKey:CAST_TO_ID(kSecAttrAccount)];
                [_askAccountPassword setObject:password forKey:CAST_TO_ID(kSecValueData)];
                [_askAccountPassword writeToKeychain];
                [_askAccountSession setObject:username forKey:CAST_TO_ID(kSecAttrAccount)];
                [_askAccountSession setObject:self.xSessionId forKey:CAST_TO_ID(kSecValueData)];
                [_askAccountSession writeToKeychain];
            }
        }
        if(handler)
            handler(succes);
    }];
}

- (void)logout {
    [_askAccountSession resetKeychainItem];
    [_askAccountSession writeToKeychain];
    if(self.xSessionId)
        self.xSessionId = nil;
    [_askAccountPassword setObject:@"" forKey:CAST_TO_ID(kSecValueData)];
    [_askAccountPassword writeToKeychain];
}

- (BOOL)isLoggedIn {
    if(self.xSessionId)
        return YES;
    else
        return NO;
}

- (void)uploadDeviceToken:(NSString *)deviceToken {
    if(deviceToken == nil) {
        NSLog(@"Refuse to upload deviceToken:%@", deviceToken);
        return;
    }
    
    NSString *deviceTokenJson = [NSString stringWithFormat:@"{\"%@\":\"%@\"}", deviceTokenJsonParam, deviceToken];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.baseUrl, uploadPath]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[deviceTokenJson dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse *httpResponse = ([response isKindOfClass:[NSHTTPURLResponse class]] ? (id)response : nil);
        NSString *message = nil;
        if(httpResponse && [httpResponse statusCode] == 200) {
            message = [NSString stringWithFormat:@"Het opslaan van de device token is gelukt."];
            NSLog(@"%@ (deviceToken: %@)", message, deviceToken);
        }
        else {
            NSLog(@"Failed to upload device token: %@", [error description]);
            message = [NSString stringWithFormat:@"Het opslaan van de device token is mislukt. Je kunt nu geen push berichten ontvangen. HTTP status code: %d", [httpResponse statusCode]];
            [self showAlertView:@"Device Token" message:message];
        }
    }];
}

- (void)showAlertView:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
#if !__has_feature(objc_arc)
    [alert release];
#endif
}

#if !__has_feature(objc_arc)
- (void)dealloc {
    [_username release];
    [_password release];
    [_xSessionId release];
    [_baseUrl release];
    [super dealloc];
}
#endif

@end
