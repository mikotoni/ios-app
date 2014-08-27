//
//  MoodTask.m
//  Goalie
//
//  Created by Stefan Kroon on 29-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOMoodTask.h"

// Model
#import "GOGenericModelClasses.h"
#import "TimeWindow.h"
#import "GOTaskBrew.h"

// Services
#import "GOMainApp.h"
#import "GOGoalieServices.h"
#import "GOSensePlatform.h"

@implementation GOMoodTask

@dynamic explanation;
//@dynamic pleasure;
//@dynamic arousal;
//@dynamic dominance;
//@dynamic nextRandomCheck;

+ (Class)relatedActiveTaskClass {
    return [GOActiveMoodTask class];
}

- (NSArray *)getTriggersForBrew:(GOTaskBrew *)brew {
    if(![brew hasPastCompletionDate]) {
        NSDate *nextRandomCheck = nil;
        NSString *nextRandomCheckString = [brew valueForKey:kGONextRandomCheck];
        if(nextRandomCheckString)
            nextRandomCheck = [RESTBody dateWithJSONObject:nextRandomCheckString];
        GOActiveTrigger *trigger =[[GOActiveTrigger alloc] initWithDate:nextRandomCheck notificationMessage:@"Vul in hoe je je op dit moment voelt." brew:brew];
        return @[trigger];
    }
    else
        return @[];
}

/*
- (GOActiveTrigger *)getNextActiveTriggerAfter:(NSDate *)afterDate forActiveGoal:(GOActiveGoal *)activeGoal {
    if([activeGoal isKindOfClass:[GOEmotionAwarenessGoal class]]) {
        GOEmotionAwarenessGoal *emoGoal = (GOEmotionAwarenessGoal *)activeGoal;
        GOTaskBrew *brew = [self getBrewsForActiveGoal:activeGoal forDate:afterDate];
        NSString *nextRandomCheckString = [[brew taskResult] valueForKey:kGONextRandomCheck];
        NSDate *nextRandomCheck = nil;
        if(nextRandomCheckString) {
            nextRandomCheck = [RESTBody dateWithJSONObject:nextRandomCheckString];
            if(nextRandomCheck) {
                GOActiveTrigger *activeTrigger =
                    [[GOActiveTrigger alloc] initWithDate:nextRandomCheck];
                return activeTrigger;
            }
        }
        if(brew) {
            nextRandomCheck = [brew]
            
            if([self.nextRandomCheck isKindOfClass:[NSDate class]]) {
                if(![firstWindow isDateInWindow:self.nextRandomCheck]) {
                    if(![secondWindow isDateInWindow:self.nextRandomCheck]) {
                        self.nextRandomCheck = [firstWindow getRandomDateInWindow];
                        [self save];
                    }
                }
            }
            else {
                self.nextRandomCheck = [firstWindow getRandomDateInWindow];
                [self save];
            }
            if([self.nextRandomCheck compare:afterDate] == NSOrderedDescending) {
            }
            else {
                self.nextRandomCheck = [secondWindow getRandomDateInWindow];
                [self save];
            }
        }
        else
            return nil;
    }
    else
        return nil;
}
*/

- (NSArray *)getBrewsForActiveGoal:(GOActiveGoal *)activeGoal  {
    TimeWindow * __block activeGoalTimeWindow = [activeGoal timeWindow];
    [activeGoal configureActiveTask:[self activeTaskForActiveGoal:activeGoal]];
    
    NSArray *storedBrews = [activeGoal getStoredBrewsForTask:self];
    
    NSMutableDictionary *visibleWindows = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *notifWindows = [[NSMutableDictionary alloc] init];
    
    
    
    [self.abstractVisibleWindows enumerateObjectsUsingBlock:^(AbstractTimeWindow *abstractVisibleWindow, NSUInteger idx, BOOL *stop) {
        NSDate *curDate = [activeGoalTimeWindow beginDate];
        while(1) {
            TimeWindow *visibleWindow = [abstractVisibleWindow firstValidTimeWindowFromDate:curDate allowStarted:NO];
            if([activeGoalTimeWindow isDateInWindow:[visibleWindow beginDate]]) {
                NSDate *key = [visibleWindow beginDate];
                [visibleWindows setObject:visibleWindow forKey:key];
                curDate = [visibleWindow endDate];
            }
            else
                break;
        }
    }];
    
    [self.abstractNotificationWindows enumerateObjectsUsingBlock:^(AbstractTimeWindow *abstractNotifWindow, NSUInteger idx, BOOL *stop) {
        NSDate *curDate = [activeGoalTimeWindow beginDate];
        while(1) {
            TimeWindow *notifWindow = [abstractNotifWindow firstValidTimeWindowFromDate:curDate allowStarted:NO];
            if([activeGoalTimeWindow isDateInWindow:[notifWindow beginDate]]) {
                NSDate *key = [notifWindow beginDate];
                [notifWindows setObject:notifWindow forKey:key];
                curDate = [notifWindow endDate];
            }
            else
                break;
            
        }
        
    }];
    
    NSMutableArray *brewsOut = [[NSMutableArray alloc] initWithCapacity:[visibleWindows count]];
    NSArray *sortedKeys = [[visibleWindows allKeys] sortedArrayUsingSelector:@selector(compare:)];
    [sortedKeys enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
        GOTaskBrew *brew = nil;
        if([storedBrews count] > idx)
            brew = [storedBrews objectAtIndex:idx];
        if(!brew) {
            TimeWindow *visibleWindow = [visibleWindows objectForKey:key];
            brew = [[GOTaskBrew alloc] initWithTimeWindow:visibleWindow
                                               activeGoal:activeGoal
                                                     task:self
                                               occurrence:idx];
            TimeWindow *notifWindow = [notifWindows objectForKey:key];
            NSDate *nextRandomCheck = [notifWindow getRandomDateInWindow];
            [brew setValue:[RESTBody JSONObjectWithDate:nextRandomCheck] forKey:kGONextRandomCheck];
            [brew save];
        }
        [brewsOut addObject:brew];
    }];
    
    return brewsOut;
}

@end

@implementation GOActiveMoodTask

- (void)updateBrew:(GOTaskBrew *)brew pleasure:(NSNumber *)pleasure arousal:(NSNumber *)arousal dominance:(NSNumber *)dominance {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    [brew setValue:pleasure forKey:@"pleusure"];
    [brew setValue:arousal forKey:@"arousal"];
    [brew setValue:dominance forKey:@"dominance"];
    [brew setCompletionDate:[mainApp nowDate]];
    [brew setEarnedPointsInteger:7];
    [brew dirtTriggers];
    [[mainApp sensePlatform] addEmotionDataPointWithPleasure:pleasure arousal:arousal dominance:dominance];
    [[mainApp goalieServices] programLocalNotifications];
}

- (NSString *)activeCellIdentifier {
    return @"ActiveMoodCell";
}

- (NSString *)titleForBrew:(GOTaskBrew *)brew {
    NSDate *nowDate = [[GOMainApp sharedMainApp] nowDate];
    NSString *relativeString = [brew.timeWindow relativeDescriptionFromDate:nowDate];
    return [NSString stringWithFormat:NSLocalizedString(@"%@", nil), relativeString];
}

@end

