//
//  GOSettingsTableVC.m
//  Goalie
//
//  Created by Stefan Kroon on 15-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOSettingsTableVC.h"

// Services
#import "GOMainApp.h"
#import "GOTestFlight.h"
#import "GOKeychain.h"

@interface GOSettingsTableVC ()

@end

@implementation GOSettingsTableVC

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    GOTestFlight *testFlight = [mainApp testFlight];
    NSDateFormatter *dateFormatter = [mainApp genericDateFormatter];
    
    // Launch time
    NSDate *launchTime = [mainApp launchTime];
    _launchTimeLabel.text = [dateFormatter stringFromDate:launchTime];
    
    // Resident memory
    NSString *residentMemoryText;
    int residentMemory = [testFlight residentMemoryInKb];
    if(residentMemory < 0)
        residentMemoryText = @"Unknown";
    else
        residentMemoryText = [NSString stringWithFormat:@"%d Kb", residentMemory];
    _residentMemoryLabel.text = residentMemoryText;
    
    
    // CPU Time
    double cpuTime = [testFlight totalCpuTime];
    _totalCpuTimeLabel.text = [NSString stringWithFormat:@"%.3f", cpuTime];
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if(selectedIndexPath)
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    _testingSwitch.on = [mainApp isTesting];
    
    NSString *username = [[mainApp keychain] username];
    _usernameLabel.text = username;
    
    if([username hasSuffix:@"almende.org"] || [username hasSuffix:@"almende.com"]) {
        [_testingSwitch setHidden:NO];
    }
}

- (void)logout {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    [mainApp logout];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"logout2"]) {
        [self logout];
    }
}

- (IBAction)testingSwitchChanged:(id)sender {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    bool oldState = mainApp.isTesting;
    bool newState = [_testingSwitch isOn];
    mainApp.isTesting = newState;
    
    if(oldState != newState) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
        if(newState) {
            [self.tableView insertSections:indexSet withRowAnimation:YES];
        }
        else {
            [self.tableView deleteSections:indexSet withRowAnimation:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[GOMainApp sharedMainApp] isTesting] ? 3 : 1;
}

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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

@end
