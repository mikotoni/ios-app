//
//  GOTriggersTableVCViewController.h
//  Goalie
//
//  Created by Stefan Kroon on 13-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GOTaskBrew;

@interface GOTriggersTableVC : UITableViewController {
    NSArray *_triggers;
    NSDateFormatter *_dateFormatter;
}

@property GOTaskBrew *brew;

@end
