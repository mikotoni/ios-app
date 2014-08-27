//
//  MoodTask.h
//  Goalie
//
//  Created by Stefan Kroon on 29-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOTask.h"
#import "GOActiveTask.h"

static NSString * const kGONextRandomCheck = @"nextRandomCheck";

@interface GOMoodTask : GOTask

@property (nonatomic, retain) NSString *explanation;
@property (nonatomic, retain) NSArray *abstractNotificationWindows;
@property (nonatomic, retain) NSArray *abstractVisibleWindows;


//@property (nonatomic, retain) NSNumber * pleasure;
//@property (nonatomic, retain) NSNumber * arousal;
//@property (nonatomic, retain) NSNumber * dominance;
//@property (nonatomic, retain) NSDate *nextRandomCheck;

@end

@interface GOActiveMoodTask : GOActiveTask

- (void)updateBrew:(GOTaskBrew *)brew pleasure:(NSNumber *)pleasure arousal:(NSNumber *)arousal dominance:(NSNumber *)dominance;

@end