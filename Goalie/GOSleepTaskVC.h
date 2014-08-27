//
//  GOSleepTaskVC.h
//  Goalie
//
//  Created by Stefan Kroon on 14-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractTaskVC.h"

@interface GOSleepTaskVC : GOAbstractTaskVC <GOTaskVCProtocol>

@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;

@end
