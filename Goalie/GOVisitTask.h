//
//  GOVisitTask.h
//  Goalie
//
//  Created by Stefan Kroon on 09-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOTask.h"
#import "GOActiveTask.h"
#import <CoreLocation/CoreLocation.h>

@class TimeWindow, CLRegion;

static NSString * const kGOVisitStartDates = @"visitStartDates";
static NSString * const kGOVisitEndDates = @"visitEndDates";
static NSString * const kGOVisitState = @"visitState";

@interface GOVisitTask : GOTask

- (NSArray *)monitorRegionsForBrew:(GOTaskBrew *)brew;

@end


@interface GOActiveVisitTask : GOActiveTask {
    AbstractTimeWindow *_abstractVisitWindow;
}

@property (nonatomic, retain) NSString *locationName;
@property (nonatomic) CLLocationCoordinate2D visitLocationCoordinate;
@property (nonatomic) NSString *locationEnteredMessage;
@property (nonatomic) NSString *locationLeftMessage;
@property (nonatomic) NSNumber *nofVisitsGoal;
@property (nonatomic) NSNumber *pointsPerVisit;

- (NSUInteger)nofVisitsGoalInteger;
- (NSUInteger)pointsPerVisitInteger;
- (CLRegion *)visitRegionForBrew:(GOTaskBrew *)brew;
- (void)didEnterWithBrew:(GOTaskBrew *)brew;
- (void)didLeaveWithBrew:(GOTaskBrew *)brew;
- (NSUInteger)nofVisitsForBrew:(GOTaskBrew *)brew;
- (void)updateBrew:(GOTaskBrew *)brew locationEntered:(bool)locationEntered;

@end