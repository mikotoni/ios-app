//
//  GODescriptiveTask.h
//  Goalie
//
//  Created by Stefan Kroon on 01-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOTask.h"
#import "GOActiveTask.h"

@class AbstractTimeWindow;

@interface GODescriptiveTask : GOTask

@property (nonatomic, retain) NSString *text;

@end

@interface GOActiveDescriptiveTask : GOActiveTask

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSArray* abstractTriggers;
//@property (readonly) NSString *text;

- (NSArray *)getTriggersForBrew:(GOTaskBrew *)brew;
    
@end
