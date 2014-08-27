//
//  GOVisitTaskVC.h
//  Goalie
//
//  Created by Stefan Kroon on 09-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractTaskVC.h"
#import <MapKit/MapKit.h>

@interface GOVisitTaskVC : GOAbstractTaskVC {
    MKMapRect _unionRectThatFits;
}

@property IBOutlet MKMapView *mapView;
@property IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *nofVisitsLabel;
@property (strong, nonatomic) IBOutlet UILabel *earnedPointsLabel;

@end
