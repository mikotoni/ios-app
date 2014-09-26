//
//  GOAboutViewController.h
//  Goalie
//
//  Created by Reza on 9/25/14.
//  Copyright (c) 2014 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KILabel.h"
#import "TTTAttributedLabel.h"

@interface GOAboutViewController : UIViewController<TTTAttributedLabelDelegate>{
    IBOutlet UILabel *whatQuestionLabel;
    IBOutlet UILabel *whatAnswerLabel;
    IBOutlet UILabel *whoQuestionLabel;
    IBOutlet UILabel *whoAnswerLabel;
    IBOutlet UILabel *howQuestionLabel;
    IBOutlet UILabel *howAnswerLabel;
    IBOutlet UILabel *addInfoTitleLabel;
    IBOutlet TTTAttributedLabel *addInfoDescLabel;
    IBOutlet UILabel *versionLabel;
}

@end
