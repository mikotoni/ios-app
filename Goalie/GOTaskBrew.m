//
//  GOTaskBrew.m
//  Goalie
//
//  Created by Stefan Kroon on 04-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOMainApp.h"
#import "GOCouchCocoa.h"
#import "GOGenericModelClasses.h"
#import "GOGoalieServices.h"
#import "TimeWindow.h"

@implementation GOTaskBrew

@dynamic beginDate, endDate, earnedPoints, activeGoal, task, type, occurrenceIndex, taskResult;
@dynamic completedDate;

- (void)setValue:(id)value forKey:(NSString *)key {
    if(!_mutableTaskResult) {
        NSDictionary *taskResult = self.taskResult;
        if(taskResult)
            _mutableTaskResult = [taskResult mutableCopy];
        else
            _mutableTaskResult = [[NSMutableDictionary alloc] init];
    }
    [_mutableTaskResult setValue:value forKey:key];
    self.taskResult = _mutableTaskResult;
}

- (id)valueForKey:(NSString *)key {
    return [self.taskResult valueForKey:key];
}

- (id)getTaskWithClass:(Class)klass {
    GOTask *task = [self task];
    if([task isKindOfClass:klass])
        return task;
    return nil;
}

- (GOActiveTask *)activeTask {
    GOTask *task = self.task;
    GOActiveGoal *activeGoal = self.activeGoal;
    return [task activeTaskForActiveGoal:activeGoal];
}

- (id)initWithTimeWindow:(TimeWindow *)timeWindow activeGoal:(GOActiveGoal *)activeGoal task:(GOTask *)task occurrence:(NSUInteger)occurrence {
    GOGoalieServices *goalieServices = [[GOMainApp sharedMainApp] goalieServices];
    CouchDatabase *database = [goalieServices database];
    self = [super initWithNewDocumentInDatabase:database];
    if(self) {
        self.beginDate = [timeWindow beginDate];
        self.endDate = [timeWindow endDate];
        self.earnedPoints = [NSNumber numberWithInt:0];
        self.task = task;
        self.activeGoal = activeGoal;
        self.occurrenceIndex = [NSNumber numberWithUnsignedInteger:occurrence];
        self.type = @"TaskBrew";
    }
    return self;
}

- (TimeWindow *)timeWindow {
    if(!_timeWindow)
        _timeWindow = [[TimeWindow alloc] initWithBeginDate:self.beginDate endDate:self.endDate];
    return _timeWindow;
}

- (void)setEarnedPointsInteger:(NSUInteger)points {
    self.earnedPoints = [NSNumber numberWithUnsignedInteger:points];
}

- (NSString *)beginString {
    return [RESTBody JSONObjectWithDate:self.beginDate];
}

- (NSString *)endString {
    return [RESTBody JSONObjectWithDate:self.endDate];
}

- (void)setBeginString:(NSString *)beginString {
    [self setBeginDate:[RESTBody dateWithJSONObject:self.beginString]];
}

- (void)setEndString:(NSString *)endString {
    [self setEndDate:[RESTBody dateWithJSONObject:self.endString]];
}

- (RESTOperation *)save {
    RESTOperation *op = [super save];
    [self.activeGoal dirtStoredBrewsForTask:self.task];
    return op;
}

- (NSArray *)triggers {
    if(!_triggers) {
        _triggers = [self.task getTriggersForBrew:self];
    }
    return _triggers;
}

- (void)dirtTriggers {
    _triggers = nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"GOTaskBrew[%@] begin:%@ end:%@ earnedPoints:%d occurence:%d",
            [self.document abbreviatedID],
            self.beginDate, self.endDate,
            [self.earnedPoints intValue],
            [self.occurrenceIndex intValue]];
}

- (void)resetCompletionDate {
    NSDate *distantFuture = [NSDate dateWithTimeIntervalSinceNow:60.0 * 60.0 * 24.0 * 365 * 10];
    [self setCompletedDate:distantFuture];
}

- (bool)hasPastCompletionDate {
    NSDate *completedDate = self.completedDate;
    if(!completedDate)
        return NO;
    NSDate *nowDate = [[GOMainApp sharedMainApp] nowDate];
    if([completedDate earlierDate:nowDate] == completedDate)
        return YES;
    return NO;
}

- (void)setCompletionDate:(NSDate *)completionDate {
    self.completedDate = completionDate;
}

- (NSDate *)completionDate {
    return self.completedDate;
}

@end
