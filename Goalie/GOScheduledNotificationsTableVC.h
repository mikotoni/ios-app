//
//  GOScheduledNotificationsTableVC.h
//  Goalie
//
//  Created by Stefan Kroon on 09-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOScheduledNotificationsTableVC : UITableViewController {
    NSDateFormatter *_dateFormatter;
    NSArray *_scheduledNotifications;
}

@end
