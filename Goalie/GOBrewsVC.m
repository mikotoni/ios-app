//
//  GOBrewsVC.m
//  Goalie
//
//  Created by Stefan Kroon on 09-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOBrewsVC.h"
#import "GOMainApp.h"
#import "GOBrewCell.h"
#import "GOBrewTableVC.h"
#import "GOEarnedPointsCell.h"
#import "GOGenericModelClasses.h"
#import "GOGoalieServices.h"

@interface GOBrewsVC ()

@end

@implementation GOBrewsVC

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

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _dateFormatter = [[GOMainApp sharedMainApp] genericDateFormatter];
    
    _lightGrayColor = [UIColor colorWithRed:0xEB/255.0 green:0xEB/255.0 blue:0xEB/255.0 alpha:1.0];
    _lightGreenColor = [UIColor colorWithRed:0xEC/255.0 green:0xFF/255.0 blue:0xDD/255.0 alpha:1.0];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    GOGoalieServices *goalieServices = [mainApp goalieServices];
    CouchLiveQuery *liveQuery = [goalieServices liveQueryForBrewsByActiveGoal:self.activeGoal task:self.task];
    
    _uiTableSource = [[CouchUITableSource alloc] init];
    _uiTableSource.tableView = self.tableView;
    _uiTableSource.query = liveQuery;
    [self.tableView setDataSource:_uiTableSource];
    [self.tableView setDelegate:self];
    if([mainApp isTesting])
        [self setToolbarItems:@[refreshButton]];
    else
        [self setToolbarItems:@[]];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([[GOMainApp sharedMainApp] isTesting])
        return UITableViewCellEditingStyleDelete;
    else
        return UITableViewCellEditingStyleNone;
}


- (IBAction)refreshBrews:(id)sender {
    [self.activeGoal dirtStoredBrewsForTask:self.task];
    [self.activeGoal getBrewsForTask:self.task];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell *)couchTableSource:(CouchUITableSource *)source cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CouchDocument *document = [_uiTableSource documentAtIndexPath:indexPath];
    GOTaskBrew *brew = [[CouchModelFactory sharedInstance] modelForDocument:document];
    UITableViewCell *cell;
    NSString *CellIdentifier;
    if(showDebugCells)
        CellIdentifier = @"BrewCell";
    else
        CellIdentifier = @"EarnedPointsCell";
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(0){
    }
    else {
        //GOEarnedPointsCell *earnedPointsCell = (id)cell;
    }
    
    [(id)cell configureWithBrew:brew];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CouchDocument *document = [_uiTableSource documentAtIndexPath:indexPath];
    GOTaskBrew *brew = [[CouchModelFactory sharedInstance] modelForDocument:document];
    NSDate *now = [[GOMainApp sharedMainApp] nowDate];
    if([[brew beginDate] compare:now] == NSOrderedAscending) {
        // Begin date in past
        if([[brew endDate] compare:now] == NSOrderedAscending) {
            // End date also in past
            [cell setBackgroundColor:_lightGrayColor];
        }
        else {
            [cell setBackgroundColor:_lightGreenColor];
        }
    }
    
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[GOMainApp sharedMainApp] isTesting])
        return indexPath;
    else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!showDebugCells)
        return 49.0;
    else
        return 120.0;
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

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
     *detailViewController = [[alloc] initWithNibName:@" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
    
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    CouchDocument *doc = [_uiTableSource documentAtIndexPath:indexPath];
    GOTaskBrew *selectedBrew = [[CouchModelFactory sharedInstance] modelForDocument:doc];
    GOBrewTableVC *brewTableVC = [segue destinationViewController];
    [brewTableVC setBrew:selectedBrew];
}


@end
