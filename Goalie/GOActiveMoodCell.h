//
//  GOActiveMoodCell.h
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractActiveTaskCell.h"

@interface GOActiveMoodCell : GOAbstractActiveTaskCell {
    NSDateFormatter *hourFormatter;
}

@property IBOutlet UILabel *descriptionLabel;

@end
