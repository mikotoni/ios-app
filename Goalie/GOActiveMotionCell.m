//
//  GOActiveMotionCell.m
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveMotionCell.h"
#import "GOMotionTask.h"

// Services
#import "GOMainApp.h"
#import "GOTranslation.h"

@implementation GOActiveMotionCell

- (void)updateDisplayedValuesAnimated:(bool)animated {
    [super updateDisplayedValuesAnimated:animated];
    
    GOActiveMotionTask *activeMotionTask = (id)[_brew activeTask];
    //GOMotionTask *motionTask = (id)[activeMotionTask task];
    
    NSTimeInterval timeActiveInterval = [activeMotionTask timeActiveIntervalFromBrew:_brew];
    NSUInteger timeActiveMinutes = ((int)timeActiveInterval) / 60;
    NSUInteger timeActiveSeconds = ((int)timeActiveInterval) % 60;
    
    //GOTranslation *translation = [[GOMainApp sharedMainApp] translation];
    self.titleLabel.text = NSLocalizedString(@"Voldoende bewegen", nil);
    self.activityGoalLabel.text = [NSString stringWithFormat:@"%@ min", [activeMotionTask dailyTargetInMinutes]];
    self.actualActivityLabel.text = [NSString stringWithFormat:@"%u min %u sec", timeActiveMinutes, timeActiveSeconds];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:timeActiveKeypath]) {
        [self updateDisplayedValuesAnimated:NO];
    }
}

- (void)startTimeActiveObserving {
    if(_brew) {
        timeActiveKeypath = [NSString stringWithFormat:@"taskResult.%@", kGOTimeActiveInterval];
        [_brew addObserver:self forKeyPath:timeActiveKeypath options:0 context:nil];
    }
}

- (void)cancelTimeActiveObserving {
    if(_brew && timeActiveKeypath) {
        [_brew removeObserver:self forKeyPath:timeActiveKeypath];
        timeActiveKeypath = nil;
    }
}

- (void)setBrew:(GOTaskBrew *)brew {
    [super setBrew:brew];
    [self cancelTimeActiveObserving];
    [self startTimeActiveObserving];
}

- (void)dealloc {
    [self cancelTimeActiveObserving];
}

@end
