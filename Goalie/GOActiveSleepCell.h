//
//  GOActiveSleepCell.h
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractActiveTaskCell.h"
#import "GOSleepTask.h"

@interface GOActiveSleepCell : GOAbstractActiveTaskCell {
    NSDateFormatter *hourFormatter;
}

@property IBOutlet UILabel *lastNightLabel;
@property IBOutlet UILabel *desiredLabel;
@property IBOutlet UILabel *descriptionDesiredLabel;
@property IBOutlet UILabel *descriptionLastNightLabel;
@property IBOutlet UIImageView *handImageView;
@end
