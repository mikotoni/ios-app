//
//  GOShootPhotoVC.h
//  Goalie
//
//  Created by Stefan Kroon on 28-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAbstractTaskVC.h"

@interface GOShootPhotoTaskVC : GOAbstractTaskVC <GOTaskVCProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    IBOutlet UIImageView *photoPreviewView;
    IBOutlet UIButton *takePhotoButton;
    IBOutlet UILabel *noCameraAvailableLabel;
    IBOutlet UITextField *kindOfPhotoTextField;
    IBOutlet UILabel *kindOfPhotoLabel;
    UIImage *acquiredPhoto;
}

- (IBAction)takePhotoButtonPressed:(id)sender;
- (IBAction)cancel:(id)sender;
    
//@property GOShootPhotoTask *task;

@end
