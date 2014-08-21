//
//  GOActiveVisitCell.h
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractActiveTaskCell.h"

@interface GOActiveVisitCell : GOAbstractActiveTaskCell

@property IBOutlet UILabel *nofVisitsLabel;
@property IBOutlet UILabel *nofVisitsGoalLabel;

@property IBOutlet UILabel *nofVisitsTitle;
@property IBOutlet UILabel *nofVisitsGoalTitle;

@end
