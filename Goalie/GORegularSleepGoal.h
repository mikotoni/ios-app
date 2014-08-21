//
//  GORegularSleepGoal.h
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveGoal.h"

@class GODescriptiveTask;

@interface GORegularSleepGoal : GOActiveGoal

@property (nonatomic, retain) NSString *sleep;
@property (nonatomic, retain) NSString *wakeup;

//- (AbstractTimeWindow *)abstractTimeWindowForDescriptionType:(NSString *)descriptionType;
    
@end
