//
//  GOGoalCell.m
//  Goalie
//
//  Created by Stefan Kroon on 06-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOGoalCell.h"

// Model
#import "GOActiveGoal.h"
#import "GOAgoraphobiaGoal.h"
#import "GORegularSleepGoal.h"

// Services
#import "GOMainApp.h"
#import "GOGoalieServices.h"

// Misc
#import "CustomBadge.h"

@implementation GOGoalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    goalieServices = [[GOMainApp sharedMainApp] goalieServices];
}

- (void)setBadgeVisible:(bool)isVisible text:(NSString *)text {
    //NSLog(@"%s isVisible:%d text:%@", __PRETTY_FUNCTION__, isVisible, text);
    UIView *badgeView = self.badgeView;
    if(isVisible) {
        if(!_customBadge) {
            _customBadge = [CustomBadge customBadgeWithString:text];
            [badgeView addSubview:_customBadge];
            [badgeView layoutIfNeeded];
            CGRect frame = _customBadge.frame;
            CGRect bounds = badgeView.bounds;
            CGFloat x = bounds.size.width - frame.size.width;
            CGFloat y = 0.0;
            [_customBadge setFrame:CGRectMake(x, y, frame.size.width, frame.size.height)];
        }
        else {
            [_customBadge setBadgeText:text];
            [_customBadge setNeedsDisplay];
        }
    }
    [badgeView setHidden:NO];
    if((!badgeIsVisible && isVisible) || (badgeIsVisible && !isVisible)) {
        _customBadge.alpha = (isVisible ? 0.0 : 1.0);
           [UIView animateWithDuration:1.0 animations:^{
                _customBadge.alpha = (isVisible ? 1.0 : 0.0);
        }];
    }
    badgeIsVisible = isVisible;
}

- (void)configureForActiveGoal:(GOActiveGoal *)activeGoal {
    //GOGoal *goal = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //NSDate *deadline;
    
    GOGoal *goal = [activeGoal goal];
    [self setActiveGoal:activeGoal];
    
    NSString *headline = @"Onbekend doel";
    headline = [activeGoal title];
    if(!headline && goal)
        headline = [goal valueForKey:@"headline"];
    
    NSString *iconImageName = [activeGoal iconImageName];
    
    self.goalIconImageView.image = [UIImage imageNamed:iconImageName];
    self.headline.text = headline;
    self.headline.enabled = YES;
    if([activeGoal isKindOfClass:[GOAgoraphobiaGoal class]] || [activeGoal isKindOfClass:[GORegularSleepGoal class]]) {
        //self.headline.enabled = NO;
    }
    
    [self performSelector:@selector(updateUncompletedTasksBadge) withObject:nil afterDelay:1.0];
    
    // Observe changes
    [self cancelNofUncompletedTaskObserving];
    [self startNofUncompletedTaskOberving];
    
    
}


// Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:nofUncompltedKeyPath]) {
        [self performSelector:@selector(updateUncompletedTasksBadge) withObject:nil afterDelay:0.5];
    }
    else if(object == _activeGoal) {
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateCompletionRate) userInfo:nil repeats:NO];
    }
}

- (void)cancelCompletionRateObserving {
    if(_activeGoal)
        [_activeGoal removeObserver:self forKeyPath:@"completionRate"];
}

- (void)startCompletionRateObserving {
    if(_activeGoal)
        [_activeGoal addObserver:self forKeyPath:@"completionRate" options:0 context:NULL];
}

- (void)cancelNofUncompletedTaskObserving {
    if(nofUncompltedKeyPath)
        [goalieServices.nofUncompletedTasksPerActiveGoal removeObserver:self forKeyPath:nofUncompltedKeyPath];
}

- (void)startNofUncompletedTaskOberving {
    nofUncompltedKeyPath = [NSString stringWithFormat:@"%@", [self.activeGoal.document documentID]];
    [goalieServices.nofUncompletedTasksPerActiveGoal addObserver:self forKeyPath:nofUncompltedKeyPath options:0 context:nil];
}

- (void)dealloc {
    [self cancelCompletionRateObserving];
    [self cancelNofUncompletedTaskObserving];
}

- (void)updateUncompletedTasksBadge {
    NSDate *nowDate = [[GOMainApp sharedMainApp] nowDate];
    NSUInteger nofUncompletedTasks = [self.activeGoal nofUncompletedTasksForDate:nowDate];
    NSString *badgeText = nil;
    bool visibleBadge = NO;
    if(nofUncompletedTasks > 0) {
        badgeText = [[NSNumber numberWithUnsignedInteger:nofUncompletedTasks] stringValue];
        visibleBadge = YES;
    }
    [self setBadgeVisible:visibleBadge text:badgeText];
}

- (void)updateCompletionRate {
    if(self.activeGoal) {
        float completionRate = [[self.activeGoal completionRate] floatValue];
        [self.progress setProgress:completionRate animated:YES];
    }
}

- (GOActiveGoal *)activeGoal {
    return _activeGoal;
}

- (void)setActiveGoal:(GOActiveGoal *)activeGoal {
    [self cancelCompletionRateObserving];
    _activeGoal = activeGoal;
    [self startCompletionRateObserving];
    [self updateCompletionRate];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
