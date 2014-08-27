//
//  GOActiveMealCell.h
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractActiveTaskCell.h"

@interface GOActiveMealCell : GOAbstractActiveTaskCell {
    NSDateFormatter *hourFormatter;
}

@property IBOutlet UILabel *preferredTimeLabel;
@property IBOutlet UILabel *registerdTimeLabel;
@property IBOutlet UIImageView *handImageView;

@end
