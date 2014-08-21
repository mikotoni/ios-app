//
//  GOOpenQuestionTaskViewController.h
//  Goalie
//
//  Created by Stefan Kroon on 03-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractTaskVC.h"

@interface GOOpenQuestionTaskVC : GOAbstractTaskVC <GOTaskVCProtocol> {
    IBOutlet UITextView *questionView;
    IBOutlet UITextView *answerView;
}


//@property GOOpenQuestionTask *task;

- (IBAction)cancel:(id)sender;

@end
