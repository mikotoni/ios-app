//
//  GOLoginViewController.h
//  Goalie
//
//  Created by Stefan Kroon on 16-04-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOLoginViewController : UIViewController {
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UILabel *loginMessageLabel;
    IBOutlet UIButton *loginButton;
}

@property (nonatomic, retain) NSString *loginMessage;

- (IBAction)loginPressed:(id)sender;

@end
