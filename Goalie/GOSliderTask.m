//
//  GOSliderTask.m
//  Goalie
//
//  Created by Stefan Kroon on 28-06-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOSliderTask.h"

// Model
#import "GOGenericModelClasses.h"

// Services
#import "GOMainApp.h"
#import "GOGoalieServices.h"

@implementation GOSliderTask

+ (Class)relatedActiveTaskClass {
    return [GOActiveSliderTask class];
}

- (bool)countAsUncompleted {
    return NO;
}


- (void)setTriggerInterval:(NSTimeInterval)triggerInterval {
    _triggerInterval = triggerInterval;
    [[[GOMainApp sharedMainApp] goalieServices] programLocalNotifications];
}

- (NSArray *)getTriggersForBrew:(GOTaskBrew *)brew {
    if(self.triggerInterval <= 0.0)
        return @[];
    NSDate *curDate = [[GOMainApp sharedMainApp] nowDate];
    NSMutableArray *triggers = [[NSMutableArray alloc] initWithCapacity:12];
    for(int i = 0; i < 12; i++) {
        curDate = [curDate dateByAddingTimeInterval:self.triggerInterval];
        GOActiveTrigger *trigger = [[GOActiveTrigger alloc] initWithDate:curDate notificationMessage:@"Wat is je spanning nu?" brew:brew];
        [triggers addObject:trigger];
    }
    return triggers;
}

@dynamic rangeStart;
@dynamic rangeEnd;
@dynamic question;

@end


@implementation GOActiveSliderTask {
    AbstractTimeWindow *_abstractVisibleWindow;
}

- (AbstractTimeWindow *)abstractTaskWindow {
    if(!_abstractVisibleWindow) {
        _abstractVisibleWindow = [self abstractWeekTask];
    }
    return _abstractVisibleWindow;
}

- (NSString *)activeCellIdentifier {
    return @"ActiveSliderCell";
}

- (NSNumber *)actualValueForBrew:(GOTaskBrew *)brew {
    return [brew valueForKey:@"actualValue"];
}

- (void)updateBrew:(GOTaskBrew *)brew withValue:(NSNumber *)value {
    [brew setValue:value forKey:kGOSliderActualValue];
    [brew setCompletionDate:[[GOMainApp sharedMainApp] nowDate]];
    [brew.activeGoal didUpdateBrew:brew];
}

@end