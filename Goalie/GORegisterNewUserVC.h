//
//  GORegisterNewUserVCViewController.h
//  Goalie
//
//  Created by Stefan Kroon on 08-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GORegisterNewUserVC : UIViewController <UITextFieldDelegate>

@property IBOutlet UITextField *usernameTextField;
@property IBOutlet UITextField *emailTextField;
@property IBOutlet UITextField *passwordOnceTextField;
@property IBOutlet UITextField *passwordTwiceTextField;

@end
