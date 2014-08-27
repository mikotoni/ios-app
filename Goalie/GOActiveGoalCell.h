//
//  GOActiveGoalCell.h
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GOActiveGoal, SafeObserver;

@interface GOActiveGoalCell : UITableViewCell {
    GOActiveGoal *_activeGoal;
    SafeObserver *_completionRateObserver;
}

@property IBOutlet UIImageView *bgIcon;
@property IBOutlet UIImageView *iconView;
@property IBOutlet UIImageView *iconView2;
@property IBOutlet UILabel *percentDailyLabel;
@property IBOutlet UILabel *percentWeeklyLabel;

@property GOActiveGoal *activeGoal;
//- (void) configureForActiveGoal:(GOActiveGoal *)activeGoal;

- (void)updateDisplayedValuesAnimated:(bool)animated;
- (void)updateDisplayedValuesAnimated;
    
@end
