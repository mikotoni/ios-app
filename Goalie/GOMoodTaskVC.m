//
//  GOEmotionTaskViewController.m
//  Goalie
//
//  Created by Stefan Kroon on 28-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOMoodTaskVC.h"

// Model
#import "GOGenericModelClasses.h"
#import "GOMoodTask.h"

// Services
#import "GOMainApp.h"
#import "GOTranslation.h"

@interface GOMoodTaskViewController ()

@end

@implementation GOMoodTaskViewController

//@synthesize task;

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
	// Do any additional setup after loading the view.
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:@"index" ofType:@"html" inDirectory:@"affectbutton"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [webView setDelegate:self];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (IBAction)cancel:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.editMode) {
        [explanationView setEditable:YES];
    }
    else {
        [explanationView setEditable:NO];
        //GOMoodTask *moodTask = [self.brew getTaskWithClass:[GOMoodTask class]];
        GOTranslation *translation = [[GOMainApp sharedMainApp] translation];
        [explanationView setText:[translation translate:@"task_emotion" string:@"task_emotion_explanation"]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.editMode) {
        [explanationView becomeFirstResponder];
        [explanationView setSelectedRange:NSMakeRange(0, 1000)];
    }
    else {
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Webview error: %@", [error description]);
}

- (void)completeTask {
    NSString *affection = [webView stringByEvaluatingJavaScriptFromString:@"getAffect()"];
    NSLog(@"Affection:%@", affection);
    NSData *affectionData = [affection dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError = nil;
    NSDictionary *affectionJson = [NSJSONSerialization JSONObjectWithData:affectionData
                                                                  options:0
                                                                    error:&jsonError];
    if(jsonError) {
        NSLog(@"Json parse error");
        return;
    }
    
    GOTaskBrew *brew = self.brew;
    GOActiveMoodTask *activeMoodTask = (id)[brew activeTask];
     NSNumber *pleasure = [affectionJson valueForKey:@"pleasure"];
     NSNumber *arousal = [affectionJson valueForKey:@"arousal"];
     NSNumber *dominance = [affectionJson valueForKey:@"dominance"];
    
    [activeMoodTask updateBrew:brew pleasure:pleasure arousal:arousal dominance:dominance];
    
    [brew save];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
