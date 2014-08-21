//
//  GOSleepTask.h
//  Goalie
//
//  Created by Stefan Kroon on 13-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GODescriptiveTask.h"

@class GOSleepState;


static NSString * const kGOSleepTaskCorrectBehavior = @"correctBehavior";
static NSString * const kGOSleepTaskDetectedTime = @"detectedTime";
static NSString * const kGOSleepTaskNoonReported = @"noonReported";

@interface GOSleepTask : GODescriptiveTask {
    bool _isWakeupSet;
    bool _isWakeup;
}

@property (nonatomic, retain) NSString *sleepType;

- (bool)isWakeup;
    
@end

@interface GOActiveSleepTask : GOActiveDescriptiveTask

@property (nonatomic, retain) NSDateComponents *abstractTargetTime;

- (NSDate *)detectedTimeForBrew:(GOTaskBrew *)brew;
- (bool)correctBehaviorForBrew:(GOTaskBrew *)brew;
- (bool)noonReportedForBrew:(GOTaskBrew *)brew;
- (NSDate *)targetTimeForBrew:(GOTaskBrew *)brew;
- (void)updateBrew:(GOTaskBrew *)brew sleepState:(GOSleepState *)sleepState;
    
@end