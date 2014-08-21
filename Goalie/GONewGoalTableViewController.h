//
//  GONewGoalTableViewController.h
//  Goalie
//
//  Created by Stefan Kroon on 19-04-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GONewGoalExplanationViewController.h"

@interface GONewGoalTableViewController : UITableViewController {
    IBOutlet UITextField *_headlineField;
    IBOutlet UILabel *_explanationLabel;
    IBOutlet UILabel *_deadlineLabel;
    NSDateFormatter *_deadlineFormatter;
}


- (IBAction)headlineChanged:(id)sender;
- (IBAction)headlineBeginEditing:(id)sender;
- (void)updateDeadlineValue;
    
@end
