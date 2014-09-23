//
//  GOGoalCollenctionCell.h
//  Goalie
//
//  Created by Basytyan on 8/25/14.
//  Copyright (c) 2014 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GOActiveGoal,CustomBadge, GOGoalieServices;
@interface GOGoalCollenctionCell : UICollectionViewCell{
    IBOutlet UIImageView *backgroundImageView;
    IBOutlet UIView *progressView;
    GOActiveGoal *_activeGoal;
    CustomBadge *_customBadge;
    NSString *nofUncompltedKeyPath;
    GOGoalieServices *goalieServices;
    bool badgeIsVisible;
}

@property IBOutlet UILabel *badgeView;
@property IBOutlet UIImageView *goalIconImageView;
@property IBOutlet UILabel *headline;
@property IBOutlet UILabel *deadlline;
@property IBOutlet UILabel *progressLabel;
@property IBOutlet UIView *progressView;
@property GOActiveGoal *activeGoal;

- (void)setBadgeVisible:(bool)isVisible text:(NSString *)text;
- (void)configureForActiveGoal:(GOActiveGoal *)activeGoal;

@end
