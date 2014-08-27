//
//  GOGoalCell.h
//  Goalie
//
//  Created by Stefan Kroon on 06-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GOActiveGoal,CustomBadge, GOGoalieServices;

@interface GOGoalCell : UITableViewCell {
    //IBOutlet NSLayoutConstraint *cellLabelHSpaceConstraint;
    //IBOutlet UIView *myContentView;
    IBOutlet UIImageView *backgroundImageView;
    GOActiveGoal *_activeGoal;
    CustomBadge *_customBadge;
    NSString *nofUncompltedKeyPath;
    GOGoalieServices *goalieServices;
    bool badgeIsVisible;
}

@property IBOutlet UIView *badgeView;
@property IBOutlet UIImageView *goalIconImageView;
@property IBOutlet UILabel *headline;
@property IBOutlet UILabel *deadlline;
@property IBOutlet UIProgressView *progress;
@property GOActiveGoal *activeGoal;

- (void)setBadgeVisible:(bool)isVisible text:(NSString *)text;
- (void)configureForActiveGoal:(GOActiveGoal *)activeGoal;
    
@end
