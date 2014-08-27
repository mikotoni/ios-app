//
//  GOSleepStateTableVC.m
//  Goalie
//
//  Created by Stefan Kroon on 15-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOSleepStateTableVC.h"
#import "GOMainApp.h"
#import "GOSensePlatform.h"
#import "GOSleepState.h"

@interface GOSleepStateTableVC ()

@end

@implementation GOSleepStateTableVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)updateDisplayedSleepState {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    NSDateFormatter *fomatter = [mainApp genericDateFormatter];
    GOSleepState *sleepState = [[mainApp sensePlatform] sleepState];
    _hoursLabel.text = [[NSNumber numberWithUnsignedInteger:sleepState.hours] stringValue];
    _startLabel.text = [fomatter stringFromDate:sleepState.startDate];
    _endLabel.text = [fomatter stringFromDate:sleepState.endDate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateDisplayedSleepState];
    [self startObservingSleepState];
    [[[GOMainApp sharedMainApp] sensePlatform] refreshSleepState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self cancelObservingSleepState];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:kGOSleepState]) {
        [self updateDisplayedSleepState];
    }
}

- (void)startObservingSleepState {
    GOSensePlatform *sensePlatform = [[GOMainApp sharedMainApp] sensePlatform];
    [sensePlatform addObserver:self forKeyPath:kGOSleepState options:0 context:nil];
}

- (void)cancelObservingSleepState {
    GOSensePlatform *sensePlatform = [[GOMainApp sharedMainApp] sensePlatform];
    [sensePlatform removeObserver:self forKeyPath:kGOSleepState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
