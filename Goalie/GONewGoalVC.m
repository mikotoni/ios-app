//
//  GONewGoalViewController.m
//  Goalie
//
//  Created by Stefan Kroon on 19-04-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GONewGoalVC.h"
#import "GONewGoalTasksViewController.h"
#import "GOMainApp.h"
#import "GOGenericModelClasses.h"

@interface GONewGoalVC ()

@end

@implementation GONewGoalVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(isNewGoal) {
        [self.navigationItem setRightBarButtonItem:nextButton];
    }
    else {
        [self.navigationItem setRightBarButtonItem:nil];
    }
}

- (IBAction)cancelPressed:(id)sender {
    /*
    if(isNewGoal) {
        GOGoal *aspirantGoal = [[GOMainApp sharedMainApp] editingGoal];
        NSManagedObjectContext *moc = [aspirantGoal managedObjectContext];
        [moc deleteObject:aspirantGoal];
        [[GOMainApp sharedMainApp] setEditingGoal:nil];
        //NSError *error = nil;
        //if([moc save:&error] != YES) {
            //NSLog(@"Failed to save the moc: %@", [error localizedDescription]);
        //}
    }
    else {
    }
*/
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    newGoalTableVC = [[self childViewControllers] objectAtIndex:0];
}

- (void)prepareForEditGoal {
    cancelOrDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelPressed:)];
    [self.navigationItem setLeftBarButtonItem:cancelOrDoneButton];
    isNewGoal = NO;
}

- (void)prepareForNewGoal {
    cancelOrDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelPressed:)];
    [self.navigationItem setLeftBarButtonItem:cancelOrDoneButton];
    isNewGoal = YES;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UINavigationItem *navItem = self.navigationItem;
    UIBarButtonItem *barButtonItem = [navItem backBarButtonItem];
    [barButtonItem setTarget:self];
    [barButtonItem setAction:@selector(cancelBackPressed)];
    
}
 */

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if([self isMovingFromParentViewController])
        [self cancelBackPressed];
}
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deadlineSelected:(BOOL)isSelected {
    [datePicker setHidden:!isSelected];
    if(isSelected) {
        //[self resignFirstResponder];
    }
}

/*
- (IBAction)datePickerChanged:(id)sender {
    [[[GOMainApp sharedMainApp] editingGoal] setDeadline:[datePicker date]];
    [newGoalTableVC updateDeadlineValue];
}
 */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"NewGoalNextSegue"]) {
        GOActiveGoal *activeGoal = [[GOMainApp sharedMainApp] editingGoal];
        //GOGoal *goal = [activeGoal goal];
        [activeGoal setValue:[datePicker date] forKey:@"deadline"];
        GONewGoalTasksViewController *newGoalTasksVC = [segue destinationViewController];
        [newGoalTasksVC prepareForNewGoal];
    }
}

@end
