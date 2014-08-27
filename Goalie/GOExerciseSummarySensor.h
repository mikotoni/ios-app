//
//  GOExerciseLocationArrivalSensor.h
//  Goalie
//
//  Created by Stefan Kroon on 26-06-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOSensor.h"

@interface GOExerciseSummarySensor : GOSensor

@property (nonatomic, retain) NSDate *started;
@property (nonatomic, retain) NSDate *arrived;
@property (nonatomic, retain) NSDate *photo;
@property (nonatomic, retain) NSDate *left;

@end
