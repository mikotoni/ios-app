//
//  GOMonitoredRegionsTableVC.h
//  Goalie
//
//  Created by Stefan Kroon on 10-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOMonitoredRegionsTableVC : UITableViewController {
    NSArray *_monitoredRegions;
}

- (IBAction)refreshRegions:(id)sender;

@end
