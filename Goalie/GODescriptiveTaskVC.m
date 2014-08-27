//
//  GODescriptiveTaskVC.m
//  Goalie
//
//  Created by Stefan Kroon on 02-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GODescriptiveTaskVC.h"
#import "GOTaskBrew.h"
#import "GODescriptiveTask.h"

@interface GODescriptiveTaskVC ()

@end

@implementation GODescriptiveTaskVC

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.editMode) {
        [descriptionTextView setEditable:YES];
    }
    else {
        GOActiveDescriptiveTask *activeDescriptiveTask = (id)self.activeTask;
        [descriptionTextView setText:[activeDescriptiveTask text]];
        [descriptionTextView setEditable:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.editMode) {
        [descriptionTextView becomeFirstResponder];
        [descriptionTextView setSelectedRange:NSMakeRange(0, 1000)];
    }
    else {
    }
}

- (void)completeTask {
   // Do really nothing for this task
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
