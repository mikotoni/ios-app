//
//  GORegularMeals.m
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GORegularMealsGoal.h"

// Model
#import "GOGenericModelClasses.h"
#import "GOMealTask.h"
#import "TimeWindow.h"

// Services
#import "GOMainApp.h"
#import "GOTranslation.h"

@implementation GORegularMealsGoal

@dynamic breakfast, lunch, dinner;

- (UIColor*)colorProgress{
    return UIColorFromRGB(0x42db00);
}
- (int)loadingHeight{
    return 92;
}
- (NSString *)progressSensorName {
    return @"regular_meals_progress";
}

- (NSDateComponents *)abstractMealMomentForKind:(NSString *)kind {
    NSDateComponents *abstractMealMoment = nil;
    if(!_abstractMealMomentDict)
        _abstractMealMomentDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    else
        abstractMealMoment = [_abstractMealMomentDict valueForKey:kind];
    
    if(!abstractMealMoment) {
        NSString *mealParameter = [self valueForKey:kind];
        abstractMealMoment = [AbstractTimeWindow abstractFromHourMinuteString:mealParameter];
        [_abstractMealMomentDict setObject:abstractMealMoment forKey:kind];
    }
    return abstractMealMoment;
}

- (void)configureActiveTask:(GOActiveTask *)activeTask {
    id mealTask = [activeTask task];
    if(![mealTask respondsToSelector:@selector(kind)]) {
        NSLog(@"WARNING: %s assumed mealTask doesn't response to kind", __PRETTY_FUNCTION__);
        return;
    }
    NSString *kind = [mealTask kind];
    
    id activeMealTask = activeTask;
    if(![activeMealTask respondsToSelector:@selector(setAbstractMealMoment:)]) {
        NSLog(@"WARNING: %s assumed activeMealTask doesn't response to setAbstractMealMoment", __PRETTY_FUNCTION__);
        return;
    }
    
    
    NSDateComponents *abstractMealMoment = [self abstractMealMomentForKind:kind];
    [activeMealTask setAbstractMealMoment:abstractMealMoment];
}

- (NSString *)description {
    return [[[GOMainApp sharedMainApp] translation] translate:@"goal_regular_meals" string:@"goal_descr_regular_meals"];
}

- (NSString *)explanation {
    GOTranslation *translation = [[GOMainApp sharedMainApp] translation];
    return [translation translate:@"goal_regular_meals" string:@"goal_help_regular_meals"];
}

- (NSString *)title {
    GOTranslation *translation = [[GOMainApp sharedMainApp] translation];
    return [translation translate:@"goal_regular_meals" string:@"goal_title_regular_meals"];
}

@end
