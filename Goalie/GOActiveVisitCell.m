//
//  GOActiveVisitCell.m
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveVisitCell.h"
#import "GOVisitTask.h"

@implementation GOActiveVisitCell

- (void)updateDisplayedValuesAnimated:(bool)animated {
    [super updateDisplayedValuesAnimated:animated];
    
    GOActiveVisitTask *activeVisitTask = (id)[_brew activeTask];
    self.titleLabel.text = [activeVisitTask titleForBrew:_brew];
    
    if(![[activeVisitTask task] groupedTask]) {
        self.nofVisitsTitle.text = NSLocalizedString(@"Deze week:", nil);
        self.nofVisitsLabel.text =
                [NSString stringWithFormat:NSLocalizedString(@"%d keer", nil),
                 [activeVisitTask nofVisitsForBrew:_brew]];
        self.nofVisitsGoalLabel.text =
                [NSString stringWithFormat:NSLocalizedString(@"min. %d keer", nil),
                 [[activeVisitTask nofVisitsGoal] integerValue]];
        self.nofVisitsGoalLabel.hidden = NO;
        self.nofVisitsGoalTitle.hidden = NO;
    }
    else {
        self.nofVisitsGoalLabel.hidden = YES;
        self.nofVisitsGoalTitle.hidden = YES;
        self.nofVisitsTitle.text = NSLocalizedString(@"Nu op locatie:", nil);
        self.nofVisitsLabel.text =
            [[_brew valueForKey:kGOVisitState] boolValue] ?
                NSLocalizedString(@"Ja", nil) :
                NSLocalizedString(@"Nee", nil);
        
    }
}

@end
