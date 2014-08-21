//
//  GOSliderTaskVC.h
//  Goalie
//
//  Created by Stefan Kroon on 02-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractTaskVC.h"

@interface GOSliderTaskVC : GOAbstractTaskVC <GOTaskVCProtocol> {
    IBOutlet UISlider *sliderView;
    IBOutlet UITextView *explanationTextView;
    IBOutlet UILabel *leftLabel;
    IBOutlet UILabel *rightLabel;
    IBOutlet UITextField *currentValueTextField;
    IBOutlet UITextField *leftTextField;
    IBOutlet UITextField *rightTextField;
}

//@property GOSliderTask *task;

- (IBAction)sliderViewChanged:(id)sender;
- (IBAction)cancel:(id)sender;

@end
