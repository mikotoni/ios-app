//
//  Task.h
//  Goalie
//
//  Created by Stefan Kroon on 06-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <CouchCocoa/CouchCocoa.h>

#ifdef USE_COREDATA
#import <CoreData/CoreData.h>
#endif

@class GOGoal;
@class GOActiveTrigger, GOActiveGoal, GOTaskBrew, GOActiveTask;

@interface GOTask : CouchModel

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *manual;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) GOGoal *goal;
@property (nonatomic, readonly) NSString *taskName;
@property (nonatomic, readonly) bool countAsUncompleted;
@property (nonatomic) bool groupedTask;
@property (nonatomic) bool groupMainTask;
@property (nonatomic) NSNumber *indexNumber;

- (NSArray *)getBrewsForActiveGoal:(GOActiveGoal *)activeGoal;
- (NSArray *)getBrewsForActiveGoal:(GOActiveGoal *)activeGoal activeTask:(GOActiveTask *)activeTask;
- (GOActiveTask *)activeTaskForActiveGoal:(GOActiveGoal *)activeGoal;
+ (Class)relatedActiveTaskClass;
+ (bool)needsBrewForDisplaying;

//- (GOTaskBrew *)getBrewForActiveGoal:(GOActiveGoal *)activeGoal;
//- (GOActiveTrigger *)getNextActiveTriggerAfter:(NSDate *)afterDate forActiveGoal:(GOActiveGoal *)activeGoal;
//- (NSArray *)getBrewsForActiveGoal:(GOActiveGoal *)activeGoal;
//- (NSArray *)mergeBrewsWithStoredBrews:(NSArray *)brews activeGoal:(GOActiveGoal *)activeGoal forDate:(NSDate *)forDate;
//- (GOTaskBrew *)getStoredBrewByOccurrencce:(NSUInteger)currentOccurrence activeGoal:(GOActiveGoal *)activeGoal forDate:(NSDate *)forDate;
- (NSArray *)getTriggersForBrew:(GOTaskBrew *)brew;

@end
