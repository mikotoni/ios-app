//
//  GOTaskCell.m
//  Goalie
//
//  Created by Stefan Kroon on 5/16/13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOTaskCell.h"

// Model
#import "GOGenericModelClasses.h"

// UI
#import "GONewGoalTasksTableViewController.h"

// Services
#import "GOMainApp.h"

@implementation GOTaskCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellForTask:(GOTask *)task brew:(GOTaskBrew *)brew tableViewController:(GONewGoalTasksTableViewController *)tvc {
    // Determine if selection is allowed
    bool allowSelection = YES;
    if([[task class] needsBrewForDisplaying]) {
        if(brew)
            allowSelection = YES;
        else
            allowSelection = NO;
    }
    if(!allowSelection) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [[self taskNameLabel] setTextColor:[UIColor grayColor]];
    }
    
    
    // Show, hide or empty checkbox
    if(brew) {
        if([brew hasPastCompletionDate]) {
            [[self checkboxImageView] setImage:tvc.greenCheckImage];
            [[self checkboxImageView] setHidden:NO];
        }
        else {
            [[self checkboxImageView] setImage:tvc.emptyCheckboxImage];
            [[self checkboxImageView] setHidden:NO];
        }
    }
    else
        [[self checkboxImageView] setHidden:YES];
    
    // Set the name
    [[self taskNameLabel] setText:[task name]];
    
    // Show the blue indicator
    [self setEditingAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
}


@end
