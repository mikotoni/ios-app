//
//  GOExerciseStartsSensor.h
//  Goalie
//
//  Created by Stefan Kroon on 26-06-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOSensor.h"

@interface GOExerciseStateSensor : GOSensor

// state is a string: ("idle", "started" or "at location")
@property (nonatomic, retain) NSString *agoraphobia_state;

@end
