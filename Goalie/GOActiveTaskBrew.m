//
//  GOActiveTaskBrew.m
//  Goalie
//
//  Created by Stefan Kroon on 04-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveTaskBrew.h"
#import "GOMainApp.h"
#import "GOCouchCocoa.h"
#import "GOCouchCocoa.h"

@implementation GOActiveTaskBrew

@dynamic beginDate, endDate, earnedPoints, activeGoal, task, type, occurrenceIndex, taskResult;
@dynamic completedDate;

- (void)setValue:(id)value forKey:(NSString *)key {
    if(!_mutableTaskResult)
        _mutableTaskResult = [[NSMutableDictionary alloc] init];
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

- (id)initWithTimeWindow:(TimeWindow *)timeWindow activeGoal:(GOActiveGoal *)activeGoal task:(GOTask *)task occurrence:(NSUInteger)occurrence {
    self = [super initWithNewDocumentInDatabase:[[[GOMainApp sharedMainApp] couchCocoa] serverDatabase]];
    if(self) {
        self.beginDate = [timeWindow beginDate];
        self.endDate = [timeWindow endDate];
        self.earnedPoints = [NSNumber numberWithInt:0];
        self.task = task;
        self.activeGoal = activeGoal;
        self.occurrenceIndex = [NSNumber numberWithUnsignedInteger:occurrence];
        self.type = @"ActiveTaskBrew";
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
    return [super save];
}

- (NSArray *)triggers {
    if(!_triggers) {
        _triggers = [self.task getTriggersForBrew:self];
    }
    return _triggers;
}

@end
