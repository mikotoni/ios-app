//
//  GONewGoalViewController.h
//  Goalie
//
//  Created by Stefan Kroon on 19-04-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GONewGoalTableViewController.h"

@interface GONewGoalVC : UIViewController {
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UIView *containerView;
    //IBOutlet UITableViewController *tableVC;
    IBOutlet UIBarButtonItem *cancelOrDoneButton;
    IBOutlet UIBarButtonItem *nextButton;
    BOOL isNewGoal;
    GONewGoalTableViewController *newGoalTableVC;
}

- (void)deadlineSelected:(BOOL)isSelected;
- (IBAction)cancelPressed:(id)sender;
- (void)prepareForNewGoal;
- (void)prepareForEditGoal;
//- (IBAction)datePickerChanged:(id)sender;
    
@end
