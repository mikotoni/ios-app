//
//  GOSwitchTask.h
//  Goalie
//
//  Created by Stefan Kroon on 01-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOTask.h"
#import "GOActiveTask.h"

static NSString * const kGOSwitchState = @"switchState";

@interface GOSwitchTask : GOTask

@property (nonatomic, retain) NSString *explanation;
//@property (nonatomic) bool switchState;

@end

@interface GOActiveSwitchTask : GOActiveTask

- (void)updateWithBrew:(GOTaskBrew *)brew setState:(bool)newState;
    
@end