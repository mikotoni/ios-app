//
//  GOSleepTask.m
//  Goalie
//
//  Created by Stefan Kroon on 13-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOSleepTask.h"

// Model
#import "GOGenericModelClasses.h"
#import "TimeWindow.h"
#import "GOSleepState.h"

// Services
#import "GOMainApp.h"
#import "GOTranslation.h"

@implementation GOSleepTask

@dynamic sleepType;

+ (Class)relatedActiveTaskClass {
    return [GOActiveSleepTask class];
}

+ (bool)needsBrewForDisplaying {
    return NO;
}

- (bool)countAsUncompleted {
    return NO;
}

- (bool)isWakeup {
    if(!_isWakeupSet) {
        _isWakeupSet = YES;
        if([self.sleepType isEqualToString:@"wakeup"])
            _isWakeup = YES;
        else
            _isWakeup = NO;
    }
    return _isWakeup;
}

- (NSString *)name {
    GOTranslation *translation = [[GOMainApp sharedMainApp] translation];
    if(!self.isWakeup)
        return [translation translate:@"goal_regular_sleep" string:@"goal_sleep_bedtime_notif_title"];
    else
        return [translation translate:@"goal_regular_sleep" string:@"goal_sleep_waketime_notif_title"];
}

@end




@implementation GOActiveSleepTask

- (NSArray *)getTriggersForBrew:(GOTaskBrew *)brew {
    NSArray *parentTriggers = [super getTriggersForBrew:brew];
    id sleepTask = [self task];
    if([sleepTask isWakeup]) {
        NSDateComponents *abstractUpdateMoment = [[NSDateComponents alloc] init];
        [abstractUpdateMoment setHour:12];
        [abstractUpdateMoment setMinute:15];
        GOAbstractTrigger *abstractTrigger = [[GOAbstractTrigger alloc] init];
        abstractTrigger.abstractMoment = abstractUpdateMoment;
        GOActiveTrigger *updateSleepTrigger = [abstractTrigger concreteTriggerForBrew:brew];
        return [parentTriggers arrayByAddingObject:updateSleepTrigger];
    }
    else
        return parentTriggers;
}

- (NSDate *)detectedTimeForBrew:(GOTaskBrew *)brew {
    return [RESTBody dateWithJSONObject:[brew valueForKey:kGOSleepTaskDetectedTime]];
}

- (NSDate *)targetTimeForBrew:(GOTaskBrew *)brew {
    NSCalendar *curCal = [GOMainApp currentCalendar];
    NSDate *beginDate = [brew beginDate];
    NSDate *startDate = [AbstractTimeWindow startDateForDate:beginDate calendar:curCal aboveUnit:NSDayCalendarUnit];
    NSDate *date = [AbstractTimeWindow dateForStartDate:startDate calendar:curCal components:self.abstractTargetTime];
    if(![brew.timeWindow isDateInWindow:date]) {
        NSDateComponents *nextDay = [[NSDateComponents alloc] init];
        [nextDay setDay:1];
        date = [[GOMainApp currentCalendar] dateByAddingComponents:nextDay toDate:date options:0];
    }
    return date;
}

- (NSString *)activeCellIdentifier {
    return @"ActiveSleepCell";
}

- (bool)correctBehaviorForBrew:(GOTaskBrew *)brew {
    NSNumber *number = [brew valueForKey:kGOSleepTaskCorrectBehavior];
    if(!number)
        return NO;
    return [number boolValue];
}

- (bool)noonReportedForBrew:(GOTaskBrew *)brew {
    NSNumber *number = [brew valueForKey:kGOSleepTaskNoonReported];
    if(!number)
        return NO;
    return [number boolValue];
}

- (void)updateBrew:(GOTaskBrew *)brew sleepState:(GOSleepState *)sleepState {
    GOSleepTask *sleepTask = (id)[self task];
    
    NSDate *sleepDate = [sleepState startDate];
    NSDate *wakeupDate = [sleepState endDate];
    NSDate *detectedDate;
    
    if([sleepTask isWakeup]) {
        detectedDate = wakeupDate;
    }
    else {
        detectedDate = sleepDate;
    }
    
    bool correctBehavior = NO;
    
    GOActiveSleepTask *activeSleepTask = (id)[brew activeTask];
    //[activeSleepTask targetTimeForBrew:brew];
    
    int brewEarnedPoints = 0;
    NSDate *targetTime = [activeSleepTask targetTimeForBrew:brew];
    TimeWindow *hitWindow = [[TimeWindow alloc] initWithBeginDate:brew.beginDate endDate:targetTime];
    if([hitWindow isDateInWindow:detectedDate]) {
        correctBehavior = YES;
        brewEarnedPoints = 8;
    }
    
    [brew setEarnedPointsInteger:brewEarnedPoints];
    [brew setValue:[NSNumber numberWithBool:correctBehavior] forKey:kGOSleepTaskCorrectBehavior];
    [brew setValue:[RESTBody JSONObjectWithDate:detectedDate] forKey:kGOSleepTaskDetectedTime];
    
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    NSDate *nowDate = [mainApp nowDate];
    [brew setCompletionDate:nowDate];
    
    AbstractTimeWindow *abstractNoonWindow = [GOMainApp abstractNoonWindow];
    TimeWindow *noonWindow = [abstractNoonWindow concreteTimeWindowForDate:nowDate];
    if([nowDate compare:noonWindow.beginDate] == NSOrderedDescending && [nowDate compare:targetTime] == NSOrderedDescending) {
        [brew setValue:[NSNumber numberWithBool:YES] forKey:kGOSleepTaskNoonReported];
    }
}

@end
