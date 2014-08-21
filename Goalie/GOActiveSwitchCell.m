//
//  GOActiveSwitchCell.m
//  Goalie
//
//  Created by Stefan Kroon on 29-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveSwitchCell.h"

// Model
#import "GOSwitchTask.h"

@implementation GOActiveSwitchCell

- (void)updateDisplayedValuesAnimated:(bool)animated {
    [super updateDisplayedValuesAnimated:animated];
    
    GOActiveSwitchTask *activeSwitchTask = (id)[_brew activeTask];
    GOSwitchTask *switchTask = (id)[activeSwitchTask task];
    
    self.titleLabel.text = [switchTask title];
    
    NSNumber *switchState = [self.brew valueForKey:kGOSwitchState];
    bool state =[switchState boolValue];
    [self.theSwitch setOn:state];
}

- (void)switched:(id)sender {
    GOActiveSwitchTask *activeSwitch = (id)[_brew activeTask];
    [activeSwitch updateWithBrew:_brew setState:[self.theSwitch isOn]];
    [_brew save];
}

@end
