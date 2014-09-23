//
//  RightMenuViewController.m
//  SlideMenu
//
//  Created by Basytyan 
//

#import "RightMenuViewController.h"
#import "UIViewController+REFrostedViewController.h"
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

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//	return 6;
//}
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
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rightMenuCell"];
//	
//	switch (indexPath.row)
//	{
//		case 0:
//			cell.textLabel.text = @"None";
//			break;
//			
//		case 1:
//			cell.textLabel.text = @"Slide";
//			break;
//			
//		case 2:
//			cell.textLabel.text = @"Fade";
//			break;
//			
//		case 3:
//			cell.textLabel.text = @"Slide And Fade";
//			break;
//			
//		case 4:
//			cell.textLabel.text = @"Scale";
//			break;
//			
//		case 5:
//			cell.textLabel.text = @"Scale And Fade";
//			break;
//	}
//	
//	cell.backgroundColor = [UIColor clearColor];
//	
//	return cell;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}



@end
