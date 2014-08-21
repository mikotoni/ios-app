//
//  GOLocationManager.m
//  Goalie
//
//  Created by Stefan Kroon on 12-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOLocationManager.h"
#import "GOMainApp.h"
#import "GOGenericModelClasses.h"
#import "GOVisitTask.h"
#import "GOGoalieServices.h"

@implementation GOLocationManager {
    CLLocationManager *_locationManager;
    NSDate *lastUsabilityNotification;
    int nofUsabilityNotifications;
}

- (id)init {
    self = [super init];
    if(self) {
       _locationManager = [[CLLocationManager alloc] init];
        //TODO: @Stefan, I don't know wether this actually is needed, but it can't hurt and I have no time for more tests right now...
        _locationManager.pausesLocationUpdatesAutomatically = false;
        [_locationManager setDelegate:self];
        [[GOMainApp sharedMainApp] addObserver:self forKeyPath:kGOGoalieServices options:0 context:nil];
    }
    return self;
}

- (void)dealloc {
    [[GOMainApp sharedMainApp] removeObserver:self forKeyPath:kGOGoalieServices];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    if(object == mainApp && [keyPath isEqualToString:kGOGoalieServices]) {
        GOGoalieServices *goalieServices = [mainApp goalieServices];
        if(goalieServices)
            [self programMonitorRegions];
        else
            [self eraseAllMonitorRegions];
    }
}

- (NSSet *)monitoredRegions {
    return [_locationManager monitoredRegions];
}

- (NSArray *)visitTasks {
    static NSArray *visitTasks = nil;
    if(!visitTasks) {
        visitTasks = [[[GOMainApp sharedMainApp] goalieServices] tasksByType:@"VisitTask"];
    }
    return visitTasks;
}

- (void)simulateRegionEnter:(CLRegion *)region {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self locationManager:_locationManager didEnterRegion:region];
}

- (void)eraseAllMonitorRegions {
        [_locationManager.monitoredRegions enumerateObjectsUsingBlock:^(CLRegion *delRegion, BOOL *stop) {
            [_locationManager stopMonitoringForRegion:delRegion];
        }];
    
}

- (void)programMonitorRegions {
    NSLog(@"%s ", __PRETTY_FUNCTION__);
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    GOGoalieServices *goalieServices = [mainApp goalieServices];
    NSDate *nowDate = [mainApp nowDate];
    NSMutableArray *allActiveMonitorRegions = [[NSMutableArray alloc] initWithCapacity:8];
    NSArray *visitTasks = [self visitTasks];
    [visitTasks enumerateObjectsUsingBlock:^(GOVisitTask *visitTask, NSUInteger idx, BOOL *stop) {
        NSArray *brews = [goalieServices brewsForTask:visitTask forDate:nowDate];
        [brews enumerateObjectsUsingBlock:^(GOTaskBrew *brew, NSUInteger idx, BOOL *stop) {
            NSArray *monitorRegions = [visitTask monitorRegionsForBrew:brew];
            [allActiveMonitorRegions addObjectsFromArray:monitorRegions];
        }];
    }];
    
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager regionMonitoringAvailable]) {
        [self eraseAllMonitorRegions];
        [allActiveMonitorRegions enumerateObjectsUsingBlock:^(CLRegion *region, NSUInteger idx, BOOL *stop) {
            [_locationManager startMonitoringForRegion:region];
        }];
    }
    else {
        NSTimeInterval timeDiff = [lastUsabilityNotification timeIntervalSinceNow];
        if((timeDiff >= 0 || (timeDiff < 60.0 * 60.0 * 24.0) ) && nofUsabilityNotifications < 5) {
            NSString *errorMessage = nil;
            if(![CLLocationManager regionMonitoringAvailable])
                errorMessage = @"Met deze telefoon kan niet worden gedetecteerd of je op een locatie bent aangekomen.";
            else
                errorMessage = @"Locatie voorzieningen zijn voor deze app niet beschikbaar. Ga naar instellingen om de locatievoorzieningen aan te zetten.";
            [[GOMainApp sharedMainApp] errorAlertMessage:errorMessage];
            lastUsabilityNotification = [NSDate date];
            nofUsabilityNotifications++;
        }
    }
}

- (GOTaskBrew *)brewForRegion:(CLRegion *)region {
    NSLog(@"%s for brew: %@", __PRETTY_FUNCTION__, [region identifier]);
    NSString *brewDocId = [region identifier];
    GOTaskBrew *brew = [[[GOMainApp sharedMainApp] goalieServices] brewById:brewDocId];
    if(!brew)
        NSLog(@"%s Brew with docId:%@ not found", __PRETTY_FUNCTION__, brewDocId);
    return brew;
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    GOTaskBrew *brew = [self brewForRegion:region];
    if(!brew)
        return;
    GOActiveVisitTask *activeVisitTask = (id)[brew activeTask];
    [activeVisitTask didEnterWithBrew:brew];
    [brew save];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    GOTaskBrew *brew = [self brewForRegion:region];
    if(!brew)
        return;
    GOActiveVisitTask *activeVisitTask = (id)[brew activeTask];
    [activeVisitTask didLeaveWithBrew:brew];
    [brew save];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    CLLocationCoordinate2D coordinate = [region center];
    NSLog(@"%s Region: [%.4f; %.4f] radius:%.1fm Brew:%@", __PRETTY_FUNCTION__, coordinate.latitude, coordinate.longitude, [region radius], [region identifier]);
    
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"ERROR: %s %@", __PRETTY_FUNCTION__, [error localizedDescription]);
}


@end
