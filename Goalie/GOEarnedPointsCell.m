//
//  GOEarnedPointsCell.m
//  Goalie
//
//  Created by Stefan Kroon on 13-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOEarnedPointsCell.h"
#import "GOMainApp.h"
#import "GOGenericModelClasses.h"
#import "TimeWindow.h"

@implementation GOEarnedPointsCell

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
    _pointsLabel.text = [[brew earnedPoints] stringValue];
    
    //NSDateComponents *endComponents = [curCal components:NSHourCalendarUnit fromDate:endDate];
    TimeWindow *timeWindow = [brew timeWindow];
    NSDate *nowDate = [[GOMainApp sharedMainApp] nowDate];
    
    NSString *dateString = [timeWindow relativeDescriptionFromDate:nowDate];
    
    // Show or hide the accessory arrow, depending on isTesting
    if([[GOMainApp sharedMainApp] isTesting]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    _dateLabel.text = dateString;
}




@end
