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

- (IBAction)didTapSave:(id)sender{
    [self donePressed:@{@"popup": [NSNumber numberWithBool:YES]}];
}
- (IBAction)didTapUpHour:(id)sender{
    int hour = [hourLabel.text intValue]+1;
    [hourLabel setText:[NSString stringWithFormat:@"%02d",hour > 23?0:hour]];
}
- (IBAction)didTapDownHour:(id)sender{
    int hour = [hourLabel.text intValue]-1;
    [hourLabel setText:[NSString stringWithFormat:@"%02d",hour < 0?23:hour]];
}

- (IBAction)didTapUpMinutes:(id)sender{
    int minute = [minuteLabel.text intValue]+1;
    [minuteLabel setText:[NSString stringWithFormat:@"%02d",minute > 59?0:minute]];
}

- (IBAction)didTapDownMinutes:(id)sender{
    int minute = [minuteLabel.text intValue]-1;
    [minuteLabel setText:[NSString stringWithFormat:@"%02d",minute < 0?59:minute]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
