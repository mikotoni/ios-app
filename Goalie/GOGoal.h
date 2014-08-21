//
//  Goal.h
//  Goalie
//
//  Created by Stefan Kroon on 19-04-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <CouchCocoa/CouchCocoa.h>

@class GOTask, TimeWindow, AbstractTimeWindow;

@interface GOGoal : CouchModel {
    //float _completionRate;
    //bool _validCompletionRate;
    //NSDate *_lastActivityDate;
    //bool _validLastActivityDate;
    NSSet *_tasks;
}

//+ (GOGoal *)goalInManagedObjectContext:(NSManagedObjectContext *)context;

@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSString * explanation;
@property (nonatomic, retain) NSString * headline;
@property (nonatomic, readonly) NSSet *tasks;
//@property (nonatomic, readonly) float completionRate;
//@property (nonatomic, readonly) NSDate *lastActivityDate;
@property (nonatomic, retain) NSString *goalType;
@property (nonatomic, retain) NSString *abstractTimeWindowString;

@end

@interface GOGoal (CoreDataGeneratedAccessors)

- (void)addTasksObject:(GOTask *)value;
//- (void)removeTasksObject:(GOTask *)value;
//- (void)addTasks:(NSSet *)values;
//- (void)removeTasks:(NSSet *)values;
- (void)calculateCompletionRate;
- (void)calculateLastActivityDate;
- (AbstractTimeWindow *)abstractTimeWindow;

@end
