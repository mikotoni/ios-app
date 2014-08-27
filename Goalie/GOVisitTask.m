//
//  GOVisitTask.m
//  Goalie
//
//  Created by Stefan Kroon on 09-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOVisitTask.h"

// Model
#import "GOGenericModelClasses.h"
#import "TimeWindow.h"

// Services
#import "GOMainApp.h"
#import "GOGoalieServices.h"

// Misc
#import "CastFunctions.h"

@implementation GOVisitTask

+ (Class)relatedActiveTaskClass {
    return [GOActiveVisitTask class];
}

- (bool)countAsUncompleted {
    return NO;
}

- (NSArray *)monitorRegionsForBrew:(GOTaskBrew *)brew {
    GOActiveVisitTask *activeVisitTask = [[GOActiveVisitTask alloc] initWithBrew:brew];
    CLRegion *region = [activeVisitTask visitRegionForBrew:brew];
    if(region)
        return @[region];
    else
        return @[];
}


@end


@implementation GOActiveVisitTask

- (NSUInteger)nofVisitsGoalInteger {
    return [self.nofVisitsGoal integerValue];
}

- (NSUInteger)pointsPerVisitInteger {
    return [self.pointsPerVisit integerValue];
}

- (NSUInteger)pointsForNofVisits:(NSUInteger)nofVisits {
    NSUInteger nofVisitsGoal = [self nofVisitsGoalInteger];
    if(nofVisits > nofVisitsGoal)
        nofVisits = nofVisitsGoal;
    return nofVisits * [self pointsPerVisitInteger];
}

- (void)updateBrew:(GOTaskBrew *)brew locationEntered:(bool)locationEntered {
    NSString *jsonNowDate = [RESTBody JSONObjectWithDate:[[GOMainApp sharedMainApp] nowDate]];
    
    if(locationEntered) {
        NSMutableArray *newVisitStartDates;
        NSArray *visitStartDates = [brew valueForKey:kGOVisitStartDates];
        if(visitStartDates)
            newVisitStartDates = [visitStartDates mutableCopy];
        else
            newVisitStartDates = [[NSMutableArray alloc] initWithCapacity:1];
        [newVisitStartDates addObject:jsonNowDate];
        [brew setValue:newVisitStartDates forKey:kGOVisitStartDates];
        
        NSUInteger nofVisits = [newVisitStartDates count];
        if(![self.task groupedTask]) {
            NSUInteger newPoints = [self pointsForNofVisits:nofVisits];
            [brew setEarnedPoints:[NSNumber numberWithUnsignedInt:newPoints]];
        }
        [brew setCompletionDate:[[GOMainApp sharedMainApp] nowDate]];
    }
    else {
        NSMutableArray *newVisitEndDates;
        NSArray *visitEndDates = [brew valueForKey:kGOVisitEndDates];
        if(visitEndDates)
            newVisitEndDates = [visitEndDates mutableCopy];
        else
            newVisitEndDates = [[NSMutableArray alloc] initWithCapacity:1];
        [newVisitEndDates addObject:jsonNowDate];
        [brew setValue:newVisitEndDates forKey:kGOVisitEndDates];
        if([self.task groupedTask])
            [brew resetCompletionDate];
    }
    [brew setValue:[NSNumber numberWithBool:locationEntered] forKey:kGOVisitState];
    [self.activeGoal didUpdateBrew:brew];
}

- (NSUInteger)nofVisitsForBrew:(GOTaskBrew *)brew {
    NSArray *visits = [brew valueForKey:kGOVisitStartDates];
    return [visits count];
}

- (AbstractTimeWindow *)abstractTaskWindow {
    if(!_abstractVisitWindow) {
        _abstractVisitWindow = [self abstractWeekTask];
    }
    return _abstractVisitWindow;
}

- (CLRegion *)visitRegionForBrew:(GOTaskBrew *)brew {
    CLLocationDistance distance = 100.0; // Meters
    NSString *identifier = [[brew document] documentID];
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:self.visitLocationCoordinate radius:distance identifier:identifier];
    
    return region;
}

- (void)didEnterWithBrew:(GOTaskBrew *)brew {
    
    GOActiveVisitTask *activeVisitTask = (id)[brew activeTask];
    [activeVisitTask updateBrew:brew locationEntered:YES];
    
    GOGoalieServices *goalieServices = [[GOMainApp sharedMainApp] goalieServices];
    NSString *title = NSLocalizedString(@"Locatie bereikt", @"Location reached alert title");
    if(self.locationEnteredMessage) {
        [goalieServices deliverLocalNotificationForBrew:brew title:title body:self.locationEnteredMessage];
    }
}

- (void)didLeaveWithBrew:(GOTaskBrew *)brew {
    GOActiveVisitTask *activeVisitTask = (id)[brew activeTask];
    [activeVisitTask updateBrew:brew locationEntered:NO];
    
    GOGoalieServices *goalieServices = [[GOMainApp sharedMainApp] goalieServices];
    NSString *title = NSLocalizedString(@"Locatie verlaten", @"Left location alert title");
    if(self.locationLeftMessage) {
        [goalieServices deliverLocalNotificationForBrew:brew title:title body:self.locationLeftMessage];
    }
}

- (NSString *)titleForBrew:(GOTaskBrew *)brew {
    NSString *title;
    NSString *locationName = self.locationName;
    if(locationName)
        title = [NSString stringWithFormat:NSLocalizedString(@"Bezoek %@", nil), locationName];
    else
        title = NSLocalizedString(@"Geen locatie ingesteld", nil);
    return title;
}

- (NSString *)activeCellIdentifier {
    return @"ActiveVisitCell";
}

@end