//
//  GOAgoraphobiaGoal.h
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveGoal.h"

@interface GOAgoraphobiaGoal : GOActiveGoal

@property (nonatomic, retain) NSNumber *exercise_lon;
@property (nonatomic, retain) NSNumber *exercise_lat;
@property (nonatomic, retain) NSString *location_label;

@end
