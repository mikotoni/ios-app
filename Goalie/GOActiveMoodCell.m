//
//  GOActiveMoodCell.m
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveMoodCell.h"
#import "GOGenericModelClasses.h"
#import "GOMoodTask.h"
#import "TimeWindow.h"
#import "GOMainApp.h"

@implementation GOActiveMoodCell

- (void)awakeFromNib {
    hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateStyle:NSDateFormatterNoStyle];
    [hourFormatter setTimeStyle:NSDateFormatterShortStyle];
}

- (void)updateDisplayedValuesAnimated:(bool)animated {
    [super updateDisplayedValuesAnimated:animated];
    
    GOActiveMoodTask *activeMoodTask = (id)[_brew activeTask];
    //GOMoodTask *moodTask = (id)[activeMoodTask task];
    
    self.titleLabel.text = [activeMoodTask titleForBrew:_brew];
    NSString *text;
    if([_brew hasPastCompletionDate])
        text = [hourFormatter stringFromDate:_brew.completionDate];
    else
        text = @"--:--";
    self.registrationTimeLabel.text = text;
    
}

/*
- (void)startObservingMoodComplete {
    if(_brew)
        [_brew addObserver:self forKeyPath:@"completionDate" options:0 context:nil];
}

- (void)cancelObservingMoodComplete {
    if(_brew)
        [_brew removeObserver:self forKeyPath:@"completionDate"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self updateDisplayedValuesAnimated:YES];
}

- (void)dealloc {
    [self cancelObservingMoodComplete];
}

- (void)setBrew:(GOTaskBrew *)brew {
    [self cancelObservingMoodComplete];
    [super setBrew:brew];
    [self startObservingMoodComplete];
}
 */

@end
