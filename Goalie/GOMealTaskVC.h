//
//  GOMealVC.h
//  Goalie
//
//  Created by Stefan Kroon on 23-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractTaskVC.h"


@interface GOMealTaskVC : GOAbstractTaskVC  <GOTaskVCProtocol> {
    IBOutlet UIDatePicker *_timePicker;
    IBOutlet UISegmentedControl *_didHaveMealControl;
    //IBOutlet UISegmentedControl *_mealKindControl;
    IBOutlet UILabel *_questionLabel;
    IBOutlet UILabel *_atWhatTimeLabel;
}

//- (IBAction)kindChanged:(id)sender;
- (IBAction)segmentChanged:(id)sender;
- (IBAction)cancel:(id)sender;
    
//@property GOMealTask *task;

@end
