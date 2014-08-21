//
//  GOActiveGoalCell.m
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveGoalCell.h"
#import "GOActiveGoal.h"
#import "SafeObserver.h"

@implementation GOActiveGoalCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)updateProgressBar {
    [self.progressView setProgress:[_activeGoal completionFloat] animated:YES];
}

- (void)updateDisplayedValuesAnimated:(bool)animated {
    [self performSelector:@selector(updateProgressBar) withObject:nil afterDelay:0.5];
    self.pointsLabel.text = [_activeGoal scoreString];
    self.iconView.image = [UIImage imageNamed:[_activeGoal iconImageName]];
    NSString *headline = [_activeGoal title];
    if(!headline)
        headline = [[_activeGoal goal] headline];
    self.titleLabel.text = headline;
}

- (void)updateDisplayedValuesAnimated {
    [self updateDisplayedValuesAnimated:YES];
}

- activeGoal {
    return _activeGoal;
}

- (void)cancelCompletionRateObserving {
    if(_activeGoal)
        [_activeGoal removeObserver:self forKeyPath:@"completionRate" context:nil];
}

- (void)setActiveGoal:(GOActiveGoal *)activeGoal {
    [self cancelCompletionRateObserving];
    _activeGoal = activeGoal;
    if(_activeGoal)
        [_activeGoal addObserver:self forKeyPath:@"completionRate" options:0 context:nil];
    [self updateDisplayedValuesAnimated:YES];
}

- (void)dealloc {
    [self cancelCompletionRateObserving];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self updateDisplayedValuesAnimated:YES];
}

@end
