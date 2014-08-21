//
//  GODescriptiveTask.m
//  Goalie
//
//  Created by Stefan Kroon on 01-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GODescriptiveTask.h"

// Model
#import "GOGenericModelClasses.h"

// Services
#import "GOMainApp.h"
#import "GOGoalieServices.h"
#import "GOSensePlatform.h"

@implementation GODescriptiveTask

+ (Class)relatedActiveTaskClass {
    return [GOActiveDescriptiveTask class];
}

@dynamic text;

+ (bool)needsBrewForDisplaying {
    return NO;
}


- (NSArray *)getTriggersForBrew:(GOTaskBrew *)brew {
    id activeDescriptiveTask = [[[[self class] relatedActiveTaskClass] alloc] initWithBrew:brew];
    
    return [activeDescriptiveTask getTriggersForBrew:brew];
}

@end

@implementation GOActiveDescriptiveTask

- (NSArray *)getTriggersForBrew:(GOTaskBrew *)brew {
    NSArray *abstractTriggers = self.abstractTriggers;
    if(abstractTriggers) {
        NSMutableArray *triggers = [[NSMutableArray alloc] initWithCapacity:[abstractTriggers count]];
        [abstractTriggers enumerateObjectsUsingBlock:^(GOAbstractTrigger *abstractTrigger, NSUInteger idx, BOOL *stop) {
             GOActiveTrigger *trigger = [abstractTrigger concreteTriggerForBrew:brew];
             [triggers addObject:trigger];
         }];
        return triggers;
    }
    return @[];
}

- (void)fireWithBrew:(GOTaskBrew *)brew {
    [[[GOMainApp sharedMainApp] sensePlatform] refreshSleepState];
}

@end
