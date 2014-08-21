//
//  GOAciveGoalTableVC.h
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GOActiveGoal, GOTaskBrew;

@interface GOActiveGoalTableVC : UITableViewController {
    NSArray *brews;
    GOTaskBrew *selectedBrew;
}

@property GOActiveGoal *activeGoal;

@end
