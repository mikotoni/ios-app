//
//  GOSettingsVC.m
//  Goalie
//
//  Created by Stefan Kroon on 10-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAdjustTimeVC.h"
#import "GOMainApp.h"

@interface GOAdjustTimeVC ()

@end

@implementation GOAdjustTimeVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)datePickerChanged:(id)sender {
    NSDate *now = [NSDate date];
    NSDate *newDate = [datePicker date];
    
    self.timeInterval = [newDate timeIntervalSinceDate:now];
}

- (IBAction)stepperChanged:(id)sender {
    double stepSize = [secondsStepper value] - 300.0;
    self.timeInterval += (NSInteger)stepSize;
    [datePicker setDate:[self localDate]];
    [secondsStepper setValue:300.0];
    [self updateLocalClock];
}

- (void)done:(id)sender {
    [[GOMainApp sharedMainApp] setTimeOffsetInterval:self.timeInterval];
    UINavigationController *navigationController = [self navigationController];
    [navigationController popViewControllerAnimated:YES];
}

- (IBAction)resetTime:(id)sender {
    self.timeInterval = 0.0;
    [datePicker setDate:[self localDate] animated:YES];
    [self updateLocalClock];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
}

- (NSDate *)localDate {
    NSDate *localDate = [[NSDate date] dateByAddingTimeInterval:_timeInterval];
    return localDate;
}

- (void)updateLocalClock {
    NSString *localTimeString = [dateFormatter stringFromDate:[self localDate]];
    [newTimeLabel setText:localTimeString];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.timeInterval = [[GOMainApp sharedMainApp] timeOffsetInterval];
    [self updateLocalClock];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLocalClock) userInfo:nil repeats:YES];
    [datePicker setDate:[self localDate]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [timer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
