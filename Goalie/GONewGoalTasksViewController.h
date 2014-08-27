//
//  GONewGoalTasksViewController.h
//  Goalie
//
//  Created by Stefan Kroon on 19-04-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <CoreData/CoreData.h>

@interface GONewGoalTasksViewController : UIViewController {
    IBOutlet UILabel *headlineLabel;
    IBOutlet UILabel *deadlineLabel;
    IBOutlet UILabel *lastActivityLabel;
    IBOutlet UITextView *explanationTextView;
    //IBOutlet UINavigationItem *navigationTitle;
    IBOutlet UIButton *addTaskButton;
    IBOutlet UIButton *editGoalButton;
    IBOutlet UIBarButtonItem *saveButton;
    IBOutlet UIProgressView *progressBar;
    IBOutlet UIBarButtonItem *uploadButton;
    IBOutlet UILabel *scoreLabel;
    IBOutlet UIImageView *iconImageView;
    
    BOOL isEditing;
    BOOL isNewGoal;
    
    NSDateFormatter *_deadlineFormatter;
    NSDateFormatter *_lastActivityFormatter;
}

- (void)addTaskOfType:(NSString *)taskType;
//- (IBAction)saveGoal:(id)sender;
- (IBAction)uploadGoal:(id)sender;
    
    
- (void)prepareForGoal;
- (void)prepareForNewGoal;
- (void)prepareForEditGoal;
    
@end
