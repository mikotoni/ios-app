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
    
    self.desiredLabel.text = [hourFormatter stringFromDate:targetTime];
    NSString *text = @"-";
    NSDate *detectedDate = [activeSleepTask detectedTimeForBrew:_brew];
    if(detectedDate)
        text = [hourFormatter stringFromDate:detectedDate];
    self.lastNightLabel.text = text;
    self.titleLabel.text = [sleepTask name];
}

@end
