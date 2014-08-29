//
//  GOAbstractTaskVC.m
//  Goalie
//
//  Created by Stefan Kroon on 23-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractTaskVC.h"
#import "GONewGoalTasksViewController.h"
#import "GOAppDelegate.h"
#import "GOMainApp.h"
#import "GOGenericModelClasses.h"

@interface GOAbstractTaskVC ()

@end

@implementation GOAbstractTaskVC

@synthesize activeTask;

- (GOTaskBrew *)brew {
    return _brew;
}

- (void)setBrew:(GOTaskBrew *)brew {
    if(brew) {
        GOActiveTask *at = [brew activeTask];
        if(at)
            self.activeTask = at;
    }
    _brew = brew;
}

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

- (GONewGoalTasksViewController *)parentNewGoalViewController {
    UINavigationController *navigationController = [self navigationController];
    NSArray *viewControllers = [navigationController viewControllers];
    GONewGoalTasksViewController __block *newGoalVC = nil;
    [viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[GONewGoalTasksViewController class]]) {
            newGoalVC = obj;
            *stop = YES;
        }
    }];
    return newGoalVC;
}

- (void)navigateBack {
    GONewGoalTasksViewController *newGoalVC = [self parentNewGoalViewController];
    if(newGoalVC) {
        UINavigationController *navigationController = [self navigationController];
        [navigationController popToViewController:newGoalVC animated:YES];
    }
    else
        [[self navigationController] popViewControllerAnimated:YES];
}

- (void)addNewTask:(GOTask *)newTask {
    GOActiveGoal *activeGoal = [[GOMainApp sharedMainApp] editingGoal];
    GOGoal *goal = [activeGoal goal];
    [goal addTasksObject:newTask];
}

- (void)donePressed:(id)sender {
    if(self.editMode) {
        [self saveNewTask];
    }
    else {
        [self completeTask];
        //GOActiveGoal *activeGoal = [[GOMainApp sharedMainApp] editingGoal];
        //GOGoal *goal = [activeGoal goal];
        //[goal calculateCompletionRate];
        //[goal calculateLastActivityDate];
    }
    if ([sender isKindOfClass:[NSDictionary class]]) {
        if ([sender[@"popup"] boolValue]) {
            [[KGModal sharedInstance] hideAnimated:YES];
            return;
        }
    }
    [self navigateBack];
}

/*
- (NSManagedObjectContext *)managedObjectContext {
    //GOAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [[GOMainApp sharedMainApp] managedObjectContext];
    return moc;
}
*/


- (void)saveNewTask {
    // Should be implemented in child class
    [NSException raise:NSInternalInconsistencyException 
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)completeTask {
    // Should be implemented in child class
    [NSException raise:NSInternalInconsistencyException 
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}


@end
