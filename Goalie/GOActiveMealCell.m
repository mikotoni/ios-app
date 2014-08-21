//
//  GOActiveMealCell.m
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveMealCell.h"
#import "GOMealTask.h"

@implementation GOActiveMealCell

- (void)awakeFromNib {
    hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateStyle:NSDateFormatterNoStyle];
    [hourFormatter setTimeStyle:NSDateFormatterShortStyle];
}

- (void)updateDisplayedValuesAnimated:(bool)animated {
    [super updateDisplayedValuesAnimated:animated];
    
    GOActiveMealTask *activeMealTask = (id)[_brew activeTask];
    GOMealTask *mealTask = (id)[activeMealTask task];
    
    self.titleLabel.text = [activeMealTask titleForBrew:_brew];
    NSDate *mealMoment = [activeMealTask mealMomentForBrew:_brew];
    NSDate *pointInTime = [mealTask pointInTimeForBrew:_brew];
    self.preferredTimeLabel.text = [hourFormatter stringFromDate:mealMoment];
    self.registerdTimeLabel.text = [hourFormatter stringFromDate:pointInTime];
    
}

@end
