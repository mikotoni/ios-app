//
//  GOSettingsVC.h
//  Goalie
//
//  Created by Stefan Kroon on 10-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOAdjustTimeVC : UIViewController  {
    IBOutlet UILabel *newTimeLabel;
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UIStepper *secondsStepper;
    NSDateFormatter *dateFormatter;
    NSTimer *timer;
}

@property (nonatomic) NSTimeInterval timeInterval;

- (IBAction)datePickerChanged:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)stepperChanged:(id)sender;
- (IBAction)resetTime:(id)sender;

@end
