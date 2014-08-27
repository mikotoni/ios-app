//
//  GOActiveTasksVC.h
//  Goalie
//
//  Created by Stefan Kroon on 09-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchUITableSource.h>

@class GOActiveGoal, GOActiveTaskBrew, GOTask;

@interface GOActiveTasksVC : UITableViewController <CouchUITableDelegate> {
    CouchUITableSource *_uiTableSource;
    IBOutlet UIBarButtonItem *refreshButton;
    NSDateFormatter *_dateFormatter;
}

@property (nonatomic, retain) GOActiveGoal *activeGoal;
@property (nonatomic, retain) GOTask *task;

- (IBAction)refreshActiveTasks:(id)sender;

@end
