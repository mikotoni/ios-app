//
//  GOActiveSleepCell.m
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveSleepCell.h"
#import "GOSleepTask.h"

@implementation GOActiveSleepCell

- (void)awakeFromNib {
    hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateStyle:NSDateFormatterNoStyle];
    [hourFormatter setTimeStyle:NSDateFormatterShortStyle];
}

- (void)updateDisplayedValuesAnimated:(bool)animated {
    [super updateDisplayedValuesAnimated:animated];
    
    GOActiveSleepTask *activeSleepTask = (id)[_brew activeTask];
    GOSleepTask *sleepTask = (id)[activeSleepTask task];
    NSDate *targetTime = [activeSleepTask targetTimeForBrew:_brew];
    
    self.desiredLabel.text = [NSString stringWithFormat:@"%@ %@",[sleepTask descriptionDesired],[hourFormatter stringFromDate:targetTime]];
    NSString *text = @"-";
    NSDate *detectedDate = [activeSleepTask detectedTimeForBrew:_brew];
    [self.handImageView setImage:[UIImage imageNamed:@"slaap-trans"]];
    if(detectedDate){
        text = [hourFormatter stringFromDate:detectedDate];
        [self.handImageView setImage:[UIImage imageNamed:@"slaap"]];
    }
    else{
        [self.handImageView setImage:[UIImage imageNamed:@"slaap-trans"]];
    }
    
    self.lastNightLabel.text = [NSString stringWithFormat:@"%@ %@",[sleepTask descriptionWentTo],text];
    self.titleLabel.text = [sleepTask name];
    
    self.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:14];
    self.lastNightLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:14];
    self.desiredLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:14];
}

@end
