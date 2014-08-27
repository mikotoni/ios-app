//
//  GOActiveTaskCell.h
//  Goalie
//
//  Created by Stefan Kroon on 09-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOActiveTaskCell : UITableViewCell {
}

@property IBOutlet UILabel *beginDateLabel;
@property IBOutlet UILabel *endDateLabel;
@property IBOutlet UILabel *earnedPointsLabel;
@property IBOutlet UILabel *completedLabel;
@property IBOutlet UILabel *occurrenceLabel;
@property IBOutlet UILabel *triggerLabel;

@end
