//
//  GOEmotionTaskViewController.h
//  Goalie
//
//  Created by Stefan Kroon on 28-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractTaskVC.h"

@interface GOMoodTaskViewController : GOAbstractTaskVC <GOTaskVCProtocol, UIWebViewDelegate> {
    IBOutlet UIWebView *webView;
    IBOutlet UITextView *explanationView;
}

//@property GOMoodTask *task;
- (IBAction)cancel:(id)sender;
    
@end
