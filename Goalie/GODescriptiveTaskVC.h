//
//  GODescriptiveTaskVC.h
//  Goalie
//
//  Created by Stefan Kroon on 02-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractTaskVC.h"

@interface GODescriptiveTaskVC : GOAbstractTaskVC <GOTaskVCProtocol> {
    IBOutlet UITextView *descriptionTextView;
}

//@property GODescriptiveTask *task;

@end
