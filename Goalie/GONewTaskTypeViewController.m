//
//  GONewTaskTypeViewController.m
//  Goalie
//
//  Created by Stefan Kroon on 19-04-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GONewTaskTypeViewController.h"
#import "GONewGoalTasksViewController.h"

@interface GONewTaskTypeViewController ()

@end

@implementation GONewTaskTypeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    taskTypes = @[@{@"Name":@"Stemming", @"Entity":@"MoodTask"}, @{@"Name":@"Open vraag", @"Entity":@"OpenQuestionTask"}];
    currentTaskTypeIndex = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [taskTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TaskTypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [[cell textLabel] setText:[[taskTypes objectAtIndex:[indexPath row]] valueForKey:@"Name"]];
    if(currentTaskTypeIndex == [indexPath row])
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    else
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:currentTaskTypeIndex inSection:0]];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    currentTaskTypeIndex = [indexPath row];
    cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
}

- (IBAction)addTask:(id)sender {
    NSArray *viewControllers = [self.navigationController viewControllers];
    GONewGoalTasksViewController *newGoalTasksVC = [viewControllers objectAtIndex:[viewControllers count]-2];
    NSString *taskType = [[taskTypes objectAtIndex:currentTaskTypeIndex] valueForKey:@"Entity"];
    [newGoalTasksVC addTaskOfType:taskType];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
