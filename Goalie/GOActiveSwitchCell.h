//
//  GOActiveSwitchCell.h
//  Goalie
//
//  Created by Stefan Kroon on 29-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractActiveTaskCell.h"

@interface GOActiveSwitchCell : GOAbstractActiveTaskCell

@property IBOutlet UISwitch *theSwitch;

- (IBAction)switched:(id)sender;

@end
