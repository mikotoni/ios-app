//
//  GOActiveTrigger.m
//  Goalie
//
//  Created by Stefan Kroon on 04-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOGenericModelClasses.h"
#import "GOMainApp.h"
#import "TimeWindow.h"

@implementation GOActiveTrigger

- (id)initWithDate:(NSDate *)triggerDate notificationMessage:(NSString *)message brew:(GOTaskBrew *)brew {
    self = [super init];
    if(self) {
        _pointInTime = triggerDate;
        _notificationMessage = message;
        _brew = brew;
    }
    return self;
}

- (id)initWithDate:(NSDate *)triggerDate needsFire:(BOOL)needsFire brew:(GOTaskBrew *)brew {
    self = [super init];
    if(self) {
        _pointInTime = triggerDate;
        _brew = brew;
        _needsFire = needsFire;
    }
    return self;
}

- (void)firedByTimer:(NSTimer *)timer {
    GOTaskBrew *brew = self.brew;
    [brew.activeTask fireWithBrew:brew];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GOActiveTrigger>: pointInTime:%@ needsFire:%@ notificationMessage:%@", _pointInTime, (_needsFire ? @"YES" : @"NO"), _notificationMessage];
}

@end

@implementation GOAbstractTrigger

- (GOActiveTrigger *)concreteTriggerForBrew:(GOTaskBrew *)brew {
    NSCalendar *curCal = [GOMainApp currentCalendar];
    NSDate *startDate = [AbstractTimeWindow startDateForDate:[brew beginDate]
                                                    calendar:curCal
                                                   aboveUnit:NSDayCalendarUnit];
    
    NSDate *triggerDate = [AbstractTimeWindow dateForStartDate:startDate
                                                      calendar:curCal
                                                    components:self.abstractMoment];
    GOActiveTrigger *trigger = nil;
    if(self.notificationMessage)
        trigger = [[GOActiveTrigger alloc] initWithDate:triggerDate notificationMessage:self.notificationMessage brew:brew];
    else
        trigger = [[GOActiveTrigger alloc] initWithDate:triggerDate needsFire:YES brew:brew];
    return trigger;
}

@end