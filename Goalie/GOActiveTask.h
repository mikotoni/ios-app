//
//  GOActiveTask.h
//  Goalie
//
//  Created by Stefan Kroon on 13-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOActiveGoal, GOTask, AbstractTimeWindow, GOTaskBrew;

@interface GOActiveTask : NSObject {
    GOTask *_task;
    GOActiveGoal *_activeGoal;
    AbstractTimeWindow *_abstractTaskWindow;
}

@property (nonatomic, retain) GOTask *task;
@property (nonatomic, retain) GOActiveGoal *activeGoal;
@property (nonatomic, retain) AbstractTimeWindow *abstractTaskWindow;

- (id)initWithBrew:(GOTaskBrew *)brew;
- (id)initWithTask:(GOTask *)task activeGoal:(GOActiveGoal *)activeGoal;
- (void)fireWithBrew:(GOTaskBrew *)brew;

- (NSString *)activeCellIdentifier;
- (NSString *)titleForBrew:(GOTaskBrew *)brew;
- (AbstractTimeWindow *)abstractWeekTask;
    
@end
