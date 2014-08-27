//
//  GOLoginViewController.m
//  Goalie
//
//  Created by Stefan Kroon on 16-04-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOLoginViewController.h"
#import "GOMainApp.h"
#import "GOKeychain.h"
#import "GOSensePlatform.h"
#import "GOKeychain.h"

@interface GOLoginViewController ()

@end

@implementation GOLoginViewController

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    GOKeychain *keychain = [[GOMainApp sharedMainApp] keychain];
    NSString *username = keychain.username;
    NSString *password = keychain.password;
    
    if(username)
        [usernameTextField setText:username];
    if(password)
        [passwordTextField setText:password];
    
    if(self.loginMessage && ![self.loginMessage isEqualToString:@""]) {
        [loginMessageLabel setText:self.loginMessage];
        [loginMessageLabel setHidden:NO];
    }
    else
        [loginMessageLabel setHidden:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginPressed:(id)sender {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    GOSensePlatform *sensePlatfrom = [mainApp sensePlatform];
    GOKeychain *keychain = [mainApp keychain];
    
    if([usernameTextField isFirstResponder])
        [usernameTextField resignFirstResponder];
    if([passwordTextField isFirstResponder])
        [passwordTextField resignFirstResponder];
    
    NSString *username = [usernameTextField text];
    NSString *password = [passwordTextField text];
    
    bool loginSuccess = [sensePlatfrom loginWithUsername:username password:password];
    if(loginSuccess) {
        [keychain storeUsername:username password:password];
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    }
    else {
        [[GOMainApp sharedMainApp] errorAlertMessage:@"Het inloggen is mislukt"];
    }
}


@end
