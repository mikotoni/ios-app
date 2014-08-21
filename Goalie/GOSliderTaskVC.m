//
//  GOSliderTaskVC.m
//  Goalie
//
//  Created by Stefan Kroon on 02-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOSliderTaskVC.h"
#import "GOTaskBrew.h"
#import "GOSliderTask.h"

// Misc
#import "CastFunctions.h"

@interface GOSliderTaskVC ()

@end

@implementation GOSliderTaskVC

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
    GOSliderTask *sliderTask = [self.brew getTaskWithClass:[GOSliderTask class]];
    GOActiveSliderTask *activeSliderTask = $castIf(GOActiveSliderTask, [self.brew activeTask]);
    if(self.editMode) {
        [explanationTextView setEditable:YES];
        [leftLabel setHidden:YES];
        [rightLabel setHidden:YES];
        [leftTextField setHidden:NO];
        [leftTextField setText:[NSString stringWithFormat:@"%@", [sliderTask rangeStart]]];
        [rightTextField setHidden:NO];
        [rightTextField setText:[NSString stringWithFormat:@"%@", [sliderTask rangeEnd]]];
        [sliderView setEnabled:NO];
        [currentValueTextField setHidden:YES];
    }
    else {
        [explanationTextView setEditable:NO];
        [explanationTextView setText:[sliderTask question]];
        [leftLabel setHidden:NO];
        [leftLabel setText:[NSString stringWithFormat:@"%@", [sliderTask rangeStart]]];
        [rightLabel setHidden:NO];
        [rightLabel setText:[NSString stringWithFormat:@"%@", [sliderTask rangeEnd]]];
        [leftTextField setHidden:YES];
        [rightTextField setHidden:YES];
        [sliderView setEnabled:YES];
        [currentValueTextField setHidden:NO];
        NSNumber *actualValue = [activeSliderTask actualValueForBrew:self.brew];
        [self updateCurrentValueTextView:actualValue];
        float sliderFloat = [self fromActualValueToSliderFloat:actualValue];
        [sliderView setValue:sliderFloat];
    }
}

- (NSNumber *)fromSliderFloatToActualValue:(float) sliderFloat {
    GOSliderTask *sliderTask = [self.brew getTaskWithClass:[GOSliderTask class]];
    float rangeStart = [[sliderTask rangeStart] floatValue];
    float rangeEnd = [[sliderTask rangeEnd] floatValue];
    float rangeLength = rangeEnd - rangeStart;
    
    NSNumber *newValue = [NSNumber numberWithFloat:rangeStart + (sliderFloat * rangeLength)];
    return newValue;
}

- (float)fromActualValueToSliderFloat:(NSNumber *)newValue {
    GOSliderTask *sliderTask = [self.brew getTaskWithClass:[GOSliderTask class]];
    float rangeStart = [[sliderTask rangeStart] floatValue];
    float rangeEnd = [[sliderTask rangeEnd] floatValue];
    float rangeLength = rangeEnd - rangeStart;
    
    float sliderFloat = ([newValue floatValue] - rangeStart) / rangeLength;
    return sliderFloat;
}

- (void)updateCurrentValueTextView:(NSNumber *)number {
    [currentValueTextField setText:[NSString stringWithFormat:@"%d", [number integerValue]]];
}

- (IBAction)sliderViewChanged:(id)sender {
    NSNumber *actualValue = [self fromSliderFloatToActualValue:[sliderView value]];
    [self updateCurrentValueTextView:actualValue];
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

- (void)completeTask {
    float sliderFloat = [sliderView value];
    NSNumber *actualValue = [self fromSliderFloatToActualValue:sliderFloat];
    GOTaskBrew *brew = self.brew;
    GOActiveSliderTask *activeSliderTask = (id)[brew activeTask];
    
    [activeSliderTask updateBrew:brew withValue:actualValue];
    
    [brew save];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
