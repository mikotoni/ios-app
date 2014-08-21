//
//  GORegularMeals.h
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveGoal.h"

@interface GORegularMealsGoal : GOActiveGoal {
    NSMutableDictionary *_abstractMealMomentDict;
}

@property (nonatomic, retain) NSString *breakfast;
@property (nonatomic, retain) NSString *lunch;
@property (nonatomic, retain) NSString *dinner;

- (NSDateComponents *)abstractMealMomentForKind:(NSString *)kind;

@end
