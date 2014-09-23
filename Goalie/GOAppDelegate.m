//
//  GOAppDelegate.m
//  Goalie
//
//  Created by Stefan Kroon on 16-04-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAppDelegate.h"
#import "GOMainApp.h"
#import "GOGoalieServices.h"
#import "GOSensePlatform.h"
#import "RightMenuViewController.h"

@implementation GOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
//    [self setSlideMenu];
    return YES;
}
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UILocalNotification *notification =
        [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if(notification) {
        self.launchNotification = notification;
    }
    self.mainApp = [GOMainApp sharedMainApp];
    [self.mainApp initialize:nil];
    [[UILabel appearance] setFont:[UIFont fontWithName:@"ProximaNova-Regular" size:14]];
    [[UITextView appearance] setFont:[UIFont fontWithName:@"ProximaNova-Regular" size:14]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor],UITextAttributeFont:[UIFont fontWithName:@"ProximaNova-Bold" size:16]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    isBecomingForeground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    isBecomingForeground = NO;
    
    GOSensePlatform *sensePlatform = [self.mainApp sensePlatform];
    if(sensePlatform) {
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
        [sensePlatform addVersionInfoDataPoint:version build:build];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[GOMainApp sharedMainApp] willTerminate];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"[GOAppDelegate application:didReceiveLocalNotification:]");
    GOGoalieServices *goalieServices = [[GOMainApp sharedMainApp] goalieServices];
    [goalieServices processLocalNotification:notification whileInForeground:!isBecomingForeground];
}
- (void)setSlideMenu{
}
#pragma mark - Application's Documents directory

@end
