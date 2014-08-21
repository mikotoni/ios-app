//
//  GOSensePlatform.h
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOSleepState;

static NSString * const kGOTimeActive = @"timeActive";
static NSString * const kGOActiveGoalsDictionaries = @"activeGoalsDictionaries";
static NSString * const kGOSleepState = @"sleepState";
static NSString * const kGOIsConnected = @"icConnected";
static NSString * const kGOIsLoadingActiveGoals = @"isLoadingActiveGoals";

@interface GOSensePlatform : NSObject

//@property (nonatomic, retain) NSArray *activeGoals;
@property (atomic, readonly) bool isConnected;
@property (atomic, readonly) NSUInteger nofLoginAttempts;
@property (atomic, readonly) NSDate *lastFailedLogin;

// Properties to observe
@property (nonatomic, readonly) NSTimeInterval timeActive;
@property (nonatomic, readonly) NSArray *activeGoalsDictionaries;
@property (nonatomic, readonly) GOSleepState *sleepState;
@property (nonatomic, readonly) bool isLoadingActiveGoals;

// Refresh observed properties
- (void)refreshActiveGoalsDictionaries;
- (void)refreshSleepState;


- (void)willTerminate;
- (BOOL)loginWithUsername:(NSString *)username password:(NSString *)password;
- (void)logout;
- (void)resetTimeActiveSensor;
- (void)startTemporaryHighFrequencyMotionDetection;
- (void)updateActiveGoalProgress:(NSNumber *)points sensorName:(NSString *)sensorName;
- (void)addVersionInfoDataPoint:(NSString *)version build:(NSString *)build;
- (void)addEmotionDataPointWithPleasure:(NSNumber *)pleasure arousal:(NSNumber *)arousal dominance:(NSNumber *)dominance;

@end

