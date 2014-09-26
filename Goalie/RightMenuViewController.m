//
//  RightMenuViewController.m
//  SlideMenu
//
//  Created by Basytyan 
//

#import "RightMenuViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "GOMasterViewController.h"
#import <CouchCocoa/CouchUITableSource.h>
#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchModelFactory.h>
#import "GOActiveGoal.h"
#import "GOMainApp.h"

@implementation RightMenuViewController

#pragma mark - UIViewController Methods -

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.tableView.separatorColor = [UIColor lightGrayColor];
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rightMenu.jpg"]];
	self.tableView.backgroundView = imageView;
	
	self.view.layer.borderWidth = .6;
	self.view.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

#pragma mark - UITableView Delegate & Datasrouce -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        GOMasterViewController *masterVC =(GOMasterViewController*) [(UINavigationController*)self.frostedViewController.contentViewController topViewController];
        CouchUITableSource *uiTableSource = masterVC.uiTableSource;
        return uiTableSource.query.rows.count;
    }
	return 4;
}
//
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
	view.backgroundColor = [UIColor clearColor];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 49, self.tableView.frame.size.width, 1)];
    line.backgroundColor = [UIColor grayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, self.tableView.frame.size.width-30, 30)];
    [label setTextColor:[UIColor lightGrayColor]];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    if (section == 0) {
        [label setText:@"Goals"];
    }
    else if(section == 1){
        [label setText:@"Others"];
    }
    [view addSubview:label];
    [view addSubview:line];
	return view;
}
//
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"goalCell"];
        if (indexPath.row == 0) {
            UILabel *labelTitle=(UILabel*)[cell viewWithTag:1];
            [labelTitle setText:@"Home"];
            UILabel *labelNotification=(UILabel*)[cell viewWithTag:2];
            labelNotification.hidden = YES;
        }
        else{
            UILabel *labelTitle=(UILabel*)[cell viewWithTag:1];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
            GOMasterViewController *masterVC =(GOMasterViewController*) [(UINavigationController*)self.frostedViewController.contentViewController topViewController];
            CouchUITableSource *uiTableSource = masterVC.uiTableSource;
            CouchDocument *document = [uiTableSource documentAtIndexPath:newIndexPath];
            GOActiveGoal *activeGoal = [[CouchModelFactory sharedInstance] modelForDocument:document];
            [labelTitle setText:activeGoal.title];
            UILabel *labelNotification=(UILabel*)[cell viewWithTag:2];
            
            labelNotification.layer.cornerRadius = 10;
            NSDate *nowDate = [[GOMainApp sharedMainApp] nowDate];
            NSUInteger nofUncompletedTasks = [activeGoal nofUncompletedTasksForDate:nowDate];
            NSString *badgeText = nil;
            labelNotification.hidden = YES;
            if(nofUncompletedTasks > 0) {
                badgeText = [[NSNumber numberWithUnsignedInteger:nofUncompletedTasks] stringValue];
                labelNotification.hidden = NO;
                labelNotification.text = badgeText;
            }
        }
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"otherCell"];
        switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = @"Settings";
                break;
                
            case 1:
                cell.textLabel.text = @"About";
                break;
                
            case 2:
                cell.textLabel.text = @"Legal Notices";
                break;
                
            case 3:
                cell.textLabel.text = @"Refresh";
                break;
        }
    }
	
	cell.backgroundColor = [UIColor clearColor];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.frostedViewController hideMenuViewController];
    GOMasterViewController *masterVC =(GOMasterViewController*) [(UINavigationController*)self.frostedViewController.contentViewController topViewController];
    if (indexPath.section == 0 && indexPath.row != 0) {
        
        [masterVC didSelectGoal:[[self staticArrayGoal] objectAtIndex:indexPath.row]];
    } else {
        switch (indexPath.row)
        {
            case 0:
                
                break;
                
            case 1:
                [masterVC performSegueWithIdentifier:@"aboutSegue" sender:nil];
                break;
                
            case 2:
                [masterVC performSegueWithIdentifier:@"legalNoticeSegue" sender:nil];
                break;
                
            case 3:
                
                break;
        }
    }
    
//    self.frostedViewController.contentViewController = navigationController;
    
}
- (NSArray *)staticArrayGoal {
    static NSArray *timeWindows = nil;
    if(!timeWindows) {
        timeWindows = @[@"Home",@"Exploring",@"Time active",@"Sleep",@"Eating",@"Emotion",@"FunActivity"];
    }
    return timeWindows;
}


@end
