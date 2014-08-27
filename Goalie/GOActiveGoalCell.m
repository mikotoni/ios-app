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


- (void)updateDisplayedValuesAnimated:(bool)animated {
    float completionRate = [[self.activeGoal completionRateDaily] floatValue];
    [self.percentDailyLabel setText:[NSString stringWithFormat:@"%.0f",completionRate*100]];
    completionRate = [[self.activeGoal completionRate] floatValue];
    [self.percentWeeklyLabel setText:[NSString stringWithFormat:@"%.0f",completionRate*100]];
    UIImage *imageIcon = [UIImage imageNamed:[_activeGoal iconImageName]];
    UIImage *bgIcon = [UIImage imageNamed:[_activeGoal backgroundCellImageName]];
    self.bgIcon.image = [bgIcon resizableImageWithCapInsets:UIEdgeInsetsMake(40, 40,40, 40) resizingMode:UIImageResizingModeTile];
    self.iconView.image = imageIcon;
    self.iconView2.image = imageIcon;
    NSString *headline = [_activeGoal title];
    if(!headline)
        headline = [[_activeGoal goal] headline];
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
