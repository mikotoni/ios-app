//
//  GOActiveMotionCell.h
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractActiveTaskCell.h"

@interface GOActiveMotionCell : GOAbstractActiveTaskCell {
    NSString *timeActiveKeypath;
}

@property IBOutlet UILabel *activityGoalLabel;
@property IBOutlet UILabel *actualActivityLabel;
@property IBOutlet UIImageView *handImageView;

@end
