//
//  GOSleepTaskVC.h
//  Goalie
//
//  Created by Stefan Kroon on 14-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractTaskVC.h"

@interface GOSleepTaskVC : GOAbstractTaskVC <GOTaskVCProtocol>{
    IBOutlet UILabel *hourLabel;
    IBOutlet UILabel *separateLabel;
    IBOutlet UILabel *minuteLabel;
    IBOutlet UIButton *doneButton;
}

@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;

@end
