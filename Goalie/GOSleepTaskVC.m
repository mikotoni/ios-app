//
//  GOSleepTaskVC.m
//  Goalie
//
//  Created by Stefan Kroon on 14-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOSleepTaskVC.h"
#import "GOSleepTask.h"
#import "GOGenericModelClasses.h"

@interface GOSleepTaskVC ()

@end

@implementation GOSleepTaskVC

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
        [self.descriptionTextView setEditable:YES];
    }
    else {
        GOActiveSleepTask *activeSleepTask = (id)self.activeTask;
        [self.descriptionTextView setText:[activeSleepTask text]];
        [self.descriptionTextView setEditable:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.editMode) {
        [self.descriptionTextView becomeFirstResponder];
        [self.descriptionTextView setSelectedRange:NSMakeRange(0, 1000)];
    }
    else {
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
