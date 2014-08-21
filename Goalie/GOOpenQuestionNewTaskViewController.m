//
//  GOOpenQuestionTaskViewController.m
//  Goalie
//
//  Created by Stefan Kroon on 03-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOOpenQuestionNewTaskViewController.h"
#import "GONewGoalTasksViewController.h"
#import "GOOpenQuestionTask.h"
#import "GOAppDelegate.h"
#import "GOMainApp.h"

@interface GOOpenQuestionNewTaskViewController ()

@end

@implementation GOOpenQuestionNewTaskViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)donePressed:(id)sender {
    
    
    UINavigationController *navigationController = [self navigationController];
    NSArray *viewControllers = [navigationController viewControllers];
    GONewGoalTasksViewController __block *newGoalVC = nil;
    [viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[GONewGoalTasksViewController class]]) {
            newGoalVC = obj;
            *stop = YES;
        }
    }];
    if(newGoalVC) {
        GOAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *moc = [appDelegate managedObjectContext];
        GOOpenQuestionTask *openQuestionTask = [GOOpenQuestionTask openQuestionTaskInManagedObjectContext:moc];
        NSString *questionText = [questionView text];
        [openQuestionTask setQuestion:questionText];
        [openQuestionTask setName:questionText];
        GOGoal *aspirantGoal = [[GOMainApp sharedMainApp] editingGoal];
        [aspirantGoal addTasksObject:openQuestionTask];
        [[self navigationController] popToViewController:newGoalVC animated:YES];
    }
}

@end
