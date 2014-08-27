//
//  GONewGoalTableViewController.m
//  Goalie
//
//  Created by Stefan Kroon on 19-04-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GONewGoalTableViewController.h"
#import "GONewGoalVC.h"
#import "GOMainApp.h"
#import "GOGenericModelClasses.h"

@interface GONewGoalTableViewController ()

@end

@implementation GONewGoalTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)headlineChanged:(id)sender {
    GOActiveGoal *activeGoal = [[GOMainApp sharedMainApp] editingGoal];
    GOGoal *goal = [activeGoal goal];
    [goal setHeadline:[_headlineField text]];
}

- (void)updateDeadlineValue {
    GOActiveGoal *goal = [[GOMainApp sharedMainApp] editingGoal];
    NSString *dateText = [_deadlineFormatter stringFromDate:[goal deadline]];
    [_deadlineLabel setText:dateText];
    
}

- (IBAction)headlineBeginEditing:(id)sender {
    NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selectedRow animated:YES];
}

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    GOGoal *goal = [[GOMainApp sharedMainApp] editingGoal];
    NSString *segueIdentifier = [segue identifier];
    if([segueIdentifier isEqualToString:@"goalExplanation"]) {
        GONewGoalExplanationViewController *newGoalExplanationVC = [segue destinationViewController];
        [newGoalExplanationVC prepareForGoal:goal];
    }
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _deadlineFormatter = [[NSDateFormatter alloc] init];
    [_deadlineFormatter setDateStyle:NSDateFormatterMediumStyle];
    [_deadlineFormatter setTimeStyle:NSDateFormatterShortStyle];
}

- (void)updateValues {
    GOActiveGoal *activeGoal = [[GOMainApp sharedMainApp] editingGoal];
    GOGoal *goal = [activeGoal goal];
    [_headlineField setText:[goal headline]];
    [_explanationLabel setText:[goal explanation]];
    [self updateDeadlineValue];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateValues];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateValues];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#if 0
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#endif

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([indexPath row] == 2) {
        GONewGoalVC *newGoalVC = (id)[self.navigationController topViewController];
        [newGoalVC deadlineSelected:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    if (row == 2) {
        GONewGoalVC *newGoalVC = (id)[self.navigationController topViewController];
        [newGoalVC deadlineSelected:YES];
    }
    if(row != 0) {
        if([_headlineField isFirstResponder])
            [_headlineField resignFirstResponder];
    }
}

@end

