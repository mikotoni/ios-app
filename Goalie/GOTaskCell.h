//
//  GOTaskCell.h
//  Goalie
//
//  Created by Stefan Kroon on 5/16/13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GOTaskBrew, GONewGoalTasksTableViewController, GOTask;

@interface GOTaskCell : UITableViewCell {
}

- (void)configureCellForTask:(GOTask *)task brew:(GOTaskBrew *)brew tableViewController:(GONewGoalTasksTableViewController *)tvc;
    
@property IBOutlet UILabel *taskNameLabel;
@property IBOutlet UIImageView *checkboxImageView;

@end
