//
//  GOActiveTask.m
//  Goalie
//
//  Created by Stefan Kroon on 13-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveTask.h"
#import "GOGenericModelClasses.h"
#import "TimeWindow.h"

@implementation GOActiveTask


 - (id)initWithBrew:(GOTaskBrew *)brew {
    return [self initWithTask:(id)[brew task] activeGoal:[brew activeGoal]];
}

- (id)initWithTask:(GOTask *)task activeGoal:(GOActiveGoal *)activeGoal {
    self = [super init];
    if(self) {
        _activeGoal = activeGoal;
        _task = task;
        if([[_activeGoal document] isDeleted])
            return nil;
        [_activeGoal configureActiveTask:self];
    }
    return self;
}
                                    
- (void)fireWithBrew:(GOTaskBrew *)brew {
    NSLog(@"WARNING: %s fire not implemented for this task (%@)", __PRETTY_FUNCTION__, [self class]);
}

- (NSString *)activeCellIdentifier {
    return @"ActiveTaskCell";
}

- (NSString *)titleForBrew:(GOTaskBrew *)brew {
    return @"-- ** --";
}

- (AbstractTimeWindow *)abstractWeekTask {
    /*
     NSCalendar *curCal = [GOMainApp currentCalendar];
     TimeWindow *timeWindow = [GOMainApp activeGoalTimeWindow];
     NSCalendarUnit calUnit = NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
     NSDateComponents *beginDateComponents = [curCal components:calUnit fromDate:timeWindow.beginDate];
     NSDateComponents *endDateComponents = [curCal components:calUnit fromDate:timeWindow.endDate];
     */
    NSDateComponents *beginDateComponents = [[NSDateComponents alloc] init];
    beginDateComponents.weekday = 1;
    beginDateComponents.hour = 3;
    beginDateComponents.minute = 0;
    AbstractTimeWindow *abstractWeekWindow = [[AbstractTimeWindow alloc]
                            initWithBeginComponents:beginDateComponents
                            endComponents:beginDateComponents
                            aboveUnit:NSWeekCalendarUnit];
    return abstractWeekWindow;
}


@end
