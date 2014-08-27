//
//  GOMealTask.m
//  Goalie
//
//  Created by Stefan Kroon on 23-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOMealTask.h"

// Model
#import "GOTaskBrew.h"
#import "TimeWindow.h"
#import "GOActiveTrigger.h"

// Services
#import "GOMainApp.h"
#import "GOGoalieServices.h"

@implementation GOMealTask

NSString *const GOMealTaskBreakfast = @"breakfast";
NSString *const GOMealTaskLunch = @"lunch";
NSString *const GOMealTaskDinner = @"dinner";

#ifdef USE_COREDATA
+ (GOMealTask *)mealTaskInManagedObjectContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:@"MealTask" inManagedObjectContext:context];
}
#endif

@dynamic kind;
//@dynamic pointInTime;
//@dynamic done;

- (NSString *)triggerMessageForKind:(NSString *)kind {
    if([kind isEqualToString:GOMealTaskBreakfast])
        return NSLocalizedString(@"Vergeet niet om je ontbijt in te vullen.", nil);
    else if([kind isEqualToString:GOMealTaskLunch])
        return NSLocalizedString(@"Vergeet niet om je lunch in te vullen.", nil);
    else
        return NSLocalizedString(@"Vergeet niet om je avondeten in te vullen.", nil);
}

- (NSDateComponents *)getMealHourMinuteByActiveGoal:(GOActiveGoal *)activeGoal {
    GOActiveMealTask *activeMealTask = (id)[self activeTaskForActiveGoal:activeGoal];
    return [activeMealTask abstractMealMoment];
}

- (NSArray *)getTriggersForBrew:(GOTaskBrew *)brew {
    GOActiveMealTask *activeMealTask = [[GOActiveMealTask alloc] initWithBrew:brew];
    NSArray *triggers  = nil;
    if(![brew hasPastCompletionDate]) {
        NSDate *triggerDate = [activeMealTask mealMomentForBrew:brew];
        NSString *triggerMessage = [self triggerMessageForKind:[self kind]];
        GOActiveTrigger *trigger = [[GOActiveTrigger alloc] initWithDate:triggerDate notificationMessage:triggerMessage brew:brew];
        triggers = @[trigger];
    }
    
    return triggers;
}

/*
- (GOActiveTrigger *)getNextActiveTriggerAfter:(NSDate *)afterDate forActiveGoal:(GOActiveGoal *)activeGoal {
    AbstractTimeWindow *abstractMealWindow = [self getAbstractMealWindowForActiveGoal:activeGoal];
    TimeWindow *concreteMealWindow = [abstractMealWindow firstValidTimeWindowFromDate:afterDate];
    NSDate *triggerDate = [concreteMealWindow endDate];
    GOActiveTrigger *activeTrigger = [[GOActiveTrigger alloc] initWithDate:triggerDate];
    return activeTrigger;
}
*/

- (NSDate *)pointInTimeForBrew:(GOTaskBrew *)brew {
    return [RESTBody dateWithJSONObject:[brew valueForKey:kGOPointInTime]];
}

- (bool)isDoneForBrew:(GOTaskBrew *)brew {
    return [[brew valueForKey:kGODone] boolValue];
}

+ (Class)relatedActiveTaskClass {
    return [GOActiveMealTask class];
}

@end

@implementation GOActiveMealTask

- (id)initWithTask:(GOMealTask *)mealTask activeGoal:(GOActiveGoal *)activeGoal {
    self = [super initWithTask:mealTask activeGoal:activeGoal];
    if(self) {
        _leadingHours = 1;
        _trailingHours = 9;
        _leadingBonusHours = 1;
        _trailingBonusHours = 1;
    }
    return self;
}

- (void)updateBrew:(GOTaskBrew *)brew done:(bool)done pointInTime:(NSDate *)pointInTime {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    [brew setValue:[NSNumber numberWithBool:done] forKey:kGODone];
    [brew setValue:[RESTBody JSONObjectWithDate:pointInTime] forKey:kGOPointInTime];
    [brew setCompletionDate:[mainApp nowDate]];
    AbstractTimeWindow *abstractBonusWindow = [self abstractBonusWindow];
    NSUInteger earnedPoints = 0;
    if(done) {
        if([abstractBonusWindow isDateInWindow:pointInTime]) {
            earnedPoints = 6;
        }
        else {
            earnedPoints = 2;
        }
    }
    
    [brew setEarnedPointsInteger:earnedPoints];
    [brew dirtTriggers];
    [[mainApp goalieServices] programLocalNotifications];
}
       

- (AbstractTimeWindow *)abstractBonusWindow {
    if(!_abstractBonusWindow) {
        NSDateComponents *abstractMealMoment = [self abstractMealMoment];
        _abstractBonusWindow =
            [[AbstractTimeWindow alloc] initWithBeginHour:[abstractMealMoment hour]-_leadingBonusHours
                                                   minute:[abstractMealMoment minute]
                                                  endHour:[abstractMealMoment hour]+_trailingBonusHours
                                                endMinute:[abstractMealMoment minute]];
    }
    return _abstractBonusWindow;
    
}

- (AbstractTimeWindow *)abstractTaskWindow {
    if(!_abstractMealWindow) {
        NSDateComponents *abstractMealMoment = [self abstractMealMoment];
        _abstractMealWindow =
            [[AbstractTimeWindow alloc] initWithBeginHour:[abstractMealMoment hour]-_leadingHours
                                                   minute:[abstractMealMoment minute]
                                                  endHour:[abstractMealMoment hour]+_trailingHours
                                                endMinute:[abstractMealMoment minute]];
    }
    return _abstractMealWindow;
}


- (NSDate *)mealMomentForBrew:(GOTaskBrew *)brew {
    NSCalendar *curCal = [GOMainApp currentCalendar];
    NSDateComponents *abstractMealMoment = [self abstractMealMoment];
    NSDate *startDate = [AbstractTimeWindow startDateForDate:[brew beginDate] calendar:curCal aboveUnit:NSDayCalendarUnit];
    NSDate *mealMoment = [AbstractTimeWindow dateForStartDate:startDate calendar:curCal components:abstractMealMoment];
    
    return mealMoment;
}

- (NSString *)activeCellIdentifier {
    return @"ActiveMealCell";
}

- (NSString *)titleForBrew:(GOTaskBrew *)brew {
    GOMealTask *mealTask = (id)self.task;
    NSString *kind = mealTask.kind;
    if([kind isEqualToString:GOMealTaskBreakfast])
        return NSLocalizedString(@"Ontbijten", nil);
    else if([kind isEqualToString:GOMealTaskLunch])
        return NSLocalizedString(@"Lunchen" , nil);
    else
        return NSLocalizedString(@"Avondeten", nil);
}



@end