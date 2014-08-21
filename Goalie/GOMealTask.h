//
//  GOMealTask.h
//  Goalie
//
//  Created by Stefan Kroon on 23-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOTask.h"
#import "GOActiveTask.h"

@class GORegularMealsGoal, AbstractTimeWindow, GOTaskBrew;

static NSString * const kGOPointInTime = @"pointInTime";
static NSString * const kGODone = @"done";

@interface GOMealTask : GOTask

#ifdef USE_COREDATA
+ (GOMealTask *)mealTaskInManagedObjectContext:(NSManagedObjectContext *)context;
#endif

@property (nonatomic, retain) NSString * kind;
//@property (nonatomic) bool done;
//@property (nonatomic, retain) NSDate *pointInTime;

- (NSString *)triggerMessageForKind:(NSString *)kind;
- (NSDate *)pointInTimeForBrew:(GOTaskBrew *)brew;
- (bool)isDoneForBrew:(GOTaskBrew *)brew;

FOUNDATION_EXPORT NSString *const GOMealTaskBreakfast;
FOUNDATION_EXPORT NSString *const GOMealTaskLunch;
FOUNDATION_EXPORT NSString *const GOMealTaskDinner;

@end

@interface GOActiveMealTask : GOActiveTask {
    AbstractTimeWindow *_abstractMealWindow;
    AbstractTimeWindow *_abstractBonusWindow;
    NSUInteger _leadingHours;
    NSUInteger _trailingHours;
    NSUInteger _leadingBonusHours;
    NSUInteger _trailingBonusHours;
}

@property (nonatomic, readonly) AbstractTimeWindow *abstractBonusWindow;
@property (nonatomic, retain) NSDateComponents *abstractMealMoment;

- (NSDate *)mealMomentForBrew:(GOTaskBrew *)brew;
- (void)updateBrew:(GOTaskBrew *)brew done:(bool)done pointInTime:(NSDate *)pointInTime;

@end

