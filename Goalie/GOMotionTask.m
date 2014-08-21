//
//  GOMotionTask.m
//  Goalie
//
//  Created by Stefan Kroon on 08-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOMotionTask.h"

// Model
#import "GOGenericModelClasses.h"
#import "TimeWindow.h"

// Services
#import "GOMainApp.h"
#import "GOSensePlatform.h"
#import "GOGoalieServices.h"
#import "GOTestFlight.h"

@implementation GOMotionTask

+ (Class)relatedActiveTaskClass {
    return [GOActiveMotionTask class];
}

- (bool)countAsUncompleted {
    return NO;
}

- (NSArray *)getTriggersForBrew:(GOTaskBrew *)brew {
    NSDate *triggerDate =[brew beginDate];
    GOActiveTrigger *trigger = [[GOActiveTrigger alloc] initWithDate:triggerDate needsFire:YES brew:brew];
    return @[trigger];
}

@end

@implementation GOActiveMotionTask

- (NSTimeInterval)timeActiveIntervalFromBrew:(GOTaskBrew *)brew {
    NSNumber *number = [brew valueForKey:kGOTimeActiveInterval];
    if(number)
        return [number floatValue];
    else
        return 0.0;
}

- (AbstractTimeWindow *)abstractTaskWindow {
    return [[AbstractTimeWindow alloc] initWithBeginHour:2 minute:0 endHour:25 endMinute:59];
}

- (void)updateBrew:(GOTaskBrew *)brew timeActiveInterval:(NSTimeInterval)newTimeActiveInterval {
    
    NSNumber *dailyTarget = [self dailyTargetInSeconds];
    NSTimeInterval dailyTargetInterval = [dailyTarget floatValue];
    bool notifyTaskDone = NO;
    
    // Reset the activity to 0 once for every brew
    NSString *activityResetDate = [brew valueForKey:kGOActivityResetDate];
    if(!activityResetDate) {
        [TestFlight passCheckpoint:@"Time Active Reset"];
        newTimeActiveInterval = 0;
        [[[GOMainApp sharedMainApp] sensePlatform] resetTimeActiveSensor];
        activityResetDate = [RESTBody JSONObjectWithDate:[[GOMainApp sharedMainApp] nowDate]];
        [brew setValue:activityResetDate forKey:kGOActivityResetDate];
    }
    else {
        NSTimeInterval oldTimeActiveInterval = [self timeActiveIntervalFromBrew:brew];
        
        if(oldTimeActiveInterval < dailyTargetInterval && newTimeActiveInterval >= dailyTargetInterval) {
            [brew setEarnedPointsInteger:10];
            [brew setCompletionDate:[[GOMainApp sharedMainApp] nowDate]];
            notifyTaskDone = YES;
        }
    }
    
    NSNumber *newTimeActiveNumber = [NSNumber numberWithFloat:newTimeActiveInterval];
    [brew setValue:newTimeActiveNumber forKey:kGOTimeActiveInterval];
    
    if(notifyTaskDone) {
        GOGoalieServices *goalieServices = [[GOMainApp sharedMainApp] goalieServices];
        [goalieServices deliverLocalNotificationForBrew:brew title:@"Bewegingsdoel gehaald" body:@"Bewegingsdoel voor vandaag behaald! Goed gedaan!"];
    }
}

- (void)fireWithBrew:(GOTaskBrew *)brew {
    GOActiveMotionTask *activeMotionTask = (id)brew.activeTask;
    [activeMotionTask updateBrew:brew timeActiveInterval:0];
    [brew save];
}

- (NSString *)activeCellIdentifier {
    return @"ActiveMotionCell";
}

@end
