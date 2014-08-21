//
//  GOActiveGoal.m
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOGenericModelClasses.h"
#import "GOMainApp.h"
#import "TimeWindow.h"
#import "GOGoalieServices.h"
#import "GOSensePlatform.h"

@implementation GOActiveGoal

@dynamic type, goal, progress_sensor, nextTriggerTimeIntervals;
@dynamic beginDate, endDate, progress;

- (NSString *)iconImageName {
    NSDictionary *goalIconImages = nil;
    if(!goalIconImages) {
        goalIconImages =  @{@"regular_meals":@"food.png",
                            @"physical_activity":@"activity.png",
                            @"regular_sleep":@"sleep.png",
                            @"emotion_awareness":@"mood.png",
                            @"agoraphobia":@"location.png"};
    }
    NSString *iconImageName = [goalIconImages objectForKey:self.type];
    if(!iconImageName)
        iconImageName = @"image_placeholder.png";
    return iconImageName;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"%s Unknown key is: %@", __PRETTY_FUNCTION__, key);
}

- (id)valueForUndefinedKey:(NSString *)key {
    NSLog(@"%s Unknwon key is: %@", __PRETTY_FUNCTION__, key);
    return @"*** Unknown value ***";
}

- (GOActiveTrigger *)getNextActiveTriggerAfter:(NSDate *)afterDate {
    NSSet *tasks = [[self goal] tasks];
    NSMutableArray *allTriggers = [[NSMutableArray alloc] init];
    //GOActiveTrigger * __block earliestTrigger = nil;
    //NSDate * __block earliestTriggerDate = nil;
    
    [tasks enumerateObjectsUsingBlock:^(GOTask *task, BOOL *stop) {
        NSArray *brews = [self getStoredBrewsForTask:task];
        [brews enumerateObjectsUsingBlock:^(GOTaskBrew *brew, NSUInteger idx, BOOL *stop) {
            NSArray *moreTriggers = [task getTriggersForBrew:brew];
            [allTriggers addObjectsFromArray:moreTriggers];
        }];
    }];
    
    [allTriggers sortUsingComparator:^NSComparisonResult(GOActiveTrigger *obj1, GOActiveTrigger *obj2) {
        return [[obj1 pointInTime] compare:[obj2 pointInTime]];
    }];
    
    GOActiveTrigger * __block earliestTrigger = nil;
    [allTriggers enumerateObjectsUsingBlock:^(GOActiveTrigger *obj, NSUInteger idx, BOOL *stop) {
        if([[obj pointInTime] compare:afterDate] == NSOrderedDescending)
            earliestTrigger = obj;
        *stop = YES;
    }];
    
    return earliestTrigger;
}

- (TimeWindow *)timeWindow {
    return [[TimeWindow alloc] initWithBeginDate:self.beginDate endDate:self.endDate];
}

- (void)setTimeWindow:(TimeWindow *)timeWindow {
    self.beginDate = timeWindow.beginDate;
    self.endDate = timeWindow.endDate;
}

- (NSDate *)deadline {
    return self.timeWindow.endDate;
}

- (void)configureActiveTask:(GOActiveTask *)activeTask {
    AbstractTimeWindow *abstractTimeWindow = [[AbstractTimeWindow alloc] initWithBeginHour:12 minute:0 endHour:13 endMinute:0];
    [activeTask setAbstractTaskWindow:abstractTimeWindow];
    //NSDictionary *dict = @{@"text":@"*** no text available ***", @"abstractTimeWindow":abstractTimeWindow};
    return;
}

- (NSMutableDictionary *)storedBrews {
    if(!_storedBrews)
        _storedBrews = [[NSMutableDictionary alloc] init];
    return _storedBrews;
}

- (NSArray *)getBrewsForDate:(NSDate *)forDate {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    GOGoalieServices *goalieServices = [mainApp goalieServices];
    NSArray *brews = [goalieServices brewsByActiveGoal:self forDate:forDate];
    return brews;
}

