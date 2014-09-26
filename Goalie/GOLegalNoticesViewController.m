//
//  GOLegalNoticesViewController.m
//  Goalie
//
//  Created by Reza on 9/25/14.
//  Copyright (c) 2014 Stefan Kroon. All rights reserved.
//

#import "GOLegalNoticesViewController.h"
#import "GOMainApp.h"
#import "GOTranslation.h"

@interface GOLegalNoticesViewController ()

@end

@implementation GOLegalNoticesViewController

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
    [self setLegalNoticesContentFont];
    [self setLegalNoticesContentText];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setLegalNoticesContentFont{
    [disclaimerTitleLabel setFont:[UIFont fontWithName:@"ProximaNova-Bold" size:14]];
    [disclaimerDescLabel setFont:[UIFont fontWithName:@"ProximaNova-Regular" size:14]];
    [openSourceTitleLabel setFont:[UIFont fontWithName:@"ProximaNova-Bold" size:14]];
    [openSourceDescLabel setFont:[UIFont fontWithName:@"ProximaNova-Regular" size:14]];
}
- (void)setLegalNoticesContentText{
    disclaimerTitleLabel.text = [[[GOMainApp sharedMainApp] translation] translate:@"activity_legal_notices" string:@"title_disclaimer"];
    
    [disclaimerDescLabel setText:[[[GOMainApp sharedMainApp] translation] translate:@"activity_legal_notices" string:@"deskripsi_disclaimer"] afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        
        return mutableAttributedString;
    }];
    
    NSRange linkRange = [[[[GOMainApp sharedMainApp] translation] translate:@"activity_legal_notices" string:@"deskripsi_disclaimer"] rangeOfString:@"disclaimer"];
    NSURL *url = [NSURL URLWithString:@"http://www.psyq.nl/Footer/Disclaimer"];
    [disclaimerDescLabel addLinkToURL:url withRange:linkRange];
    disclaimerDescLabel.delegate = self;
    
    openSourceTitleLabel.text = [[[GOMainApp sharedMainApp] translation] translate:@"activity_legal_notices" string:@"title_open_source"];
    openSourceDescLabel.text = [[[GOMainApp sharedMainApp] translation] translate:@"activity_legal_notices" string:@"deskription_open_source"];
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
