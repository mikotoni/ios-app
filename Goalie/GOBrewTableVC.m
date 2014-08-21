//
//  GOBrewTableVC.m
//  Goalie
//
//  Created by Stefan Kroon on 11-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOBrewTableVC.h"
#import "GOBrewValuesTableVC.h"
#import "GOTriggersTableVC.h"
#import "GOMainApp.h"
#import "GOGenericModelClasses.h"

@interface GOBrewTableVC ()

@end

@implementation GOBrewTableVC

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    GOTaskBrew *brew = self.brew;
    self.brewIdLabel.text = [[brew document] documentID];
    self.taskidLabel.text = [[[brew task] document] documentID];
    self.activeGoalIdLabel.text = [[[brew activeGoal] document] documentID];
    self.beginLabel.text = [_dateFormatter stringFromDate:[brew beginDate]];
    self.endLabel.text = [_dateFormatter stringFromDate:[brew endDate]];
    self.earnedPointsLabel.text = [[brew earnedPoints] description];
    self.earnedPointsStepper.value = [[brew earnedPoints] doubleValue];
    self.completedLabel.text = [_dateFormatter stringFromDate:[brew completionDate]];
    self.occurrenceLabel.text = [[brew occurrenceIndex] description];
}

- (IBAction)stepperChanged:(id)sender {
    self.earnedPointsLabel.text = [NSString stringWithFormat:@"%d", (int)[self.earnedPointsStepper value]];
}

- (IBAction)saveBrew:(id)sender {
    self.brew.earnedPoints = [NSNumber numberWithInt:(int)self.earnedPointsStepper.value];
    [self.brew save];
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

#pragma mark - Table view delegate

    /*
     - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
}
     */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = [segue identifier];
    if([segueID isEqualToString:@"SpecificValuesSegue"]) {
        GOBrewValuesTableVC *brewTableVC = [segue destinationViewController];
        [brewTableVC setBrew:self.brew];
    }
    else if([segueID isEqualToString:@"TriggersSegue"]) {
        GOTriggersTableVC *triggersVC = [segue destinationViewController];
        [triggersVC setBrew:self.brew];
    }
}

@end
