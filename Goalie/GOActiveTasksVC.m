//
//  GOActiveTasksVC.m
//  Goalie
//
//  Created by Stefan Kroon on 09-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveTasksVC.h"
#import "GOMainApp.h"
#import "GOBrewCell.h"


@interface GOActiveTasksVC ()

@end

@implementation GOActiveTasksVC

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
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [_dateFormatter setDoesRelativeDateFormatting:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    [super viewWillAppear:animated];
    GOGoalieServices *goalieServices = [mainApp goalieServices];
    CouchLiveQuery *liveQuery = [goalieServices activeTasksForActiveGoal:self.activeGoal task:self.task];
    
    
    //[couchCocoa rowsForQuery:liveQuery];
    
    _uiTableSource = [[CouchUITableSource alloc] init];
    _uiTableSource.tableView = self.tableView;
    _uiTableSource.query = liveQuery;
    [self.tableView setDataSource:_uiTableSource];
    [self.tableView setDelegate:self];
}

- (IBAction)refreshActiveTasks:(id)sender {
    [self.activeGoal dirtStoredBrewsForTask:self.task];
    [self.activeGoal getBrewsForTask:self.task];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell *)couchTableSource:(CouchUITableSource *)source cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ActiveTaskCell";
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    GOBrewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    CouchDocument *document = [_uiTableSource documentAtIndexPath:indexPath];
    GOActiveTaskBrew *activeTask = [[CouchModelFactory sharedInstance] modelForDocument:document];
    
    NSDate *now = [mainApp nowDate];
    UIColor *red = [UIColor redColor];
    UIColor *black = [UIColor blackColor];
    //NSLocale *currentLocale = [NSLocale currentLocale];
    
    NSDate *beginDate = [activeTask beginDate];
    UILabel *beginLabel = [cell beginDateLabel];
    NSString *beginString = [_dateFormatter stringFromDate:beginDate];
    [beginLabel setText:beginString];
    if([beginDate compare:now] == NSOrderedAscending)
        [beginLabel setTextColor:red];
    else
        [beginLabel setTextColor:black];
        
    NSDate *endDate = [activeTask endDate];
    UILabel *endLabel = [cell endDateLabel];
    NSString *endString = [_dateFormatter stringFromDate:endDate];
    [endLabel setText:endString];
    if([endDate compare:now] == NSOrderedAscending)
        [endLabel setTextColor:red];
    else
        [endLabel setTextColor:black];
    
    [[cell occurrenceLabel] setText:[[activeTask occurrenceIndex] stringValue]];
    NSString *completedString = [_dateFormatter stringFromDate:[activeTask completedDate]];
    [[cell completedLabel] setText:completedString];
    [[cell earnedPointsLabel] setText:[[activeTask earnedPoints] stringValue]];
    NSArray *triggers = [activeTask triggers];
    NSUInteger nofTriggers = [triggers count];
    NSString *triggerString = nil;
    switch(nofTriggers) {
        case 0:
            triggerString = @"-";
            break;
        case 1: {
            GOActiveTrigger *trigger = [triggers objectAtIndex:0];
            triggerString = [_dateFormatter stringFromDate:[trigger pointInTime]];
            break;
        }
        default:
            triggerString = [NSString stringWithFormat:@"%d triggers", nofTriggers];
            break;
    }
    [[cell triggerLabel] setText:triggerString];
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     *detailViewController = [[alloc] initWithNibName:@" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
