//
//  GOSwitchTaskVC.m
//  Goalie
//
//  Created by Stefan Kroon on 02-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOSwitchTaskVC.h"
#import "GOTaskBrew.h"
#import "GOSwitchTask.h"

@interface GOSwitchTaskVC ()

@end

@implementation GOSwitchTaskVC

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
        [explanationTextView setEditable:YES];
        [theSwitch setEnabled:NO];
        [theSwitch setOn:NO];
    }
    else {
        [explanationTextView setEditable:NO];
        GOSwitchTask *switchTask = [self.brew getTaskWithClass:[GOSwitchTask class]];
        [explanationTextView setText:[switchTask explanation]];
        [theSwitch setEnabled:YES];
        [theSwitch setOn:[[self.brew valueForKey:kGOSwitchState] boolValue]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.editMode) {
        [explanationTextView becomeFirstResponder];
        [explanationTextView setSelectedRange:NSMakeRange(0, 1000)];
    }
    else {
    }
}

- (IBAction)switchChanged:(id)sender {
    
}

- (void)completeTask {
    GOTaskBrew *brew = self.brew;
    GOActiveSwitchTask *activeSwitchTask = (id)[brew activeTask];
    [activeSwitchTask updateWithBrew:brew setState:[theSwitch isOn]];
    //[brew setValue:[NSNumber numberWithBool:[theSwitch isOn]] forKey:kGOSwitchState];
    [brew save];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
