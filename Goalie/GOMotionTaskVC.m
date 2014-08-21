//
//  GOMotionTaskVC.m
//  Goalie
//
//  Created by Stefan Kroon on 08-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOMotionTaskVC.h"
#import "GOMotionTask.h"
#import "GOTaskBrew.h"
#import "GOMainApp.h"
#import "GOSensePlatform.h"

@interface GOMotionTaskVC ()

@end

@implementation GOMotionTaskVC

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

- (void)showGoalInMinutes:(NSNumber *)targetInMinutes {
    int targetInMinutesInt = [targetInMinutes intValue];
    NSString *goalValue = [NSString stringWithFormat:@"%d", targetInMinutesInt];
    [self.goalValueLabel setText:goalValue];
    
}

- (void)showActual:(NSNumber *)actualInSeconds targetInMinutes:(NSNumber  *)targetInMinutes {
    int targetInMinutesInt = [targetInMinutes intValue];
    int actualInSecondsInt = [actualInSeconds intValue];
    int actualInMinutesInt = actualInSecondsInt / 60;
    int actualSeconds = actualInSecondsInt % 60;
    
    NSString *actualValue = [NSString stringWithFormat:@"%d:%02d", actualInMinutesInt, actualSeconds];
    
    UIColor *labelColor;
    if(actualInMinutesInt < targetInMinutesInt)
        labelColor = [UIColor redColor];
    else
        labelColor = [UIColor greenColor];
    
    UILabel *actualValueLabel = self.actualValueLabel;
    [actualValueLabel setTextColor:labelColor];
    [actualValueLabel setText:actualValue];
}

- (void)updateWithBrew:(GOTaskBrew *)brew {
    GOActiveMotionTask *activeMotionTask = [[GOActiveMotionTask alloc] initWithBrew:brew];
    NSNumber *dailyTargetInMinutes = [activeMotionTask dailyTargetInMinutes];
    NSNumber *actualInSeconds = [brew valueForKey:kGOTimeActiveInterval];
    [self showActual:actualInSeconds targetInMinutes:dailyTargetInMinutes];
    [self showGoalInMinutes:dailyTargetInMinutes];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(!self.editMode) {
        [self updateWithBrew:self.brew];
        
        [[[GOMainApp sharedMainApp] sensePlatform] startTemporaryHighFrequencyMotionDetection];
        [self addObserver:self forKeyPath:@"brew.taskResult" options:0 context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self updateWithBrew:self.brew];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeObserver:self forKeyPath:@"brew.taskResult"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
