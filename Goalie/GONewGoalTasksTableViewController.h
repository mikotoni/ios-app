//
//  GONewGoalTasksTableViewController.h
//  Goalie
//
//  Created by Stefan Kroon on 03-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchCocoa/CouchUITableSource.h>

@class GOTaskBrew;

@interface GONewGoalTasksTableViewController : UITableViewController <CouchUITableDelegate> {
    //NSFetchedResultsController *fetchedResultsController;
    //NSArray *tasks;
    GOTaskBrew *_selectedBrew;
}

@property (strong ,nonatomic) CouchUITableSource *uiTableSource;
@property (strong, nonatomic) CouchLiveQuery *query;

@property UIImage *greenCheckImage;
@property UIImage *redCheckImage;
@property UIImage *emptyCheckboxImage;

@end
