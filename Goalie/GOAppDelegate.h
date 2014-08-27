//
//  GOAppDelegate.h
//  Goalie
//
//  Created by Stefan Kroon on 16-04-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GOMainApp;

@interface GOAppDelegate : UIResponder <UIApplicationDelegate> {
    bool isBecomingForeground;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UILocalNotification *launchNotification;
@property (nonatomic, retain) GOMainApp *mainApp;

@end
