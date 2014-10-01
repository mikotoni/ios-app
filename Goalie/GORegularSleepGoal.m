//
//  GORegularSleepGoal.m
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GORegularSleepGoal.h"

// Model
#import "GOGenericModelClasses.h"
#import "TimeWindow.h"
#import "GOSleepTask.h"


// Services
#import "GOMainApp.h"
#import "GOTranslation.h"

@implementation GORegularSleepGoal

@dynamic sleep, wakeup;

- (UIColor*)colorProgress{
    return UIColorFromRGB(0xfca503);
}
- (int)loadingHeight{
    return 90;
}
- (NSString *)progressSensorName {
    return @"regular_sleep_progress";
}

- (void)configureActiveTask:(GOActiveTask *)activeTask {
    NSString *text = @"Geen beschrijving gevonden";
    
    id activeDescriptiveTask = activeTask;
    id descriptiveTask = [activeTask task];
    if(![descriptiveTask respondsToSelector:@selector(text)])
        NSLog(@"WARNING: %s assumed descriptiveTask doesn't respond to task", __PRETTY_FUNCTION__);
    else
        text = [descriptiveTask text];
    
    id sleepTask = [activeTask task];
    if(![sleepTask respondsToSelector:@selector(isWakeup)])
        NSLog(@"WARNING: %s assumed sleepTask doesn't resond to isWakeup", __PRETTY_FUNCTION__);
    else {
        bool isWakeup = [sleepTask isWakeup];
        NSString *timeString = (isWakeup ? self.wakeup : self.sleep);
        NSString *newText = [text stringByReplacingOccurrencesOfString:@"<time>" withString:timeString];
        
        if(![activeDescriptiveTask respondsToSelector:@selector(setText:)])
            NSLog(@"WARNING: %s assumed descriptionTask doesn't respond to setText", __PRETTY_FUNCTION__);
        else
            [activeDescriptiveTask setText:newText];
        
        NSDateComponents *abstractTextMoment = [AbstractTimeWindow abstractFromHourMinuteString:timeString];
        id activeSleepTask = activeTask;
        if(![activeSleepTask respondsToSelector:@selector(setAbstractTargetTime:)])
            NSLog(@"WARNING: %s assumed activeSleepTask doesn't respond to setAbstractTargetTime", __PRETTY_FUNCTION__);
        else
            [activeSleepTask setAbstractTargetTime:abstractTextMoment];
        
        NSDateComponents *abstractBegin = [abstractTextMoment copy];
        NSDateComponents *abstractEnd = [abstractTextMoment copy];
        if(![sleepTask isWakeup]) {
            abstractBegin.hour = 15;
            abstractEnd.hour = 15 + 24;
        }
        else {
            abstractBegin.hour = 18 - 24;
            abstractEnd.hour = 18;
        }
        
        AbstractTimeWindow *abstractTimeWindow = [[AbstractTimeWindow alloc] initWithBeginComponents:abstractBegin
                                                                                       endComponents:abstractEnd
                                                                                           aboveUnit:NSDayCalendarUnit];
        if(![activeDescriptiveTask respondsToSelector:@selector(setAbstractTaskWindow:)])
            NSLog(@"WARNING: %s assumed descriptionTask doesn't respond to setAbstractTaskWindow", __PRETTY_FUNCTION__);
        else
            [activeDescriptiveTask setAbstractTaskWindow:abstractTimeWindow];
        
        NSDateComponents *abstractAlarmMoment = [abstractTextMoment copy];
        if(![sleepTask isWakeup])
            abstractAlarmMoment.minute -= 30;
        
        if(![activeDescriptiveTask respondsToSelector:@selector(setAbstractTriggers:)])
            NSLog(@"WARNING: %s assumed descriptionTask doesn't respond to setAbstractTriggers", __PRETTY_FUNCTION__);
        else {
            GOAbstractTrigger *abstractTrigger = [[GOAbstractTrigger alloc] init];
            [abstractTrigger setAbstractMoment:abstractAlarmMoment];
            [abstractTrigger setNotificationMessage:newText];
            [activeDescriptiveTask setAbstractTriggers:@[abstractTrigger]];
        }
    }
    
    return;
}

- (NSString *)description {
    return [[[GOMainApp sharedMainApp] translation] translate:@"goal_regular_sleep" string:@"goal_descr_regular_sleep"];
}
- (NSString *)explanation {
    return [[[GOMainApp sharedMainApp] translation] translate:@"goal_regular_sleep" string:@"goal_help_regular_sleep"];
}

- (NSString *)title {
    GOTranslation *translation = [[GOMainApp sharedMainApp] translation];
    return [translation translate:@"goal_regular_sleep" string:@"goal_title_regular_sleep"];
}

@end
