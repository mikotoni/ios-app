//
//  GOActiveSliderCell.m
//  Goalie
//
//  Created by Stefan Kroon on 29-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveSliderCell.h"

// Model
#import "GOSliderTask.h"

@implementation GOActiveSliderCell

- (void)updateDisplayedValuesAnimated:(bool)animated {
    [super updateDisplayedValuesAnimated:animated];
    
    GOActiveSliderTask *activeSliderTask = (id)[_brew activeTask];
    GOSliderTask *sliderTask = (id)[activeSliderTask task];
    
    self.titleLabel.text = [sliderTask title];
    self.currentValueLabel.text = [NSString stringWithFormat:@"%d", [[activeSliderTask actualValueForBrew:_brew] integerValue]];
}


@end
