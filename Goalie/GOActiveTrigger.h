//
//  GOActiveTrigger.h
//  Goalie
//
//  Created by Stefan Kroon on 04-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOTaskBrew;

@interface GOActiveTrigger : NSObject

@property (nonatomic, retain) NSDate *pointInTime;
@property (nonatomic, retain) NSString *notificationMessage;
@property (nonatomic, retain) GOTaskBrew *brew;
@property bool needsFire;

- (id)initWithDate:(NSDate *)triggerDate notificationMessage:(NSString *)message brew:(GOTaskBrew *)brew;
- (id)initWithDate:(NSDate *)triggerDate needsFire:(BOOL)needsFire brew:(GOTaskBrew *)brew;
- (void)firedByTimer:(NSTimer *)timer;

@end

@interface GOAbstractTrigger : NSObject

- (GOActiveTrigger *)concreteTriggerForBrew:(GOTaskBrew *)brew;
    
@property (nonatomic, retain) NSString *notificationMessage;
@property (nonatomic, retain) NSDateComponents *abstractMoment;

@end