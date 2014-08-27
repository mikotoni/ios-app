//
//  GOOpenQuestionTaskViewController.m
//  Goalie
//
//  Created by Stefan Kroon on 03-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOOpenQuestionTaskVC.h"
#import "GONewGoalTasksViewController.h"
#import "GOOpenQuestionTask.h"
#import "GOAppDelegate.h"
#import "GOMainApp.h"
#import "GOGenericModelClasses.h"

@interface GOOpenQuestionTaskVC ()

@end

@implementation GOOpenQuestionTaskVC

//@synthesize task;

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

- (IBAction)cancel:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.editMode) {
        [answerView setEditable:NO];
        [questionView setEditable:YES];
    }
    else {
        [answerView setEditable:YES];
        [questionView setEditable:NO];
        GOOpenQuestionTask *openQuestionTask = [self.brew getTaskWithClass:[GOOpenQuestionTask class]];
        [questionView setText:[openQuestionTask question]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.editMode) {
        [questionView becomeFirstResponder];
        [questionView setSelectedRange:NSMakeRange(0, 1000)];
    }
    else {
        [answerView becomeFirstResponder];
        [answerView setSelectedRange:NSMakeRange(0, 1000)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#ifdef USE_COREDATA
- (void)saveNewTask {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    NSManagedObjectContext *moc = [self managedObjectContext];
    GOOpenQuestionTask *newTask = [GOOpenQuestionTask openQuestionTaskInManagedObjectContext:moc];
    NSString *questionText = [questionView text];
    [newTask setQuestion:questionText];
    [newTask setName:questionText];
    [self addNewTask:newTask];
    GOGoal *aspirantGoal = [mainApp editingGoal];
    [aspirantGoal calculateCompletionRate];
}
#endif

- (void)completeTask {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    GOTaskBrew *brew = self.brew;
    [brew setCompletionDate:[mainApp nowDate]];
    [brew save];
}

@end
