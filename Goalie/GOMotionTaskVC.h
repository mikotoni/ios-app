//
//  GOMotionTaskVC.h
//  Goalie
//
//  Created by Stefan Kroon on 08-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractTaskVC.h"

@interface GOMotionTaskVC : GOAbstractTaskVC

@property (weak, nonatomic) IBOutlet UILabel *actualValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *goalValueLabel;

@end
