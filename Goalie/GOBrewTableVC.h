//
//  GOBrewTableVC.h
//  Goalie
//
//  Created by Stefan Kroon on 11-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GOTaskBrew;

@interface GOBrewTableVC : UITableViewController {
    NSDateFormatter *_dateFormatter;
}

@property (strong, nonatomic) IBOutlet UILabel *brewIdLabel;
@property (strong, nonatomic) IBOutlet UILabel *taskidLabel;
@property (strong, nonatomic) IBOutlet UILabel *activeGoalIdLabel;
@property (strong, nonatomic) IBOutlet UILabel *beginLabel;
@property (strong, nonatomic) IBOutlet UILabel *endLabel;
@property (strong, nonatomic) IBOutlet UILabel *earnedPointsLabel;
@property (strong, nonatomic) IBOutlet UILabel *completedLabel;
@property (strong, nonatomic) IBOutlet UILabel *occurrenceLabel;
@property (strong, nonatomic) IBOutlet UIStepper *earnedPointsStepper;

@property GOTaskBrew *brew;
- (IBAction)stepperChanged:(id)sender;
- (IBAction)saveBrew:(id)sender;

@end
