//
//  GOGoalExplanationVC.m
//  Goalie
//
//  Created by Stefan Kroon on 25-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOGoalExplanationVC.h"

#import "GOGenericModelClasses.h"

@interface GOGoalExplanationVC ()

@end

@implementation GOGoalExplanationVC {
    IBOutlet UITextView *textView;
}

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    GOActiveGoal *activeGoal = self.activeGoal;
    NSString *explanation = [activeGoal explanation];
    if(!explanation)
        explanation = [[activeGoal goal] explanation];
    textView.text = explanation;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
