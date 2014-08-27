//
//  GONewGoalTasksTableViewController.m
//  Goalie
//
//  Created by Stefan Kroon on 03-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GONewGoalTasksTableViewController.h"
#import "GONewGoalTasksViewController.h"
#import "GOMainApp.h"
#import "GOTaskCell.h"
#import "GOOpenQuestionTaskVC.h"
#import "GOBrewsVC.h"
#import "GOGoalieServices.h"
#import "GOGenericModelClasses.h"

#import <CouchCocoa/CouchModelFactory.h>

@interface GONewGoalTasksTableViewController ()

@end

@implementation GONewGoalTasksTableViewController

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
    self.greenCheckImage = [UIImage imageNamed:@"GreenCheckmark.png"];
    self.emptyCheckboxImage = [UIImage imageNamed:@"EmptyCheckbox.png"];
    self.redCheckImage = [UIImage imageNamed:@"RedCross.png"];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    /*
    NSPredicate *goalPredicate = [NSPredicate pred
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:ascending:;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
    [fetchRequest setIncludesSubentities:YES];
    [fetchRequest setPredicate:goalPredicate];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
     */
    
    
    UITableView *tableView = self.tableView;
    self.uiTableSource = [[CouchUITableSource alloc] init];
    self.uiTableSource.tableView = tableView;
    [tableView setDataSource:self.uiTableSource];
    [tableView setDelegate:self];
}

- (void)dealloc {
    self.uiTableSource.tableView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    GOActiveGoal *activeGoal = [mainApp editingGoal];
    GOGoal *goal = [activeGoal goal];
    GOGoalieServices *goalieServices = [mainApp goalieServices];
    NSString *documentId = [[goal document] documentID];
    CouchLiveQuery *query = [goalieServices liveQueryForTasksByGoalWithKeys:@[documentId]];
    self.uiTableSource.query = query;
    self.query = query;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [tasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TaskCell";
    GOTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}
*/

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

#pragma mark - CouchUITable delegate

- (UITableViewCell *)couchTableSource:(CouchUITableSource *)source cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GOTaskCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TaskCell" forIndexPath:indexPath];
    
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    CouchDocument *taskDoc = [self.uiTableSource documentAtIndexPath:indexPath];
    GOTask *task = [[CouchModelFactory sharedInstance] modelForDocument:taskDoc];
    GOTaskBrew *brew = [[mainApp editingGoal] getBrewForTask:task forDate:[mainApp nowDate]];
    
    [cell configureCellForTask:task brew:brew tableViewController:self];
    
    return cell;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    CouchDocument *document = [self.uiTableSource documentAtIndexPath:indexPath];
    GOTask *task = [[CouchModelFactory sharedInstance] modelForDocument:document];
    if(![[task class] needsBrewForDisplaying])
        return indexPath;
    
    _selectedBrew = [[mainApp editingGoal] getBrewForTask:task forDate:[mainApp nowDate]];
    if(_selectedBrew)
        return indexPath;
    else
        return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    CouchDocument *taskDoc = [self.uiTableSource documentAtIndexPath:indexPath];
    GOTask *task = [[CouchModelFactory sharedInstance] modelForDocument:taskDoc];
    if(!task) {
        [mainApp errorAlertMessage:@"De taak is niet gevonden"];
    }
    else {
        NSString *taskName = [task taskName];
        UIViewController <GOTaskVCProtocol> *taskVC =
            [[self storyboard] instantiateViewControllerWithIdentifier:taskName];
        [taskVC setEditMode:NO];
        [taskVC setBrew:_selectedBrew];
        GOActiveTask *activeTask;
        if(_selectedBrew)
            activeTask = [_selectedBrew activeTask];
        else {
            Class activeTaskClass = [[task class] relatedActiveTaskClass];
            activeTask = [[activeTaskClass alloc] initWithTask:task activeGoal:[mainApp editingGoal]];
        }
        [taskVC setActiveTask:activeTask];
        [self.navigationController pushViewController:taskVC animated:YES];
    }
}

//- tableView

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    CouchDocument *document = [self.uiTableSource documentAtIndexPath:indexPath];
    GOTask *task = [[CouchModelFactory sharedInstance] modelForDocument:document];
    
    GOBrewsVC *brewsVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"TaskBrews"];
    [brewsVC setActiveGoal:[mainApp editingGoal]];
    [brewsVC setTask:task];
    [self.navigationController pushViewController:brewsVC animated:YES];
}


@end
