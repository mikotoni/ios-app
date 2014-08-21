//
//  GOAdvancedBrewsTableVC.m
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAdvancedBrewsTableVC.h"
#import "GOMainApp.h"
#import "GOBrewCell.h"
#import "GOBrewTableVC.h"
#import "GOGoalieServices.h"

@interface GOAdvancedBrewsTableVC ()

@end

@implementation GOAdvancedBrewsTableVC

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
    
    liveQuery = [[[GOMainApp sharedMainApp] goalieServices] liveQueryForAllBrews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CouchModelFactory *modelFactory = [CouchModelFactory sharedInstance];
    NSMutableArray *allValidBrews = [[NSMutableArray alloc] init];
    [liveQuery wait];
    enumerator = [liveQuery rows];
    
    CouchQueryRow *row;
    
    while((row = [enumerator nextRow])) {
        CouchDocument *doc = [row document];
        GOTaskBrew *brew = [modelFactory modelForDocument:doc];
        if(brew && [[[brew activeGoal] document] isDeleted])
            [allValidBrews addObject:brew];
    }

    visibleBrews = [allValidBrews copy];
}

- (void)deleteAll:(id)sender {
    NSMutableSet *operations = [[NSMutableSet alloc] initWithCapacity:[visibleBrews count]];
    [visibleBrews enumerateObjectsUsingBlock:^(GOTaskBrew *brew, NSUInteger idx, BOOL *stop) {
        RESTOperation * op = [brew deleteDocument];
        [op start];
        [operations addObject:op];
    }];
    [RESTOperation wait:operations];
    [self.tableView reloadData];
    return;
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
    if(visibleBrews)
        return [visibleBrews count];
    else
        return [enumerator count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BrewCell";
    GOBrewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    GOTaskBrew *brew;
    NSUInteger rowIndex = [indexPath row];
    
    if(visibleBrews) {
        brew = [visibleBrews objectAtIndex:rowIndex];
    }
    else {
        CouchQueryRow *row = [enumerator rowAtIndex:rowIndex];
        CouchDocument *doc = [row document];
        brew = [[CouchModelFactory sharedInstance] modelForDocument:doc];
    }
    
    [cell configureWithBrew:brew];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return 120.0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSUInteger selectedRow = [indexPath row];
    GOTaskBrew *selectedBrew;
    if(visibleBrews) {
        selectedBrew = [visibleBrews objectAtIndex:selectedRow];
    }
    else {
        CouchQueryRow *row = [enumerator rowAtIndex:selectedRow];
        CouchDocument *doc = [row document];
        selectedBrew = [[CouchModelFactory sharedInstance] modelForDocument:doc];
    }
    GOBrewTableVC *brewTableVC = [segue destinationViewController];
    [brewTableVC setBrew:selectedBrew];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

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
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
