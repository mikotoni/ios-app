//
//  GOMealVC.m
//  Goalie
//
//  Created by Stefan Kroon on 23-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOMealTaskVC.h"
#import "GOMealTask.h"
#import "GOGenericModelClasses.h"

@interface GOMealTaskVC ()

@end

@implementation GOMealTaskVC

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
- (void)setupCustomFont{
    [_questionLabel setFont:[_questionLabel.font fontWithSize:19]];
    [_atWhatTimeLabel setFont:[UIFont fontWithName:@"ProximaNova-Bold" size:21]];
    [hourLabel setFont:[hourLabel.font fontWithSize:90]];
    [separateLabel setFont:[separateLabel.font fontWithSize:90]];
    [minuteLabel setFont:[minuteLabel.font fontWithSize:90]];
    [doneButton.titleLabel setFont:[UIFont fontWithName:@"ProximaNova-Bold" size:17]];
}
- (NSString *)questionForKind:(NSString *)taskKind {
    NSString *question = NSLocalizedString(@"Heb je vandaag ontbeten?", nil);
    if([taskKind isEqualToString:GOMealTaskDinner]) {
        question = NSLocalizedString(@"Heb je vandaag gedineerd?", nil);
    }
    else if([taskKind isEqualToString:GOMealTaskLunch]) {
        question = NSLocalizedString(@"Heb je vandaag geluncht?", nil);
    }
    return question;
}

#ifdef USE_COREDATA
- (NSString *)kindForIndex:(NSInteger)index {
    switch(index) {
        default:
        case 0: return GOMealTaskBreakfast; break;
        case 1: return GOMealTaskLunch; break;
        case 2: return GOMealTaskDinner; break;
    }
}

- (void)saveNewTask {
    NSManagedObjectContext *moc = [self managedObjectContext];
    GOMealTask *newTask = [GOMealTask mealTaskInManagedObjectContext:moc];
    NSString *questionText = [_questionLabel text];
    [newTask setKind:[self kindForIndex:[_mealKindControl selectedSegmentIndex]]];
    [newTask setName:questionText];
    [self addNewTask:newTask];
    [[KGModal sharedInstance] hideAnimated:YES];
}
#endif

- (void)segmentChanged:(id)sender {
    [self updatePart2];
}

- (IBAction)cancel:(id)sender {
//    [[self navigationController] popViewControllerAnimated:YES];
    [[KGModal sharedInstance] hideAnimated:YES];
}


- (void)updatePart2 {
    bool didHaveMeal = ([_didHaveMealControl selectedSegmentIndex] == 0);
    if(didHaveMeal) {
        [_atWhatTimeLabel setHidden:NO];
        [_timePicker setHidden:NO];
    }
    else {
        [_atWhatTimeLabel setHidden:YES];
        [_timePicker setHidden:YES];
    }
}

- (void)completeTask {
    GOTaskBrew *brew = self.brew;
    GOActiveMealTask *activeMealTask = (id)[brew activeTask];
    
    bool done = ([_didHaveMealControl selectedSegmentIndex] == 0);
    NSDate *pointInTime = nil;
    if(done)
        pointInTime = [_timePicker date];
    
    [activeMealTask updateBrew:brew done:done pointInTime:pointInTime];
    
    [brew save];
}

- (void)updateQuestionForKind:(NSString *)taskKind {
    NSString *question = [self questionForKind:taskKind];
//    [_questionLabel setText:question];
}

/*
- (IBAction)kindChanged:(id)sender {
    NSString *newKind = [self kindForIndex:[_mealKindControl selectedSegmentIndex]];
    [self updateQuestionForKind:newKind];
}
 */

- (IBAction)skippedMeal:(id)sender {
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.editMode) {
        /*
        [_mealKindControl setEnabled:YES];
        [_mealKindControl setHidden:NO];
        [_timePicker setEnabled:NO];
        [_didHaveMealControl setMomentary:YES];
        [_didHaveMealControl setEnabled:NO];
        [_didHaveMealControl setSelectedSegmentIndex:-1];
        [_timePicker setEnabled:NO];
         */
    }
    else {
        //[_mealKindControl setEnabled:NO];
        //[_mealKindControl setHidden:YES];
        [_timePicker setEnabled:YES];
        [_didHaveMealControl setMomentary:NO];
        [_didHaveMealControl setEnabled:YES];
        [_timePicker setEnabled:YES];
        
        GOTaskBrew *brew = self.brew;
        GOMealTask *mealTask = [brew getTaskWithClass:[GOMealTask class]];
        GOActiveMealTask *activeMealTask = (id)[brew activeTask];
        NSString *title = [activeMealTask titleForBrew:brew];
        [[self navigationController] setTitle:title];
        [self.navigationItem setTitle:title];
        [self updateQuestionForKind:[mealTask kind]];
        NSInteger selectedSegmentIndex = 1;
        if([mealTask isDoneForBrew:brew] == YES)
            selectedSegmentIndex = 0;
        
        [_didHaveMealControl setSelectedSegmentIndex:selectedSegmentIndex];
        NSDate *pointInTime = [mealTask pointInTimeForBrew:brew];
        if(pointInTime && ![pointInTime isKindOfClass:[NSNull class]])
            [_timePicker setDate:pointInTime];
        NSCalendar *calendar            = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

        NSDateComponents *components    = [calendar components:(NSHourCalendarUnit |NSMinuteCalendarUnit) fromDate:pointInTime];
        [hourLabel setText:[NSString stringWithFormat:@"%02d",components.hour]];
        [minuteLabel setText:[NSString stringWithFormat:@"%02d",components.minute]];
        
//        [self updatePart2];
    }
    [self setupCustomFont];
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
