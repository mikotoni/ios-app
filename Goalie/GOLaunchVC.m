//
//  GOLaunchVC.m
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOLaunchVC.h"
#import "GOMainApp.h"
#import "GOLoginViewController.h"
#import "GOKeychain.h"
#import "GOGoalieServices.h"

@interface GOLaunchVC ()

@end

@implementation GOLaunchVC

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueIdentifier = [segue identifier];
    if([segueIdentifier isEqualToString:@"directLogin"]) {
        GOLoginViewController *loginVC = [segue destinationViewController];
        [loginVC setLoginMessage:_loginMessage];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [label setText:@"Loading..."];
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    GOKeychain *keychain = [mainApp keychain];
    [mainApp addObserver:self forKeyPath:@"loadingText" options:NSKeyValueObservingOptionNew context:nil];
    
    if([keychain hasAutoLoginCredentials]) {
    //if([[mainApp goalieServices] validUsername]) {
        [label setText:@"Try to auto login"];
        [self performSegueWithIdentifier:@"home" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"login" sender:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    [mainApp removeObserver:self forKeyPath:@"loadingText"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    NSString *loadingText = mainApp.loadingText;
    NSLog(@"loadingText: %@", loadingText);
    [label setText:loadingText];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
