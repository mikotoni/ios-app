//
//  GOTaskBrew.h
//  Goalie
//
//  Created by Stefan Kroon on 04-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <CouchCocoa/CouchCocoa.h>

@class TimeWindow, GOActiveGoal, GOTask, GOActiveTask;

@interface GOTaskBrew : CouchModel {
    TimeWindow *_timeWindow;
    NSMutableDictionary *_mutableTaskResult;
    NSArray *_triggers;
}

@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) GOActiveGoal *activeGoal;
@property (nonatomic, retain) GOTask *task;
@property (nonatomic, retain) NSNumber *occurrenceIndex;

@property (nonatomic, retain) NSNumber *earnedPoints;
@property (nonatomic, retain) NSDate *beginDate;
@property (nonatomic, retain) NSDate *endDate;

@property (nonatomic, retain) NSString *beginString;
@property (nonatomic, retain) NSString *endString;

@property (nonatomic, retain) NSDate *completedDate;

@property (nonatomic, retain) NSDictionary *taskResult;
@property (readonly) GOActiveTask *activeTask;

- (id)initWithTimeWindow:(TimeWindow *)timeWindow activeGoal:(GOActiveGoal *)activeGoal task:(GOTask *)task occurrence:(NSUInteger)occurrence;
- (TimeWindow *)timeWindow;
- (id)getTaskWithClass:(Class)klass;
- (void)setEarnedPointsInteger:(NSUInteger)points;
- (NSArray *)triggers;
- (void)dirtTriggers;
    
- (void)resetCompletionDate;
- (bool)hasPastCompletionDate;
- (void)setCompletionDate:(NSDate *)completionDate;
- (NSDate *)completionDate;

    
@end
