//
//  GOActiveGoal.h
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOGoal.h"
#import "CouchExtendedModel.h"

@class GOTaskBrew, GOActiveTrigger, GOActiveTask, TimeWindow;

@interface GOActiveGoal : CouchExtendedModel {
    NSMutableDictionary *_storedBrewQueries;
    NSMutableDictionary *_storedBrews;
    CouchLiveQuery *_earnedPointsLiveQuery;
    CouchLiveQuery *_earnedPointsDailyQuery;
    CouchLiveQuery *_earnedPointsWeeklyQuery;
}

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *explanation;

@property bool firstEarnedPointsValue;
@property (nonatomic, retain) GOGoal *goal;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSNumber *progress;
@property (nonatomic, retain) NSNumber *progress_sensor;
@property (nonatomic, retain) NSArray *nextTriggerTimeIntervals;
//@property (nonatomic, retain) NSArray *brewDictionaries;
@property (nonatomic, retain) NSDate *beginDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) TimeWindow *timeWindow;
@property (nonatomic, retain) NSNumber *earnedPoints;
@property (nonatomic, retain) NSNumber *earnedPointsDaily;
@property (nonatomic, retain) NSNumber *earnedPointsWeekly;
@property (nonatomic, retain) NSNumber *completionRate;
@property (nonatomic, retain) NSNumber *completionRateDaily;
@property (nonatomic, retain) NSNumber *completionRateWeekly;
@property (readonly) NSString *progressSensorName;
//@property (nonatomic, retain) NSNumber *patient_id;

//@property (nonatomic, retain) NSDate * deadline;
//@property (nonatomic, readonly) NSString *headline;
//@property (nonatomic, readonly) NSString * explanation;
//@property (nonatomic, readonly) NSArray *tasks;

//- (TimeWindow *)getTimeWindow;
- (NSDate *)deadline;
- (NSArray *)getBrewsForDate:(NSDate *)forDate;
- (NSArray *)getBrewsForTask:(GOTask *)task;
- (NSArray *)getStoredBrewsForTask:(GOTask *)task;
- (GOTaskBrew *)getBrewForTask:(GOTask *)task forDate:(NSDate *)forDate;
- (void) dirtStoredBrewsForTask:(GOTask *)task;
- (NSString *)iconImageName;
- (UIColor*)colorProgress;
- (NSString*)backgroundCellImageName;
- (void)saveEarnedPointsToSensePlatform;
- (void)updateActiveGoalFromDictionary:(NSDictionary *)activeGoalDict;
    
- (NSUInteger)completionInteger;
- (float)completionFloat;
- (NSString *)scoreString;
- (void)configureActiveTask:(GOActiveTask *)activeTask;
- (GOActiveTrigger *)getNextActiveTriggerAfter:(NSDate *)afterDate;

//- (NSArray *)brewDictionariesForDate:(NSDate *)forDate;
- (GOTaskBrew *)storedBrewForTask:(GOTask *)task forOccurrence:(NSUInteger)occurrence;
- (GOTaskBrew *)testAndDeleteStoredBrew:(GOTaskBrew *)brew forDate:(NSDate *)forDate;
- (NSUInteger)nofUncompletedTasksForDate:(NSDate *)forDate;
- (void)didUpdateBrew:(GOTaskBrew *)brew;


@end
