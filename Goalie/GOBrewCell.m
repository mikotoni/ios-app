//
//  GOBrewCell.m
//  Goalie
//
//  Created by Stefan Kroon on 09-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOBrewCell.h"
#import "GOMainApp.h"
#import "GOGenericModelClasses.h"

@implementation GOBrewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithBrew:(GOTaskBrew *)brew {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    NSDateFormatter *dateFormatter = [mainApp genericDateFormatter];
    NSDate *now = [mainApp nowDate];
    UIColor *red = [UIColor redColor];
    UIColor *black = [UIColor blackColor];
    //NSLocale *currentLocale = [NSLocale currentLocale];
    
    NSDate *beginDate = [brew beginDate];
    //UILabel *beginLabel = [cell beginDateLabel];
    NSString *beginString = [dateFormatter stringFromDate:beginDate];
    [_beginDateLabel setText:beginString];
    if([beginDate compare:now] == NSOrderedAscending)
        [_beginDateLabel setTextColor:red];
    else
        [_beginDateLabel setTextColor:black];
        
    NSDate *endDate = [brew endDate];
    NSString *endString = [dateFormatter stringFromDate:endDate];
    [_endDateLabel setText:endString];
    if([endDate compare:now] == NSOrderedAscending)
        [_endDateLabel setTextColor:red];
    else
        [_endDateLabel setTextColor:black];
    
    [_occurrenceLabel setText:[[brew occurrenceIndex] stringValue]];
    NSString *completedString = [dateFormatter stringFromDate:[brew completionDate]];
    [_completedLabel setText:completedString];
    [_earnedPointsLabel setText:[[brew earnedPoints] stringValue]];
    NSArray *triggers = [brew triggers];
    NSUInteger nofTriggers = [triggers count];
    NSString *triggerString = nil;
    switch(nofTriggers) {
        case 0:
            triggerString = @"-";
            break;
        case 1: {
            GOActiveTrigger *trigger = [triggers objectAtIndex:0];
            triggerString = [dateFormatter stringFromDate:[trigger pointInTime]];
            break;
        }
        default:
            triggerString = [NSString stringWithFormat:@"%d triggers", nofTriggers];
            break;
    }
    [_triggerLabel setText:triggerString];
}

@end
