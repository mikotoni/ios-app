//
//  GOOpenQuestionTaskViewController.h
//  Goalie
//
//  Created by Stefan Kroon on 03-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOOpenQuestionNewTaskViewController : UIViewController {
    IBOutlet UITextView *questionView;
}

- (IBAction)donePressed:(id)sender;

@end
