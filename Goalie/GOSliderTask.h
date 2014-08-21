//
//  GOSliderTask.h
//  Goalie
//
//  Created by Stefan Kroon on 28-06-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOTask.h"
#import "GOActiveTask.h"

static NSString * const kGOSliderActualValue = @"actualValue";

@interface GOSliderTask : GOTask

@property (nonatomic, retain) NSString *question;
@property (nonatomic, retain) NSNumber *rangeStart;
@property (nonatomic, retain) NSNumber *rangeEnd;
@property (nonatomic) NSTimeInterval triggerInterval;
//@property (nonatomic, retain) NSNumber *actualValue;

@end


@interface GOActiveSliderTask : GOActiveTask

- (void)updateBrew:(GOTaskBrew *)brew withValue:(NSNumber *)value;
- (NSNumber *)actualValueForBrew:(GOTaskBrew *)brew;
    
@end