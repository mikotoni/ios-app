//
//  GOSwitchTask.m
//  Goalie
//
//  Created by Stefan Kroon on 01-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOSwitchTask.h"

// Model
#import "GOGenericModelClasses.h"

@implementation GOSwitchTask

@dynamic explanation;
//@dynamic switchState;

+ (Class)relatedActiveTaskClass {
    return [GOActiveSwitchTask class];
}

- (bool)countAsUncompleted {
    return NO;
}

@end


@implementation GOActiveSwitchTask {
    AbstractTimeWindow *_abstractVisibleWindow;
}

- (void)updateWithBrew:(GOTaskBrew *)brew setState:(bool)newState {
    [brew setValue:[NSNumber numberWithBool:newState] forKey:kGOSwitchState];
    [brew.activeGoal didUpdateBrew:brew];
}

- (AbstractTimeWindow *)abstractTaskWindow {
    if(!_abstractVisibleWindow) {
        _abstractVisibleWindow = [self abstractWeekTask];
    }
    return _abstractVisibleWindow;
}

- (NSString *)activeCellIdentifier {
    return @"ActiveSwitchCell";
}

@end