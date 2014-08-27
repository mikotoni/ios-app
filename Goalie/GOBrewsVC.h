//
//  GOBrewsVC.h
//  Goalie
//
//  Created by Stefan Kroon on 09-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchCocoa/CouchUITableSource.h>

@class GOActiveGoal, GOTaskBrew, GOTask;

@interface GOBrewsVC : UITableViewController <CouchUITableDelegate> {
    CouchUITableSource *_uiTableSource;
    IBOutlet UIBarButtonItem *refreshButton;
    NSDateFormatter *_dateFormatter;
    NSDateFormatter *_weekdayFormatter;
    //GOTaskBrew *_selectedBrew;
    bool showDebugCells;
    UIColor *_lightGrayColor;
    UIColor *_lightGreenColor;
}

@property (nonatomic, retain) GOActiveGoal *activeGoal;
@property (nonatomic, retain) GOTask *task;

- (IBAction)refreshBrews:(id)sender;

@end
