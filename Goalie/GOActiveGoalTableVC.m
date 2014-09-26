//
//  GOAciveGoalTableVC.m
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveGoalTableVC.h"

// Model
#import "GOGenericModelClasses.h"
#import "GOShootPhotoTask.h"
#import "GOMealTask.h"
#import "GOSleepTask.h"
#import "GORegularMealsGoal.h"
// Services
#import "GOMainApp.h"

// UI
#import "GOActiveGoalCell.h"
#import "GOActiveTaskCell.h"
#import "GOAbstractActiveTaskCell.h"
#import "GOAbstractTaskVC.h"
#import "GOGoalExplanationVC.h"

#import "GOMealTaskVC.h"
#import "GOSleepTaskVC.h"

#define informationFont [UIFont fontWithName:@"HelveticaNeue" size:16.0]

@interface GOActiveGoalTableVC ()

@end

@implementation GOActiveGoalTableVC

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
//    UILabel* lbNavTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,40,320,50)];
//    lbNavTitle.textAlignment = NSTextAlignmentLeft;
//    lbNavTitle.text = [[self.activeGoal title] uppercaseString];
//    lbNavTitle.adjustsFontSizeToFitWidth = NO;
//    lbNavTitle.font = [UIFont fontWithName:@"ProximaNova-Bold" size:17];
//    [lbNavTitle setTextColor:[UIColor whiteColor]];
//    self.navigationItem.titleView = lbNavTitle;
    self.title = [[self.activeGoal title] uppercaseString];
//    UILabel* lbNavTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,40,320,40)];
//    lbNavTitle.textAlignment = NSTextAlignmentLeft;
//    lbNavTitle.text = @"GOALIE";
//    [lbNavTitle setTextColor:[UIColor whiteColor]];
//    self.navigationItem.titleView = lbNavTitle;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadBrews];
}
- (void)loadBrews{
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    NSDate *nowDate = [mainApp nowDate];
    brews = [self.activeGoal getBrewsForDate:nowDate];
    brews = [brews sortedArrayUsingComparator:^NSComparisonResult(GOTaskBrew *brew1, GOTaskBrew *brew2) {
        NSNumber *indexNumber1 = [[brew1 task] indexNumber];
        NSNumber *indexNumber2 = [[brew2 task] indexNumber];
        return [indexNumber1 compare:indexNumber2];
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.activeGoal isKindOfClass:[GORegularMealsGoal class]]) {
        return 5;
    }
    return 2 + [brews count];
}

- (GOTaskBrew *)brewForIndexPath:(NSIndexPath *)indexPath {
    NSUInteger rowIndex = [indexPath row];
    GOTaskBrew *brew = nil;
    if(rowIndex > 0)
        brew = [brews objectAtIndex:rowIndex - 1];
    return brew;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    NSUInteger rowIndex = [indexPath row];
    UITableViewCell *cell;
    if(rowIndex == 0) {
        cellIdentifier = @"ActiveGoalCell";
        GOActiveGoalCell *activeGoalCell =
            [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [activeGoalCell setActiveGoal:self.activeGoal];
        cell = activeGoalCell;
    }
    else if(((rowIndex == 1 + [brews count]) && ![self.activeGoal isKindOfClass:[GORegularMealsGoal class]])||(rowIndex == 4 && [self.activeGoal isKindOfClass:[GORegularMealsGoal class]])){
        cellIdentifier = @"ActiveInformationCell";
        cell =
        [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        NSString *strText = [NSString stringWithFormat:@"%@",self.activeGoal.explanation];
        UILabel *label = (UILabel*)[cell viewWithTag:1];
        CGRect paragraphRect =
        [strText boundingRectWithSize:CGSizeMake(300, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:informationFont} context:nil];
        CGRect frame = label.frame;
        frame.origin.y = 0;
        frame.size.height = paragraphRect.size.height;
        label.frame = frame;
        [label setText:strText];
    }
    else{
        if (indexPath.row <= [brews count]) {
            GOTaskBrew *brew = [self brewForIndexPath:indexPath];
            GOActiveTask *activeTask = [brew activeTask];
            cellIdentifier = [activeTask activeCellIdentifier];
            GOAbstractActiveTaskCell *activeTaskCell =
            [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            [activeTaskCell setBrew:brew];
            if ([self.activeGoal isKindOfClass:[GORegularMealsGoal class]]) {
            
            }
            cell = activeTaskCell;
        }
        else{
            GOAbstractActiveTaskCell *activeTaskCell = [tableView dequeueReusableCellWithIdentifier:@"ActiveMealCell" forIndexPath:indexPath];
            cell = activeTaskCell;
            cell.contentView.alpha = 0.5;
            cell.userInteractionEnabled = NO;
        }
        
    }
    
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
    //selectedBrew = [brews objectAtIndex:[indexPath row] -1];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    if (indexPath.row != 0 && indexPath.row != 1 + [brews count]) {
        GOTaskBrew *brew = [self brewForIndexPath:indexPath];
        GOActiveTask *activeTask = [brew activeTask];
        if ([activeTask isKindOfClass:[GOActiveMealTask class]]) {
            GOMealTaskVC *modal = (GOMealTaskVC *)[storyBoard instantiateViewControllerWithIdentifier:@"MealTask"];
            modal.delegate = self;
            selectedBrew = [brews objectAtIndex:[indexPath row] -1];
            
            [modal setEditMode:NO];
            [modal setBrew:selectedBrew];
            [[KGModal sharedInstance] setCloseButtonType:KGModalCloseButtonTypeNone];
            [[KGModal sharedInstance] showWithContentViewController:modal andAnimated:YES];
        }
//        else if ([activeTask isKindOfClass:[GOActiveSleepTask class]]){
//            GOSleepTaskVC *modal = (GOSleepTaskVC *)[storyBoard instantiateViewControllerWithIdentifier:@"MealTask"];
//            [[KGModal sharedInstance] setCloseButtonType:KGModalCloseButtonTypeNone];
//            [[KGModal sharedInstance] showWithContentViewController:modal andAnimated:YES];
//        }
    }
 }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue destinationViewController] isKindOfClass:[GOGoalExplanationVC class]]) {
        GOGoalExplanationVC *goalExplanationVC = (id)[segue destinationViewController];
        [goalExplanationVC setActiveGoal:self.activeGoal];
    }
    else {
        UIViewController <GOTaskVCProtocol> *taskVC = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        selectedBrew = [brews objectAtIndex:[indexPath row] -1];
        
        [taskVC setEditMode:NO];
        [taskVC setBrew:selectedBrew];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    if((row == 1 + [brews count] && ![self.activeGoal isKindOfClass:[GORegularMealsGoal class]])||
       (row == 4 && [self.activeGoal isKindOfClass:[GORegularMealsGoal class]])){
        NSString *strText = [NSString stringWithFormat:@"%@",self.activeGoal.explanation];
        CGRect paragraphRect =
        [strText boundingRectWithSize:CGSizeMake(300, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:informationFont} context:nil];
        return paragraphRect.size.height+14;
    }
    else if(row == 0){
        return 188.0;
    }
    else if(row < [brews count]){
        GOTaskBrew *brew = [self brewForIndexPath:indexPath];
        if ([[brew task] isKindOfClass:[GOShootPhotoTask class]]) {
            return 250.0;
        }
    }
    return 70;
}

- (void)doneAction{
    [self loadBrews];
    [self.tableView reloadData];
}
@end