- (CouchQuery *)getStoredBrewQueryForTask:(GOTask *)task {
    //NSString *documentID = [[task document] documentID];
    CouchQuery *query = nil;//[_storedBrewQueries valueForKey:documentID];
    if(!query) {
        GOGoalieServices *goalieServices = [[GOMainApp sharedMainApp] goalieServices];
        query = [goalieServices queryForBrewsByActiveGoal:self task:task];
        //[_storedBrewQueries setObject:query forKey:documentID];
    }
    return query;
}

- (NSUInteger)nofUncompletedTasksForDate:(NSDate *)forDate {
    GOGoalieServices *goalieServices = [[GOMainApp sharedMainApp] goalieServices];
    NSArray *brews = [goalieServices uncompletedBrewsByActiveGoalQuery:self forDate:forDate];
    
    NSUInteger __block nofUncompletedTasks = 0;
    [brews enumerateObjectsUsingBlock:^(GOTaskBrew *brew, NSUInteger idx, BOOL *stop) {
        GOTask *task = [brew task];
        if([task countAsUncompleted])
            nofUncompletedTasks++;
        
    }];
    return nofUncompletedTasks;
}

- (void)saveEarnedPointsToSensePlatform {
    GOSensePlatform *sensePlatform = [[GOMainApp sharedMainApp] sensePlatform];
    NSString *progressSensorName = [self progressSensorName];
    [sensePlatform updateActiveGoalProgress:self.earnedPoints sensorName:progressSensorName];
}

- (void)updateEarnedPointsByQuery:(CouchQuery *)query {
    CouchQueryEnumerator *enumerator = [query rows];
    if(enumerator) {
        CouchQueryRow *row = [enumerator nextRow];
        if(row) {
            self.earnedPoints = [row value];
            NSLog(@"%s row-count:%d earnedPoints:%d", __PRETTY_FUNCTION__, [enumerator count], [_earnedPoints integerValue]);
            float earnedPoints = [self.earnedPoints floatValue];
            if(earnedPoints > 100)
                earnedPoints = 100;
            self.completionRate = [NSNumber numberWithFloat:(earnedPoints / 100.0)];
            if(self.firstEarnedPointsValue)
                self.firstEarnedPointsValue = NO;
            else {
                [self saveEarnedPointsToSensePlatform];
            }
        }
        else
            NSLog(@"%s row-count:%d", __PRETTY_FUNCTION__, [enumerator count]);
    }
    else
        NSLog(@"%s Enumerator failed.", __PRETTY_FUNCTION__);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(object == _earnedPointsLiveQuery) {
        [self updateEarnedPointsByQuery:_earnedPointsLiveQuery];
    }
    else if([keyPath isEqualToString:@"isDeleted"]) {
        if([[self document] isDeleted]) {
            [self deleteAllBrews];
        }
    }
}

- (NSNumber *)earnedPoints {
    if(!_earnedPointsLiveQuery) {
        GOGoalieServices *goalieServices = [[GOMainApp sharedMainApp] goalieServices];
        _earnedPointsLiveQuery = [goalieServices liveQueryForEarnedPointsByActiveGoal:self];
        [_earnedPointsLiveQuery start];
        [_earnedPointsLiveQuery addObserver:self forKeyPath:@"rows" options:0 context:NULL];
        self.firstEarnedPointsValue = YES;
    }
    return _earnedPoints;
}

- (NSNumber *)completionRate {
    [self earnedPoints];
    return _completionRate;
}

- (float)completionFloat {
    NSNumber *completionRate = [self completionRate];
    float completionFloat = [completionRate floatValue];
    return completionFloat;
}

- (NSUInteger)completionInteger {
    NSUInteger completionInteger = [self completionFloat] * 100;
    return completionInteger;
}

- (NSString *)scoreString {
    return [NSString stringWithFormat:@"%d/100", [self completionInteger]];
}

