//
//  GOMainApp.h
//  Goalie
//
//  Created by Stefan Kroon on 15-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TimeWindow, AbstractTimeWindow;
@class GOGoalieServices, GOSensePlatform, GOCoreData, GOTestFlight, GOKeychain, GOLocationManager;
@class GOActiveGoal, GOTaskBrew, GOReachabilityManager, GOTranslation;

static NSString * const kGOGoalieServices = @"goalieServices";

@interface GOMainApp : NSObject

// Services
@property (readonly) GOLocationManager *locationService;
@property (readonly) GOSensePlatform *sensePlatform;
@property (readonly) GOCoreData *coreData;
@property (readonly) GOTestFlight *testFlight;
@property (readonly) GOGoalieServices *goalieServices;
@property (readonly) GOKeychain *keychain;
@property (readonly) GOReachabilityManager *reachabilityManager;
@property (readonly) GOTranslation *translation;

// Properties

@property GOActiveGoal *editingGoal;
@property (readonly) NSDate *launchTime;
@property bool isTesting;
@property (readonly) NSDateFormatter *genericDateFormatter;

@property NSURL *serverURL;

- (void)startGoalieServices;
- (void)stopGoalieServices;

+ (GOMainApp *)sharedMainApp;
+ (NSDateComponents *)subtractOneWeek;
+ (NSDate *)nextSunday;
+ (TimeWindow *)activeGoalTimeWindow;
+ (NSCalendar *)currentCalendar;
+ (AbstractTimeWindow *)abstractNoonWindow;

- (void)initialize:(void (^)(bool success))handler;
- (void)willTerminate;
- (NSDate *)nowDate;
- (void)restart;
- (void)syncActiveGoals;
- (void)presentBrewAfterEvent:(GOTaskBrew *)brew;
- (void)errorAlertMessage:(NSString *)errorMessage;
- (void)presentLoginFailure:(NSString *)message;
- (void)logout;

@property NSString *loadingText;
@property (nonatomic) NSTimeInterval timeOffsetInterval;
    
@end
