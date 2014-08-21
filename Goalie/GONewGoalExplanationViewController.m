//
//  GONewGoalExplanationViewController.m
//  Goalie
//
//  Created by Stefan Kroon on 19-04-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GONewGoalExplanationViewController.h"
#import "GONewGoalVC.h"
#import "GOMainApp.h"
#import "GOGenericModelClasses.h"

@interface GONewGoalExplanationViewController ()

@end

@implementation GONewGoalExplanationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //[[self.navigationController navigationItem] setTitle:@"Doel omschrijving"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    GOActiveGoal *activeGoal = [[GOMainApp sharedMainApp] editingGoal];
    GOGoal *goal = [activeGoal goal];
    [textView setText:[goal explanation]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [textView becomeFirstResponder];
    [textView setSelectedRange:NSMakeRange(0, 1000)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)donePressed:(id)sender {
    GOActiveGoal *activeGoal = [[GOMainApp sharedMainApp] editingGoal];
    GOGoal *goal = [activeGoal goal];
    [goal setExplanation:[textView text]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