- (NSArray *)getStoredBrewsForTask:(GOTask *)task {
    NSLog(@"[GOActiveGoal getStoredBrewsForTask:\"%@\"]", [task name]);
    NSString *taskDocId = [[task document] documentID];
    NSMutableArray *brews = [[self storedBrews] valueForKey:taskDocId];
    if(!brews) {
        brews = [[NSMutableArray alloc] init];
        
        CouchQuery *query = [self getStoredBrewQueryForTask:task];
        if(query) {
            CouchQueryEnumerator *enumerator = [query rows];
            if(enumerator) {
                CouchQueryRow *row;
                while((row = [enumerator nextRow])) {
                    CouchDocument *document = [row document];
                    if(document) {
                        CouchModel *modelObject = [[CouchModelFactory sharedInstance] modelForDocument:document];
                        if(modelObject) {
                            [brews addObject:modelObject];
                        }
                    }
                }
            }
            else
                NSLog(@"WARNING: %s: Enumerator is nil", __PRETTY_FUNCTION__);
        }
        [_storedBrews setObject:brews forKey:taskDocId];
    }
    
    return brews;
}

- (void)updateActiveGoalFromDictionary:(NSDictionary *)activeGoalDict {
    // Copy all settings
    [activeGoalDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

- (void) dirtStoredBrewsForTask:(GOTask *)task {
    NSString *taskDocId = [[task document] documentID];
    [_storedBrews removeObjectForKey:taskDocId];
}

- (NSArray *)getBrewsForTask:(GOTask *)task {
    return [task getBrewsForActiveGoal:self];
}

- (GOTaskBrew *)getBrewForTask:(GOTask *)task forDate:(NSDate *)forDate {
    GOTaskBrew * __block brew = nil;
    NSArray *brews = [self getBrewsForTask:task];
    [brews enumerateObjectsUsingBlock:^(GOTaskBrew *obj, NSUInteger idx, BOOL *stop) {
        if([[obj timeWindow] isDateInWindow:forDate]) {
            brew = obj;
            *stop = YES;
        }
    }];
    return brew;
}

- (GOTaskBrew *)storedBrewForTask:(GOTask *)task forOccurrence:(NSUInteger)occurrence {
    NSString *taskDocumentID = [[task document] documentID];
    NSArray *storedTasksForTask = [_storedBrews objectForKey:taskDocumentID];
    if(!storedTasksForTask) {
        storedTasksForTask = [self getStoredBrewsForTask:task];
        if(!_storedBrews)
            _storedBrews = [[NSMutableDictionary alloc] init];
        [_storedBrews setObject:storedTasksForTask forKey:taskDocumentID];
    }
    if([storedTasksForTask count] <= occurrence)
        return nil;
    GOTaskBrew *brew = [storedTasksForTask objectAtIndex:occurrence];
    return brew;
}

- (GOTaskBrew *)testAndDeleteStoredBrew:(GOTaskBrew *)storedTask forDate:(NSDate *)forDate {
    if([[storedTask endDate] compare:forDate] == NSOrderedAscending) {
        return storedTask;
    }
    else {
        [storedTask deleteDocument];
        return nil;
    }
}

- (void)deleteAllBrews {
        NSArray *brews = [[[GOMainApp sharedMainApp] goalieServices] brewsByActiveGoal:self forDate:nil];
        [brews enumerateObjectsUsingBlock:^(GOTaskBrew *brew, NSUInteger idx, BOOL *stop) {
            [[brew deleteDocument] start];
        }];
}

- (void)didDeleteDocument:(CouchDocument *)document {
    [self deleteAllBrews];
}


- (void)dealloc {
    NSLog(@"%s self:%p document:%p", __PRETTY_FUNCTION__, self, [self document]);
    if(_earnedPointsLiveQuery)
        [_earnedPointsLiveQuery removeObserver:self forKeyPath:@"rows"];
}

- (void)didUpdateBrew:(GOTaskBrew *)brew {
    return;
}

- (NSString *)explanation {
    return nil;
}

@end
