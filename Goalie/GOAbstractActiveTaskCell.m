//
//  GOAbstractActiveTaskCell.m
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractActiveTaskCell.h"

// Services
#import "GOMainApp.h"

@implementation GOAbstractActiveTaskCell {
    int nofScheduledUpdates;
}

- (GOTaskBrew *)brew {
    return _brew;
}

- (void)updateDisplayedValuesAnimated:(bool)animated {
    GOTask *task = [_brew task];
    bool hidePoints = [task groupedTask] && ![task groupMainTask];
    [self.pointsTextLabel setHidden:hidePoints];
    if(!hidePoints) {
        NSString *pointsText = @"--";
        NSNumber *earnedPoints = [_brew earnedPoints];
        if([earnedPoints integerValue] > 0 || [_brew hasPastCompletionDate])
            pointsText = [earnedPoints stringValue];
     
        if(!animated)
            self.pointsLabel.text = pointsText;
        else {
            [UIView animateWithDuration:0.5 animations:^{
                self.pointsLabel.alpha = 0.0;
                ;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    self.pointsLabel.text = pointsText;
                    self.pointsLabel.alpha = 1.0;
                }];
            }];
        }
    }
    else {
        if([_brew hasPastCompletionDate]) {
            self.pointsLabel.text = @"V";
        }
        else {
            self.pointsLabel.text = @"-";
        }
    }
}

- (void)updateDisplayedValuesAnimated {
    if(nofScheduledUpdates > 1) {
        nofScheduledUpdates --;
        return;
    }
    nofScheduledUpdates = 0;
    [self updateDisplayedValuesAnimated:YES];
}

- (void)cancelEarnedPointsObserving {
    if(_brew) {
        [_brew removeObserver:self forKeyPath:@"earnedPoints" context:nil];
        [_brew removeObserver:self forKeyPath:@"completedDate" context:nil];
    }
}

- (void)setBrew:(GOTaskBrew *)brew {
    bool updateImmediatly = NO;
    [self cancelEarnedPointsObserving];
    if(!_brew)
        updateImmediatly = YES;
    else
        previousPoints = [_brew earnedPoints];
    _brew = brew;
    if(_brew) {
        nofScheduledUpdates = 0;
        [_brew addObserver:self forKeyPath:@"earnedPoints" options:0 context:nil];
        [_brew addObserver:self forKeyPath:@"completedDate" options:0 context:nil];
    }
    if(updateImmediatly)
        [self updateDisplayedValuesAnimated:NO];
    else {
        [self performSelector:@selector(updateDisplayedValuesAnimated) withObject:nil afterDelay:0];
        nofScheduledUpdates++;
    }
}

-(void)dealloc {
    [self cancelEarnedPointsObserving];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    nofScheduledUpdates++;
    [self performSelector:@selector(updateDisplayedValuesAnimated) withObject:nil afterDelay:0];
}

@end
