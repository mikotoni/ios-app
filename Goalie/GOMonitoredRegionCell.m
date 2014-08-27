//
//  GOMonitoredRegionCell.m
//  Goalie
//
//  Created by Stefan Kroon on 14-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOMonitoredRegionCell.h"
#import "GOMainApp.h"
#import "GOLocationManager.h"

@implementation GOMonitoredRegionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)simulateVisit:(id)sender {
    [[[GOMainApp sharedMainApp] locationService] simulateRegionEnter:_region];
}

- (void)configureForRegion:(CLRegion *)region {
    _region = region;
    CLLocationCoordinate2D locationCoordinate = [region center];
    self.locationLabel.text = [NSString stringWithFormat:@"[%.3f; %.3f]", locationCoordinate.latitude, locationCoordinate.longitude];
    self.radiusLabel.text = [NSString stringWithFormat:@"%.1fm", region.radius];
    self.regionIdLabel.text = region.identifier;
}

@end
