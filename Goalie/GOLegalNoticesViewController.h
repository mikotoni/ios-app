//
//  GOLegalNoticesViewController.h
//  Goalie
//
//  Created by Reza on 9/25/14.
//  Copyright (c) 2014 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
@interface GOLegalNoticesViewController : UIViewController<TTTAttributedLabelDelegate>{
    IBOutlet UILabel *disclaimerTitleLabel;
    IBOutlet TTTAttributedLabel *disclaimerDescLabel;
    IBOutlet UILabel *openSourceTitleLabel;
    IBOutlet UILabel *openSourceDescLabel;
}

@end
