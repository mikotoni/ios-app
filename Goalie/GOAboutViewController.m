//
//  GOAboutViewController.m
//  Goalie
//
//  Created by Reza on 9/25/14.
//  Copyright (c) 2014 Stefan Kroon. All rights reserved.
//

#import "GOAboutViewController.h"
#import "GOMainApp.h"
#import "GOTranslation.h"

static inline NSRegularExpression * NameRegularExpression() {
    static NSRegularExpression *_nameRegularExpression = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _nameRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"^\\w+" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _nameRegularExpression;
}

static inline NSRegularExpression * ParenthesisRegularExpression() {
    static NSRegularExpression *_parenthesisRegularExpression = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _parenthesisRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"\\([^\\(\\)]+\\)" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _parenthesisRegularExpression;
}
@interface GOAboutViewController ()

@end

@implementation GOAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setAboutContentFont];
    [self setAboutContentText];
    // Do any additional setup after loading the view.
}
- (void)setAboutContentFont{
    [whatQuestionLabel setFont:[UIFont fontWithName:@"ProximaNova-Bold" size:14]];
    [whatAnswerLabel setFont:[UIFont fontWithName:@"ProximaNova-Regular" size:14]];
    [whoQuestionLabel setFont:[UIFont fontWithName:@"ProximaNova-Bold" size:14]];
    [whatAnswerLabel setFont:[UIFont fontWithName:@"ProximaNova-Regular" size:14]];
    [howQuestionLabel setFont:[UIFont fontWithName:@"ProximaNova-Bold" size:14]];
    [howAnswerLabel setFont:[UIFont fontWithName:@"ProximaNova-Regular" size:14]];
    [addInfoTitleLabel setFont:[UIFont fontWithName:@"ProximaNova-Bold" size:14]];
    [addInfoDescLabel setFont:[UIFont fontWithName:@"ProximaNova-Regular" size:14]];
    [versionLabel setFont:[UIFont fontWithName:@"ProximaNova-Regular" size:12]];
}
- (void)setAboutContentText{
    whatQuestionLabel.text = [[[GOMainApp sharedMainApp] translation] translate:@"activity_about" string:@"q_what_does_goalie_do"];
    whatAnswerLabel.text = [[[GOMainApp sharedMainApp] translation] translate:@"activity_about" string:@"a_what_does_goalie_do"];
    whoQuestionLabel.text = [[[GOMainApp sharedMainApp] translation] translate:@"activity_about" string:@"q_for_whom"];
    whoAnswerLabel.text = [[[GOMainApp sharedMainApp] translation] translate:@"activity_about" string:@"a_for_whom"];
    howQuestionLabel.text = [[[GOMainApp sharedMainApp] translation] translate:@"activity_about" string:@"q_get_account"];
    howAnswerLabel.text = [[[GOMainApp sharedMainApp] translation] translate:@"activity_about" string:@"a_get_account"];
    addInfoTitleLabel.text = [[[GOMainApp sharedMainApp] translation] translate:@"activity_about" string:@"q_more_info"];
//    addInfoDescLabel.text = [[[GOMainApp sharedMainApp] translation] translate:@"activity_about" string:@"a_more_info"];
//    addInfoDescLabel.linkTapHandler = ^(KILinkType linkType, NSString *string, NSRange range) {
//        if (linkType == KILinkTypeURL)
//        {
//            // Open URLs
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"http://" stringByAppendingString:string]]];
//        }
//    };
    
    [addInfoDescLabel setText:[[[GOMainApp sharedMainApp] translation] translate:@"activity_about" string:@"a_more_info"] afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
       
        
        return mutableAttributedString;
    }];
    
    NSRange linkRange = [[[[GOMainApp sharedMainApp] translation] translate:@"activity_about" string:@"a_more_info"] rangeOfString:@"goalie.sense-os.nl"];
    NSURL *url = [NSURL URLWithString:@"http://goalie.sense-os.nl"];
    [addInfoDescLabel addLinkToURL:url withRange:linkRange];
    addInfoDescLabel.delegate = self;
    
    versionLabel.text = [NSString stringWithFormat:@"Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(__unused TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
