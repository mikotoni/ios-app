//
//  GORegisterNewUserVCViewController.m
//  Goalie
//
//  Created by Stefan Kroon on 08-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GORegisterNewUserVC.h"

@interface GORegisterNewUserVC ()

@end

@implementation GORegisterNewUserVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _usernameTextField.delegate = self;
    _emailTextField.delegate = self;
    _passwordOnceTextField.delegate = self;
    _passwordTwiceTextField.delegate =self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == _usernameTextField)
        [_emailTextField becomeFirstResponder];
    else if(textField == _emailTextField)
        [_passwordOnceTextField becomeFirstResponder];
    else if(textField == _passwordOnceTextField)
        [_passwordTwiceTextField becomeFirstResponder];
    else
        ; // Should submit form here
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
