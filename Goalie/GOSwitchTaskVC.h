//
//  GOSwitchTaskVC.h
//  Goalie
//
//  Created by Stefan Kroon on 02-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractTaskVC.h"

@interface GOSwitchTaskVC : GOAbstractTaskVC <GOTaskVCProtocol> {
    IBOutlet UITextView *explanationTextView;
    IBOutlet UISwitch *theSwitch;
}

//@property GOSwitchTask *task;

- (IBAction)switchChanged:(id)sender;
- (IBAction)cancel:(id)sender;
    
@end
