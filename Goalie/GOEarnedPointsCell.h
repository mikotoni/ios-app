//
//  GOEarnedPointsCell.h
//  Goalie
//
//  Created by Stefan Kroon on 13-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GOTaskBrew;

@interface GOEarnedPointsCell : UITableViewCell

- (void)configureWithBrew:(GOTaskBrew *)brew;

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;

@end
