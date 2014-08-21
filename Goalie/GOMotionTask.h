//
//  GOMotionTask.h
//  Goalie
//
//  Created by Stefan Kroon on 08-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOTask.h"
#import "GOActiveTask.h"

static NSString * const kGOTimeActiveInterval = @"timeActiveInterval";
static NSString * const kGOActivityResetDate = @"activityResetDate";

@interface GOMotionTask : GOTask

//@property (nonatomic, retain) NSNumber *motionGoalMinutes;

    
@end

@interface GOActiveMotionTask : GOActiveTask

@property (nonatomic, retain) NSNumber *dailyTargetInSeconds;
@property (nonatomic, retain) NSNumber *dailyTargetInMinutes;
    
- (void)updateBrew:(GOTaskBrew *)brew timeActiveInterval:(NSTimeInterval)timeActiveInterval;
- (NSTimeInterval)timeActiveIntervalFromBrew:(GOTaskBrew *)brew;

@end
