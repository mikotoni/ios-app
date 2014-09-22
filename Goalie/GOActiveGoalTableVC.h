//
//  GOAciveGoalTableVC.h
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GOAbstractTaskVC.h"

@class GOActiveGoal, GOTaskBrew;

@interface GOActiveGoalTableVC : UITableViewController<GOAbstractTaskVCProtocol> {
    NSArray *brews;
    GOTaskBrew *selectedBrew;
    IBOutlet UIView*informationView;
    IBOutlet UILabel*informationLabel;
}

@property GOActiveGoal *activeGoal;

@end
