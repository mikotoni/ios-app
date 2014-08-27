//
//  GOActiveShootPhotoCell.h
//  Goalie
//
//  Created by Stefan Kroon on 29-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractActiveTaskCell.h"

@interface GOActiveShootPhotoCell : GOAbstractActiveTaskCell

@property IBOutlet UIButton *nextButton;
@property IBOutlet UIButton *previousButton;
@property IBOutlet UIImageView *photoImageView;

- (IBAction)nextPhoto:(id)sender;
- (IBAction)previousPhoto:(id)sender;

@end
