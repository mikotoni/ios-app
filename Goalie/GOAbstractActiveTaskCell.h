//
//  GOAbstractActiveTaskCell.h
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GOGenericModelClasses.h"

@interface GOAbstractActiveTaskCell : UITableViewCell {
    GOTaskBrew *_brew;
    NSNumber *previousPoints;
}

@property GOTaskBrew *brew;

@property IBOutlet UILabel *titleLabel;
@property IBOutlet UILabel *pointsLabel;
@property IBOutlet UILabel *pointsTextLabel;

- (void)updateDisplayedValuesAnimated:(bool)animated;
- (void)updateDisplayedValuesAnimated;
    
@end
