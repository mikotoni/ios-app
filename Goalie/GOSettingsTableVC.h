//
//  GOSettingsTableVC.h
//  Goalie
//
//  Created by Stefan Kroon on 15-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOSettingsTableVC : UITableViewController {
    IBOutlet UILabel *_launchTimeLabel;
    IBOutlet UILabel *_residentMemoryLabel;
    IBOutlet UILabel *_totalCpuTimeLabel;
    
    IBOutlet UISwitch *_testingSwitch;
    IBOutlet UILabel *_usernameLabel;
}

- (IBAction)testingSwitchChanged:(id)sender;
    
@end
