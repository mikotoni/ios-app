//
//  GONewGoalTasksViewController.m
//  Goalie
//
//  Created by Stefan Kroon on 19-04-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

//#import <CoreData/CoreData.h>
//#import <RestKit/RestKit.h>

#import "GONewGoalTasksViewController.h"
#import "GOAppDelegate.h"
#import "GOMainApp.h"
#import <CouchCocoa/CouchModelFactory.h>
#import "GOGenericModelClasses.h"
#import "GOGoalieServices.h"

@interface GONewGoalTasksViewController ()

@end

@implementation GONewGoalTasksViewController

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
    _deadlineFormatter = [[NSDateFormatter alloc] init];
    [_deadlineFormatter setDateStyle:NSDateFormatterMediumStyle];
    [_deadlineFormatter setTimeStyle:NSDateFormatterShortStyle];
    [_deadlineFormatter setDoesRelativeDateFormatting:YES];
    
    _lastActivityFormatter = _deadlineFormatter;
    explanationTextView.contentInset = UIEdgeInsetsMake(-8, -8, -8, -8);
}
/*
- (void)viewDidLayoutSubviews {
    [explanationLabel sizeToFit];
}
 */

- (void)updateValues {
    GOActiveGoal *activeGoal = [[GOMainApp sharedMainApp] editingGoal];
    GOGoal *goal = [activeGoal goal];
    NSDate *deadline = [activeGoal deadline];
    NSString *headline = [goal headline];
    NSString *explanation = [goal explanation];
    NSString *deadlineString =
            [NSString stringWithFormat:@"Deadline: %@", [_deadlineFormatter stringFromDate:deadline]];
    NSString *lastActivityDateString = @"-";
    //if([goal lastActivityDate])
        //lastActivityDateString = [_lastActivityFormatter stringFromDate:[goal lastActivityDate]];
    NSString *lastActivityString = [NSString stringWithFormat:@"Laatste activiteit: %@", lastActivityDateString];
    [deadlineLabel setText:deadlineString];
    [lastActivityLabel setText:lastActivityString];
    [headlineLabel setText:headline];
    [explanationTextView setText:explanation];
    [addTaskButton setHidden:(isEditing ? NO : YES)];
    [editGoalButton setHidden:!(isEditing && !isNewGoal)];
    if(isEditing) {
        [self setToolbarItems:@[uploadButton]];
    }
    else {
        [self setToolbarItems:@[]];
    }
    
    [progressBar setProgress:[activeGoal completionFloat]];
    [scoreLabel setText:[activeGoal scoreString]];
    iconImageView.image = [UIImage imageNamed:[activeGoal iconImageName]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateValues];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateValues];
    [explanationTextView flashScrollIndicators];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navigateHome {
    UINavigationController *navigationController = [self navigationController];
    [navigationController popToRootViewControllerAnimated:YES];
}

#ifdef USE_COREDATA
- (IBAction)saveGoal:(id)sender {
    //GOAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSError *error = nil;
    if([[[GOMainApp sharedMainApp] managedObjectContext] save:&error] != YES) {
        NSLog(@"Failed to save the goal: %@", [error localizedDescription]);
    }
    [self navigateHome];
/*
    NSManagedObjectContext *moc = [[GOMainApp sharedMainApp] managedObjectContext];
    NSError *error = nil;
    if([moc save:&error] != YES) {
        NSLog(@"Failed to save the managed object context: %@", [error localizedDescription]);
    }
    else {
        [self navigateHome];
    }
 */
}
#endif

- (IBAction)uploadGoal:(id)sender {
    // Put Objects
    /*
     GOMainApp *mainApp = [GOMainApp sharedMainApp];
    GOGoal *goal = [mainApp editingGoal];
    NSString *path = [NSString stringWithFormat:@"goal/%@", [goal uuid]];
    RKObjectManager *objectManager = [mainApp objectManager];
    RKManagedObjectRequestOperation *operation =
        [objectManager appropriateObjectRequestOperationWithObject:goal
                                                            method:RKRequestMethodPOST
                                                              path:path
                                                        parameters:nil];
    operation.targetObject = nil;
    //operation.targetObjectID = nil;
    [objectManager enqueueObjectRequestOperation:operation];
   */ 
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueIdentifier = [segue identifier];
    if([segueIdentifier isEqualToString:@"editGoalDetails"]) {
        GONewGoalTasksViewController *newGoalVC = [segue destinationViewController];
        [newGoalVC prepareForEditGoal];
    }
}

- (void)addTaskOfType:(NSString *)taskType {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    GOGoalieServices *goalieServices = [mainApp goalieServices];
#ifdef USE_COREDATA
    NSManagedObjectContext *managedObjectContext = [mainApp managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:taskType
                                                         inManagedObjectContext:managedObjectContext];
    NSManagedObject *newTask = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:managedObjectContext];
#else
    Class class = [[CouchModelFactory sharedInstance] classForDocumentType:taskType];
    CouchDatabase *database = [goalieServices database];
    GOTask *newTask = [[class alloc] initWithNewDocumentInDatabase:database];
    [newTask save];
#endif
    GOActiveGoal *activeGoal = [mainApp editingGoal];
    GOGoal *goal = [activeGoal goal];
    [goal addTasksObject:newTask];
}

- (void)prepareForNewGoal {
    UINavigationItem *navigationItem = self.navigationItem;
    [navigationItem setTitle:@"Nieuw doel"];
    isEditing = YES;
    isNewGoal = YES;
    [navigationItem setRightBarButtonItem:saveButton];
}

- (void)prepareForGoal {
    UINavigationItem *navigationItem = self.navigationItem;
    [navigationItem setTitle:@"Doel details"];
    [navigationItem setRightBarButtonItem:nil];
    isEditing = NO;
    isNewGoal = NO;
}

- (void)prepareForEditGoal {
    UINavigationItem *navigationItem = self.navigationItem;
    [navigationItem setTitle:@"Doel bewerken"];
    isEditing = YES;
    isNewGoal = NO;
    [navigationItem setRightBarButtonItem:saveButton];
}

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueIdentifier = [segue identifier];
}
*/

@end
