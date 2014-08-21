//
//  Task.m
//  Goalie
//
//  Created by Stefan Kroon on 06-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOMainApp.h"

// Model
#import "GOGenericModelClasses.h"
#import "TimeWindow.h"

// Services
#import "GOGoalieServices.h"

// External
#import "objc/runtime.h"

@implementation GOTask


@dynamic manual;
@dynamic name;
@dynamic goal;
@dynamic groupedTask;
@dynamic groupMainTask;
@dynamic indexNumber;

+ (Class)relatedActiveTaskClass {
    return [GOActiveTask class];
}

- (bool)countAsUncompleted {
    return YES;
}

- (GOActiveTask *)activeTaskForActiveGoal:(GOActiveGoal *)activeGoal {
    Class activeTaskClass = [[self class] relatedActiveTaskClass];
    return [[activeTaskClass alloc] initWithTask:self activeGoal:activeGoal];
}

+ (bool)needsBrewForDisplaying {
    return YES;
}

- (NSArray *)getBrewsForActiveGoal:(GOActiveGoal *)activeGoal activeTask:(GOActiveTask *)activeTask {

    NSMutableArray *brews = [[NSMutableArray alloc] init];
    
    TimeWindow *activeGoalTimeWindow = [activeGoal timeWindow];
    NSDate *curDate = [activeGoalTimeWindow beginDate];
    NSArray *storedBrews = [activeGoal getStoredBrewsForTask:self];
    NSMutableArray *propertiesToSave = nil;
    
    static const int maxNofOccurrences = 64;
    NSUInteger currentOccurrence;
    for(currentOccurrence = 0; currentOccurrence < maxNofOccurrences; currentOccurrence++) {
        GOTaskBrew *brew = nil;
        TimeWindow *brewTimeWindow = nil;
        if([storedBrews count] > currentOccurrence) {
            brew = [storedBrews objectAtIndex:currentOccurrence];
            brewTimeWindow = [brew timeWindow];
        }
        else {
            brewTimeWindow = [activeTask.abstractTaskWindow firstValidTimeWindowFromDate:curDate allowStarted:NO];
            NSDate *brewTimeWindowBeginDate = [brewTimeWindow beginDate];
            if(![activeGoalTimeWindow isDateInWindow:brewTimeWindowBeginDate]) {
                break;
            }
            brew = [[GOTaskBrew alloc] initWithTimeWindow:brewTimeWindow
                                                       activeGoal:activeGoal
                                                             task:self
                                                       occurrence:currentOccurrence];
            
            if(!propertiesToSave)
                propertiesToSave = [[NSMutableArray alloc] init];
            [propertiesToSave addObject:[brew propertiesToSave]];
        }
    
        [brews addObject:brew];
        curDate = [brewTimeWindow endDate];
    }
    
    if(currentOccurrence >= maxNofOccurrences)
        NSLog(@"WARNING: %s Too many occurrences for task %@", __PRETTY_FUNCTION__, self.name);
    
    if(propertiesToSave) {
        [activeGoal dirtStoredBrewsForTask:self];
        //GOCouchCocoa *couchCocoa = [[GOMainApp sharedMainApp] couchCocoa];
        GOGoalieServices *goalieServices = [[GOMainApp sharedMainApp] goalieServices];
        [goalieServices putChanges:propertiesToSave];
    }
    
    return brews;
}

- (NSArray *)getTriggersForBrew:(GOTaskBrew *)brew {
    //NSLog(@"WARNING: %s Function not implementend for this task: %@", __PRETTY_FUNCTION__, [self class]);
    //const char *className = class_getName([[brew task] class]);
    //NSLog(@"%s %s does not have triggers", __PRETTY_FUNCTION__, className);
    return @[];
}

- (NSArray *)getBrewsForActiveGoal:(GOActiveGoal *)activeGoal {
    Class relatedActiveTaskClass = [[self class] relatedActiveTaskClass];
    NSArray *brews = @[];
    if(!relatedActiveTaskClass) {
        NSLog(@"WARNING: %s No related active task found.", __PRETTY_FUNCTION__);
    }
    else {
        GOActiveTask *activeTask = [[relatedActiveTaskClass alloc] initWithTask:self activeGoal:activeGoal];
        brews = [self getBrewsForActiveGoal:activeGoal activeTask:activeTask];
    }
    return brews;
}

- (NSString *)taskName {
    NSString *className = NSStringFromClass([self class]);
    NSString *taskName = [className substringFromIndex:2];
    return taskName;
}

- (NSString *)title {
    return NSLocalizedString(self.name, nil);
}

@end
