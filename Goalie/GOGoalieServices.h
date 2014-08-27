//
//  GOGoalieServices.h
//  Goalie
//
//  Created by Stefan Kroon on 20-06-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "PaigeConnection.h"
#import "GOCouchCocoa.h"

@class GOActiveGoal, GOTask, GOTaskBrew, GOGoal, GOSleepState;

@interface GOGoalieServices : NSObject <UIAlertViewDelegate>

@property (nonatomic, retain) CouchLiveQuery *activeGoalsQuery;
@property (nonatomic, retain) NSArray *activeTimers;
@property (strong, nonatomic) NSMutableDictionary *nofUncompletedTasksPerActiveGoal;
@property NSString *validUsername;

// Initialization
- (id)initUseLocalCouchDatabase:(bool)useLocal;
    
// Login / logout
//- (void)tryAutoLoginWithHandler:(void (^)(bool success, NSString *message))handler;
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                  handler:(void (^)(bool success, NSString *message))handler;
- (void)logout;
- (void)couchLoginWithUsername:(NSString *)rawUsername
                      password:(NSString *)password
                       handler:(void (^)(bool success))handler;

// Abstract database layer
//- (void)processActiveGoal:(NSDictionary *)activeGoalDict;
- (void)processTimeActiveInterval:(NSTimeInterval)totalSeconds;
- (void)putChanges:(NSArray *)propertiesToSave;
- (CouchDatabase *)database;

- (CouchLiveQuery *)queryForTasksByGoalWithKeys:(NSArray *)keys ;
- (CouchLiveQuery *)liveQueryForTasksByGoalWithKeys:(NSArray *)keys;
- (CouchLiveQuery *)liveQueryForEarnedPointsByActiveGoal:(GOActiveGoal *)activeGoal;
- (CouchLiveQuery *)liveQueryForEarnedPointsByActiveGoal:(GOActiveGoal *)activeGoal forDate:(NSDate *)forDate;
- (CouchLiveQuery *)liveQueryForEarnedPointsByActiveGoal:(GOActiveGoal *)activeGoal forWeekUntilDate:(NSDate *)forDate;
- (CouchLiveQuery *)liveQueryForBrewsByActiveGoal:(GOActiveGoal *)activeGoal task:(GOTask *)task;
- (CouchLiveQuery *)liveQueryForAllBrews;

- (CouchQuery *)queryForBrewsByActiveGoal:(GOActiveGoal *)activeGoal task:(GOTask *)task;
    
- (NSArray *)uncompletedBrewsByActiveGoalQuery:(GOActiveGoal *)activeGoal forDate:(NSDate *)forDate;
- (NSArray *)brewsForTask:(GOTask *)task forDate:(NSDate *)forDate;
- (NSArray *)brewsForTask:(GOTask *)task beginDate:(NSDate *)beginDate endDate:(NSDate *)endDate;
- (NSArray *)brewsByActiveGoal:(GOActiveGoal *)activeGoal forDate:(NSDate *)forDate;
- (GOGoal *)goalForActiveGoal:(GOActiveGoal *)activeGoal;
- (NSArray *)tasksByType:(NSString *)typeName;
- (void)dumpAllDocuments;
- (GOTaskBrew *)brewById:(NSString *)brewDocId;
- (void)restart;

// Deadman contorl
- (void)startDeadmanControl;
- (void)stopDeadmanControl;
- (void)pushDeadmanControl;
    
// Misc
- (void)processNewActiveGoalsDictionaries:(NSArray *)activeGoalsDictionaries;
- (void)deliverLocalNotificationForBrew:(GOTaskBrew *)brew title:(NSString *)title body:(NSString *)body;
- (void)processLocalNotification:(UILocalNotification *)notification whileInForeground:(bool)whileInForeground;
- (void)programLocalNotifications;
- (void)reloadActiveGoals;
- (void)processBrewEvent:(GOTaskBrew *)brew firstAlert:(bool)firstAlert title:(NSString *)title body:(NSString *)body;
- (void)processSleepState:(GOSleepState *)sleepState;
- (void)updateNofUncompletedTasks;
    
@end
