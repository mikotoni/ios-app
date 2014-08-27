//
//  GOEmotionAwarenessGoal.h
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveGoal.h"

@class TimeWindow;

@interface GOEmotionAwarenessGoal : GOActiveGoal

@property (nonatomic, retain) NSArray *timeWindows;

- (TimeWindow *)getNextTimeWindowForDate:(NSDate *)forDate;
- (NSArray *)abstractVisibleWindows;
- (NSArray *)abstractNotificationWindows;

@end
