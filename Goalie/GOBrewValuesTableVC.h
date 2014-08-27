//
//  GOBrewValuesTableVC.h
//  Goalie
//
//  Created by Stefan Kroon on 12-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GOTaskBrew;

@interface GOBrewValuesTableVC : UITableViewController {
    NSArray *_allKeys;
}

@property GOTaskBrew *brew;

@end
