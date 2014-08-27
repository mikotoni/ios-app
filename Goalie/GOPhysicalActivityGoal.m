//
//  GOPhysicalActivityGoal.m
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOPhysicalActivityGoal.h"

// Model
#import "GOMotionTask.h"
#import "GOVisitTask.h"

// Services
#import "GOMainApp.h"
#import "GOTranslation.h"

// Misc
#import "CastFunctions.h"

@implementation GOPhysicalActivityGoal

@dynamic daily_target, location_label, location_lat, location_lon;

- (NSString *)progressSensorName {
    return @"physical_activity_progress";
}

- (NSNumber *)dailyTargetInMinutes {
    return self.daily_target;
}

- (NSNumber *)dailyTargetInSeconds {
    float dailyTargetInMinutes = [self.daily_target floatValue];
    NSNumber *dailyTargetInSeconds = [NSNumber numberWithFloat:dailyTargetInMinutes * 60];
    return dailyTargetInSeconds;
}

- (void)configureActiveTask:(GOActiveTask *)activeTask {
    if([activeTask isKindOfClass:[GOActiveMotionTask class]]) {
        id activeMotionTask = activeTask;
        if(![activeMotionTask respondsToSelector:@selector(setDailyTargetInMinutes:)])
            NSLog(@"WARNING: %s assumed activeMotionTask doesn't respond to setDailyTargetInMinutes", __PRETTY_FUNCTION__);
        else
            [activeMotionTask setDailyTargetInMinutes:[self dailyTargetInMinutes]];
        
        if(![activeMotionTask respondsToSelector:@selector(setDailyTargetInSeconds:)])
            NSLog(@"WARNING: %s assumed activeMotionTask doesn't respond to setDailyTargetInSeconds", __PRETTY_FUNCTION__);
        else
            [activeMotionTask setDailyTargetInSeconds:[self dailyTargetInSeconds]];
    }
    
    if([activeTask isKindOfClass:[GOActiveVisitTask class]]) {
        GOActiveVisitTask *activeVisitTask = $castIf(GOActiveVisitTask, activeTask);
        if(activeVisitTask) {
            // Set location label
            [activeVisitTask setLocationName:[self location_label]];
        
            // Set location coordinates
            CLLocationDegrees latitudeDegrees = [[self location_lat] doubleValue];
            CLLocationDegrees longitudeDegrees = [[self location_lon] doubleValue];
            CLLocationCoordinate2D visitLocationCoordinate = CLLocationCoordinate2DMake(latitudeDegrees, longitudeDegrees);
            [activeVisitTask setVisitLocationCoordinate:visitLocationCoordinate];
            
            // Set enter message
            [activeVisitTask setLocationEnteredMessage:@"Je bent op de opgegeven locatie aangekomen"];
            
            // Set points
            [activeVisitTask setNofVisitsGoal:@2];
            [activeVisitTask setPointsPerVisit:@15];
        }
        
    }
}

- (NSString *)explanation {
    return [[[GOMainApp sharedMainApp] translation] translate:@"goal_physical_activity" string:@"goal_help_physical_activity"];
}

- (NSString *)title {
    GOTranslation *translation = [[GOMainApp sharedMainApp] translation];
    return [translation translate:@"goal_physical_activity" string:@"goal_title_physical_activity"];
}

@end
