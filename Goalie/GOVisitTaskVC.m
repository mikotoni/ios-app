//
//  GOVisitTaskVC.m
//  Goalie
//
//  Created by Stefan Kroon on 09-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOVisitTaskVC.h"
#import "GOVisitTask.h"
#import "GOTaskBrew.h"

@interface GOVisitTaskVC ()

@end

@implementation GOVisitTaskVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(!self.editMode) {
        GOTaskBrew *brew = self.brew;
        GOActiveVisitTask *activeVisitTask = [[GOActiveVisitTask alloc] initWithBrew:brew];
        [self.locationLabel setText:[activeVisitTask locationName]];
        int earnedPoints = [[brew earnedPoints] intValue];
        [self.earnedPointsLabel setText:[NSString stringWithFormat:@"%d", earnedPoints]];
        NSUInteger nofVisits = [activeVisitTask nofVisitsForBrew:brew];
        [self.nofVisitsLabel setText:[NSString stringWithFormat:@"%d", nofVisits]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    GOActiveVisitTask *activeVisitTask = [[GOActiveVisitTask alloc] initWithBrew:self.brew];
    CLRegion *visitRegion = [activeVisitTask visitRegionForBrew:self.brew];
    MKMapView *mapView = self.mapView;
    MKPointAnnotation *visitAnnotation = [[MKPointAnnotation alloc] init];
    visitAnnotation.title = [activeVisitTask locationName];
    visitAnnotation.coordinate = [visitRegion center];
    [mapView addAnnotation:visitAnnotation];
    MKUserLocation *theUserLocation = [mapView userLocation];
    CLLocation *userLocation = [theUserLocation location];
    
    MKMapRect userRect = MKMapRectNull;
    if(userLocation) {
        CLLocationCoordinate2D userCoordinate = [userLocation coordinate];
        MKMapPoint userPoint = MKMapPointForCoordinate(userCoordinate);
        userRect = MKMapRectMake(userPoint.x, userPoint.y, 0, 0);
    }
    
    MKMapRect visitRect = MKMapRectNull;
    if(visitRegion) {
        CLLocationCoordinate2D visitCoordinate = visitRegion.center;
        MKMapPoint visitPoint = MKMapPointForCoordinate(visitCoordinate);
        visitRect = MKMapRectMake(visitPoint.x, visitPoint.y, 0, 0);
    }
    
    MKMapRect unionRect = MKMapRectNull;
    if(!MKMapRectIsNull(visitRect) && !MKMapRectIsNull(userRect))
        unionRect = MKMapRectUnion(userRect, visitRect);
    else if(!MKMapRectIsNull(visitRect))
        unionRect = visitRect;
    else if(!MKMapRectIsNull(userRect))
        unionRect = userRect;
    else
        unionRect = MKMapRectNull;
    
    if(!MKMapRectIsNull(unionRect)) {
        _unionRectThatFits = [mapView mapRectThatFits:unionRect];
        UIEdgeInsets insets = UIEdgeInsetsMake(40, 40, 40, 40);
        [self.mapView setVisibleMapRect:_unionRectThatFits edgePadding:insets animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
