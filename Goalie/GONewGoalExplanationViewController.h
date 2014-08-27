//
//  GONewGoalExplanationViewController.h
//  Goalie
//
//  Created by Stefan Kroon on 19-04-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GONewGoalExplanationViewController : UIViewController {
    IBOutlet UITextView *textView;
}

- (IBAction)donePressed:(id)sender;

@end
