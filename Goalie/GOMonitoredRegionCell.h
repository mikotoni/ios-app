//
//  GOMonitoredRegionCell.h
//  Goalie
//
//  Created by Stefan Kroon on 14-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface GOMonitoredRegionCell : UITableViewCell {
    CLRegion *_region;
}

- (IBAction)simulateVisit:(id)sender;
- (void)configureForRegion:(CLRegion *)region;

@property (strong, nonatomic) IBOutlet UILabel *radiusLabel;
@property (strong, nonatomic) IBOutlet UILabel *regionIdLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;

@end
