//
//  GOEmotionAwarenessGoal.m
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOEmotionAwarenessGoal.h"

// Model
#import "GOGenericModelClasses.h"
#import "TimeWindow.h"
#import "GOMoodTask.h"

// Services
#import "GOMainApp.h"
#import "GOTranslation.h"


@implementation GOEmotionAwarenessGoal

- (UIColor*)colorProgress{
    return UIColorFromRGB(0xb16eff);
}
- (int)loadingHeight{
    return 82;
}
- (NSString *)progressSensorName {
    return @"emotion_awareness_progress";
}

- (NSArray *)abstractNotificationWindows {
    static NSArray *timeWindows = nil;
    if(!timeWindows) {
        AbstractTimeWindow *morningWindow = [AbstractTimeWindow windowWithBeginHour:9 minute:0 endHour:12 minute:0];
        AbstractTimeWindow *noonWindow = [AbstractTimeWindow windowWithBeginHour:13 minute:0 endHour:17 minute:0];
        AbstractTimeWindow *eveningWindow = [AbstractTimeWindow windowWithBeginHour:18 minute:0 endHour:21 minute:0];
        timeWindows = @[morningWindow, noonWindow, eveningWindow];
    }
    return timeWindows;
}

- (NSArray *)abstractVisibleWindows {
    static NSArray *timeWindows = nil;
    if(!timeWindows) {
        AbstractTimeWindow *morningWindow = [AbstractTimeWindow windowWithBeginHour:5 minute:0 endHour:12 minute:0];
        AbstractTimeWindow *noonWindow = [AbstractTimeWindow windowWithBeginHour:12 minute:0 endHour:18 minute:0];
        AbstractTimeWindow *eveningWindow = [AbstractTimeWindow windowWithBeginHour:18 minute:0 endHour:5+24 minute:0];
        timeWindows = @[morningWindow, noonWindow, eveningWindow];
    }
    return timeWindows;
}

- (TimeWindow *)getNextTimeWindowForDate:(NSDate *)forDate {
    NSArray *abstractTimeWindows = [self abstractVisibleWindows];
    NSMutableArray *validTimeWindows =
        [[NSMutableArray alloc] initWithCapacity:[abstractTimeWindows count]];
    
    [abstractTimeWindows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        AbstractTimeWindow *abstractWindow = obj;
        TimeWindow *validTimeWindow = [abstractWindow firstValidTimeWindowFromDate:forDate allowStarted:NO];
        [validTimeWindows addObject:validTimeWindow];
    }];
    
    TimeWindow * __block bestTimeWindow = nil;
    [validTimeWindows enumerateObjectsUsingBlock:^(id currentWindow, NSUInteger idx, BOOL *stop) {
        if(!bestTimeWindow)
            bestTimeWindow = currentWindow;
        else {
            NSDate *bestBegin = [bestTimeWindow beginDate];
            NSDate *currentBegin = [currentWindow beginDate];
            if([bestBegin compare:currentBegin] == NSOrderedDescending)
                bestTimeWindow = currentWindow;
        }
    }];
    return bestTimeWindow;
}

- (void)configureActiveTask:(GOActiveTask *)activeTask {
    id moodTask = [activeTask task];
    if([moodTask respondsToSelector:@selector(setAbstractNotificationWindows:)])
        [moodTask setAbstractNotificationWindows:[self abstractNotificationWindows]];
    else
        NSLog(@"WARNING: %s assumed moodTask doesn't respond to setAbstractNotificationWindows", __PRETTY_FUNCTION__);
    
    if([moodTask respondsToSelector:@selector(setAbstractVisibleWindows:)])
        [moodTask setAbstractVisibleWindows:[self abstractVisibleWindows]];
    else
        NSLog(@"WARNING: %s assumed moodTask doesn't respond to setAbstractVisibleWindows", __PRETTY_FUNCTION__);
}

- (NSString *)description {
    return [[[GOMainApp sharedMainApp] translation] translate:@"goal_emotion_awareness" string:@"goal_descr_emotion_awareness"];
}

- (NSString *)explanation {
    return [[[GOMainApp sharedMainApp] translation] translate:@"goal_emotion_awareness" string:@"goal_help_emotion_awareness"];
}

- (NSString *)title {
    GOTranslation *translation = [[GOMainApp sharedMainApp] translation];
    return [translation translate:@"goal_emotion_awareness" string:@"goal_title_emotion_awareness"];
}


@end
