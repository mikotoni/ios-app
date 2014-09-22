//
//  GOPhysicalActivityGoal.h
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveGoal.h"

@interface GOPhysicalActivityGoal : GOActiveGoal

@property (nonatomic, retain) NSNumber *daily_target;
@property (nonatomic, retain) NSString *location_label;
@property (nonatomic, retain) NSNumber *location_lon;
@property (nonatomic, retain) NSNumber *location_lat;
- (NSNumber *)dailyTargetInSeconds;
- (NSNumber *)dailyTargetInMinutes;
    
@end
