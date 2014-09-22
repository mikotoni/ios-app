//
//  GOGoalieServices.m
//  Goalie
//
//  Created by Stefan Kroon on 20-06-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOGoalieServices.h"

// UI
#import "GOAbstractTaskVC.h"

// Model
#import "GOGenericModelClasses.h"
#import "GOSleepState.h"
#import "GOSleepTask.h"
#import "GOMotionTask.h"
#import "TimeWindow.h"
#import <TouchDB/TouchDB.h>

// Services
#import "GOMainApp.h"
#import "GOKeychain.h"
#import "GOLocationManager.h"
#import "GOTestFlight.h"

@implementation GOGoalieServices {
    GOCouchCocoa *_couchCocoa;
    GOTaskBrew *_eventBrew;
    bool _useLocalCouchDatabase;
    
    // Last active / motion variables
    NSDate *lastBrewsLookup;
    NSArray *motionBrews;
    
    bool useDeadmanControl;
    NSDate *_lastDeadmanPush;
    NSDate *_deadmanFireDate;
    UILocalNotification *_deadmanNotification;
}

#pragma mark Configuration

+ (NSURLCredential *)couchdbServerAdmin {
    static NSURLCredential *credential = nil;
    if(!credential)
        credential = [NSURLCredential credentialWithUser:@"admin"
                                                password:@"aB1QixTj30f48"
                                             persistence:NSURLCredentialPersistenceNone];
    return credential;
}

+ (NSURLCredential *)goalieAdmin {
    static NSURLCredential *credential = nil;
    if(!credential)
        credential = [NSURLCredential credentialWithUser:@"GoalieAdmin"
                                                password:@"fOagbOagb"
                                             persistence:NSURLCredentialPersistenceNone];
    return credential;
}


#pragma mark Initialization

- (id)initUseLocalCouchDatabase:(bool)useLocal {
    self = [super init];
    if(self) {
        // Configure CouchCocoa
        GOMainApp *mainApp = [GOMainApp sharedMainApp];
        mainApp.loadingText = @"Loading CouchCocoa";
        _couchCocoa = [[GOCouchCocoa alloc] init];
        
        _useLocalCouchDatabase = useLocal;
        _nofUncompletedTasksPerActiveGoal = [[NSMutableDictionary alloc] initWithCapacity:8];
    }
    return self;
}

- (bool)addUser:(NSString *)username password:(NSString *)password {
    NSLog(@"%s addUser:%@ password:%@]", __PRETTY_FUNCTION__, username, @"***");
    bool success = NO;
    
    CouchDatabase *userDatabase = [GOCouchCocoa openCouchServerWithCredential:[GOGoalieServices couchdbServerAdmin] database:@"_users"];
    
    NSString *newUserDocumentID = [NSString stringWithFormat:@"org.couchdb.user:%@", username];
    CouchDocument *newUserDocument = [userDatabase documentWithID:newUserDocumentID];
    NSMutableDictionary *properties = [[newUserDocument properties] mutableCopy];
    [properties setValue:username forKey:@"name"];
    [properties setValue:password forKey:@"password"];
    [properties setValue:@[@"goalie_user"] forKey:@"roles"];
    [properties setValue:@"user" forKey:@"type"];
    RESTOperation *op = [newUserDocument putProperties:properties];
    success = [op wait];
    
    return success;
}

#pragma mark Login / logout

/*
- (void)tryAutoLoginWithHandler:(void (^)(bool autoSuccess, NSString *autoMessage))autoHandler {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    GOKeychain *keychain = [mainApp keychain];
    NSString *username = [keychain username];
    NSString *password = [keychain password];
    [self loginWithUsername:username password:password handler:^(bool success, NSString *message) {
        autoHandler(success, message);
    }];
}
*/

- (void)couchLoginWithUsername:(NSString *)rawUsername password:(NSString *)password handler:(void (^)(bool success))handler {
    NSLog(@"%s username:%@ password:%@", __PRETTY_FUNCTION__, rawUsername, @"***");
    NSURLCredential *userCredential = [NSURLCredential credentialWithUser:[NSString stringWithFormat:@"goalie_%@", rawUsername]
                                                                 password:password
                                                              persistence:NSURLCredentialPersistenceNone];
    NSString *databaseName = @"goalie";
    
    [_couchCocoa openCouchServerWithCredential:userCredential
                                      database:databaseName
                                       handler:^(bool couchCocoaSuccess, CouchDatabase *database) {
        if(couchCocoaSuccess) {
            NSLog(@"%s Successfull login at couch", __PRETTY_FUNCTION__);
            _couchCocoa.database = database;
            CouchDatabase *databaseForAdmin =
                [GOCouchCocoa openCouchServerWithCredential:[GOGoalieServices goalieAdmin]
                                                   database:@"goalie"];
            _couchCocoa.design = [_couchCocoa createCouchDesignForDatabase:databaseForAdmin];
            handler(YES);
        }
        else {
            NSLog(@"%s Couch user does not exist yet. Create the user", __PRETTY_FUNCTION__);
            bool addUserSuccess = [self addUser:[userCredential user] password:[userCredential password]];
            if(addUserSuccess) {
                NSLog(@"%s Successfully created the couch user.", __PRETTY_FUNCTION__);
                [_couchCocoa openCouchServerWithCredential:userCredential
                                                  database:databaseName
                                                   handler:^(bool couchCocoaSuccess2, CouchDatabase *database) {
                    if(couchCocoaSuccess2) {
                        _couchCocoa.database = database;
                        CouchDatabase *databaseForAdmin =
                            [GOCouchCocoa openCouchServerWithCredential:[GOGoalieServices goalieAdmin]
                                                               database:@"goalie"];
                        _couchCocoa.design = [_couchCocoa createCouchDesignForDatabase:databaseForAdmin];
                        handler(YES);
                    }
                    else {
                        NSLog(@"%s But still can't login", __PRETTY_FUNCTION__);
                        handler(NO);
                    }
                }];
            }
            else {
                NSLog(@"%s Failed to create the new couch user", __PRETTY_FUNCTION__);
                handler(NO);
            }
        }
    }];
}


- (void)loginWithUsername:(NSString *)username password:(NSString *)password handler:(void (^)(bool success, NSString *message))handler {
    NSLog(@"%s username:%@ passowrd:%@", __PRETTY_FUNCTION__, username, @"***");
        if(!_useLocalCouchDatabase) {
            [self couchLoginWithUsername:username password:password handler:^(bool loginGoalieSuccess) {
                if(loginGoalieSuccess) {
                    NSLog(@"%s Successfull login", __PRETTY_FUNCTION__);
                    [[GOMainApp sharedMainApp] restart];
                    handler(YES, nil);
                }
                else {
                    NSLog(@"%s Failed to login at Goalie Services with remote database", __PRETTY_FUNCTION__);
                    handler(NO, @"Failed to login at Goalie Services");
                }
            }];
        }
        else {
            _couchCocoa.database = [_couchCocoa openTouchDatabaseForUser:username];
            _couchCocoa.design = [_couchCocoa createCouchViewsForLocalDatabase:_couchCocoa.database];
            if(_couchCocoa.database && _couchCocoa.design) {
                [[GOMainApp sharedMainApp] restart];
                handler(YES, nil);
            }
            else {
                NSLog(@"%s Failed to login at Goalie Services with local database", __PRETTY_FUNCTION__);
                handler(NO, @"Failed to start local couch database");
            }
        }
}

- (UILocalNotification *)deadmanNotification {
    if(!useDeadmanControl)
        return nil;
    if(!_deadmanNotification) {
        _deadmanNotification = [[UILocalNotification alloc] init];
        _deadmanFireDate = [[NSDate date] dateByAddingTimeInterval:2 * 60.0];
        [_deadmanNotification setFireDate:_deadmanFireDate];
        [_deadmanNotification setAlertBody:@"Het meten van activiteit is gestopt. Open Goalie om het meten opnieuw te starten"];
        [_deadmanNotification setUserInfo:@{@"type":@"deadman"}];
    }
    
    return _deadmanNotification;
}

- (void)scheduleDeadmanNotification {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    [sharedApplication scheduleLocalNotification:[self deadmanNotification]];
}

- (void)cancelDeadmanNotification {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    if(_deadmanNotification) {
        [sharedApplication cancelLocalNotification:_deadmanNotification];
        _deadmanNotification = nil;
        _deadmanFireDate = nil;
    }
}

- (void)pushDeadmanControl {
    if(!useDeadmanControl)
        return;
    _lastDeadmanPush = [NSDate date];
    if(!_deadmanFireDate || !_deadmanNotification) {
        [self scheduleDeadmanNotification];
    }
    else {
        NSDate *now = [NSDate date];
        if([_deadmanFireDate timeIntervalSinceDate:now] < 60.0) {
            [self cancelDeadmanNotification];
            [self scheduleDeadmanNotification];
        }
    }
}

- (void)startDeadmanControl {
    useDeadmanControl = YES;
    if(!_deadmanFireDate || !_deadmanNotification)
        [self scheduleDeadmanNotification];
}

- (void)stopDeadmanControl {
    useDeadmanControl = NO;
    [self cancelDeadmanNotification];
}

- (void)logout {
    [_couchCocoa logout];
    [UIApplication sharedApplication].scheduledLocalNotifications = @[];
    [self cancelAllCurrentTimers];
}


#pragma mark Abstract database layer

- (CouchDatabase *)database {
    return [_couchCocoa database];;
}

/*
- (void)putChanges:(NSArray *)propertiesToSave {
    [_couchCocoa putChanges:propertiesToSave];
}
 */

- (GOGoal *)goalForActiveGoal:(GOActiveGoal *)activeGoal {
    NSString *goalType = [activeGoal type];
    CouchQuery *query = [_couchCocoa queryViewNamed:@"GoalsByGoalType" keys:@[goalType]];
    [query setPrefetch:YES];
    
    CouchQueryEnumerator *enumerator = [query rows];
    CouchQueryRow *row = [enumerator nextRow];
    if(!row) {
        NSLog(@"Failed to find GOGoal with goalType: %@", goalType);
    }
    else {
        CouchDocument *document = [row document];
        if(document) {
            GOGoal *goal = [[CouchModelFactory sharedInstance] modelForDocument:document];
            return goal;
        }
    }
    return nil;
}

- (bool)processActiveGoal:(NSDictionary *)activeGoalDict {
    //gMYWarnRaisesException = TRUE;
    NSLog(@"activeGoalDict: %@", [activeGoalDict description]);
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    NSString *goalType = [activeGoalDict valueForKey:@"type"];
    NSDate *now = [mainApp nowDate];
    NSDateComponents *oneWeekBackComponents = [GOMainApp subtractOneWeek];
    NSDate *oneWeekBack = [[GOMainApp currentCalendar] dateByAddingComponents:oneWeekBackComponents toDate:now options:0];
    NSString *nowString = [RESTBody JSONObjectWithDate:now];
    NSString *oneWeekBackString = [RESTBody JSONObjectWithDate:oneWeekBack];
    CouchQuery *query = [_couchCocoa queryViewNamed:@"ActiveGoalsByBeginDate" startKey:oneWeekBackString endKey:nowString];
    [query setPrefetch:YES];
    
    
    GOActiveGoal *activeGoal = nil;
    CouchQueryEnumerator *enumerator = [query rows];
    CouchQueryRow *row;
    while((row = [enumerator nextRow])) {
        CouchDocument *document = [row document];
        if(document) {
            activeGoal = [[CouchModelFactory sharedInstance] modelForDocument:document];
            if([[activeGoal type] isEqualToString:goalType]) {
                [activeGoal updateActiveGoalFromDictionary:activeGoalDict];
                [activeGoal save];
                return false;
            }
        }
        activeGoal = nil;
    }
    
    Class klass = [[CouchModelFactory sharedInstance] classForDocumentType:goalType];
    if(!klass) {
        NSLog(@"Can't create GOActiveGoal for class/type: %@", goalType);
        return false;
    }
    
    // Build new active goal
    activeGoal = [[klass alloc]initWithNewDocumentInDatabase:_couchCocoa.database];
    
    // Update the active goal
    [activeGoal updateActiveGoalFromDictionary:activeGoalDict];
    
    // Link to the goal
    GOGoal *goal = [self goalForActiveGoal:activeGoal];
    [activeGoal setGoal:goal];
    
    // TimeWindow
    TimeWindow *timeWindow = [GOMainApp activeGoalTimeWindow];
    [activeGoal setTimeWindow:timeWindow];
    
    // Save
    [activeGoal save];
    [activeGoal saveEarnedPointsToSensePlatform];
    
    // Trigger to generate brews
    [goal.tasks enumerateObjectsUsingBlock:^(GOTask *task, BOOL *stop) {
        [activeGoal getBrewsForTask:task];
    }];
    
    return true;
}

- (void)dumpAllDocuments {
    CouchModelFactory *modelFactory = [CouchModelFactory sharedInstance];
    CouchQuery *query = [[_couchCocoa database] getAllDocuments];
    [query setPrefetch:YES];
    CouchQueryEnumerator *enumerator = [query rows];
    CouchQueryRow *row;
    
    while((row = [enumerator nextRow]) != nil) {
        CouchDocument *document = [row document];
        NSString *type = [document propertyForKey:@"type"];
        NSLog(@"_id:%@ type:%@", [document documentID], [document propertyForKey:@"type"]);
        if([type isEqualToString:@"TaskBrew"]) {
            GOTaskBrew *brew = [modelFactory modelForDocument:document];
            NSLog(@"  %@", [brew description]);
        }
    }
}

#pragma mark Query returning methods

- (CouchQuery *)queryForBrewsFromDate:(NSDate *)beginDate limit:(NSUInteger)limit {
    NSString *beginString = [RESTBody JSONObjectWithDate:beginDate];
    CouchQuery *query = [_couchCocoa queryViewNamed:@"BrewsByEndDate" startKey:beginString];
    [query setLimit:limit];
    [query setPrefetch:YES];
    return query;
}

- (CouchQuery *)queryForBrewsByActiveGoal:(GOActiveGoal *)activeGoal forDate:(NSDate *)forDate {
    NSString *activeGoalId = [[activeGoal document] documentID];
    NSArray *startKey;
    if(forDate) {
        NSString *forString = [RESTBody JSONObjectWithDate:forDate];
        startKey = @[activeGoalId, forString];
    }
    else
        startKey = @[activeGoalId];
    NSArray *endKey = @[activeGoalId, @{}];
    
    CouchQuery *query = [_couchCocoa queryViewNamed:@"BrewsByActiveGoalEndDate" startKey:startKey endKey:endKey];
    [query setPrefetch:YES];
    return query;
}

- (CouchQuery *)queryForTasksByGoalWithKeys:(NSArray *)keys {
    CouchQuery *query = [_couchCocoa queryViewNamed:@"TasksByGoal" keys:keys];
    [query setPrefetch:YES];
    return query;
}

- (CouchQuery *)queryForBrewsByActiveGoal:(GOActiveGoal *)activeGoal task:(GOTask *)task {
    NSString *activeGoalDocId = [[activeGoal document] documentID];
    NSString *taskDocId = [[task document] documentID];
    TimeWindow *activeGoalTimeWindow = [activeGoal timeWindow];
    NSString *activeGoalBeginDate = [RESTBody JSONObjectWithDate:[activeGoalTimeWindow beginDate]];
    NSString *activeGoalEndDate = [RESTBody JSONObjectWithDate:[activeGoalTimeWindow endDate]];
    CouchQuery *query = [_couchCocoa queryViewNamed:@"BrewsByActiveGoalTaskBeginDate"
                                          startKey:@[activeGoalDocId, taskDocId, activeGoalBeginDate]
                                            endKey:@[activeGoalDocId, taskDocId, activeGoalEndDate]];
    [query setPrefetch:YES];
    return query;
}


#pragma mark Live Query returning methods

- (CouchLiveQuery *)liveQueryForAllBrews {
    CouchQuery *query = [_couchCocoa queryViewNamed:@"BrewsByEndDate"];
    [query setPrefetch:YES];
    return [query asLiveQuery];
}

- (CouchLiveQuery *)liveQueryForBrewsByActiveGoal:(GOActiveGoal *)activeGoal task:(GOTask *)task {
    return [[self queryForBrewsByActiveGoal:activeGoal task:task] asLiveQuery];
}


- (CouchLiveQuery *)liveQueryForActiveGoalsBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate {
    NSString *beginString = [RESTBody JSONObjectWithDate:beginDate];
    NSString *endString = [RESTBody JSONObjectWithDate:endDate];
    
    CouchQuery *query = [_couchCocoa queryViewNamed:@"ActiveGoalsByBeginDate" startKey:beginString endKey:endString];
    [query setPrefetch:YES];
    
    return [query asLiveQuery];
}

- (CouchLiveQuery *)activeGoalsQuery {
    if(!_activeGoalsQuery) {
        GOMainApp *mainApp = [GOMainApp sharedMainApp];
        NSDate *now = [mainApp nowDate];
        NSCalendar *curCal = [GOMainApp currentCalendar];
        NSDateComponents *subtractOneWeek = [GOMainApp subtractOneWeek];
        NSDate *beginDate = [curCal dateByAddingComponents:subtractOneWeek toDate:now options:0];
        NSDate *endDate = now;
        
        _activeGoalsQuery = [self liveQueryForActiveGoalsBeginDate:beginDate endDate:endDate];
        
        [[_activeGoalsQuery start] onCompletion:^{
            NSDate *firstDate = nil;
            CouchQueryEnumerator *enumerator = [_activeGoalsQuery rows];
            CouchQueryRow *row;
            while((row = [enumerator nextRow])) {
                GOActiveGoal *activeGoal = [[CouchModelFactory sharedInstance] modelForDocument:[row document]];
                NSDate *activeGoalEnd = [activeGoal endDate];
                if(firstDate == nil || [activeGoalEnd compare:firstDate] == NSOrderedAscending) {
                    firstDate = activeGoalEnd;
                }
            }
            if(!firstDate)
                firstDate = [now dateByAddingTimeInterval:60*60*12]; // Defaults to 12h
            NSTimeInterval fireDelay = [firstDate timeIntervalSinceDate:now];
            [self performSelector:@selector(processActiveGoalEndDateEdge) withObject:self afterDelay:fireDelay];
        }];
    }
    return _activeGoalsQuery;
}

- (CouchLiveQuery *)liveQueryForTasksByGoalWithKeys:(NSArray *)keys {
    CouchQuery *query = [_couchCocoa queryViewNamed:@"TasksByGoal" keys:keys];
    [query setPrefetch:YES];
    return  [_couchCocoa asLiveQuery:query];
}

- (CouchLiveQuery *)liveQueryForEarnedPointsByActiveGoal:(GOActiveGoal *)activeGoal {
    CouchQuery *query = [_couchCocoa queryViewNamed:@"EarnedPointsByActiveGoalTaskBeginDate" startEndDocument:[activeGoal document]];
    [query setGroupLevel:1];
    [query setGroup:YES];
    return [_couchCocoa asLiveQuery:query];
}
- (CouchLiveQuery *)liveQueryForEarnedPointsByActiveGoal:(GOActiveGoal *)activeGoal forDate:(NSDate *)forDate {
    NSString *activeGoalId = [[activeGoal document] documentID];
    NSArray *startKey;
    if(forDate) {
        NSCalendar *curCal = [GOMainApp currentCalendar];
        NSString *forString = [RESTBody JSONObjectWithDate:[AbstractTimeWindow startDateForDate:forDate calendar:curCal aboveUnit:NSDayCalendarUnit]];
        startKey = @[activeGoalId, forString];
    }
    else
        startKey = @[activeGoalId];
    NSArray *endKey = @[activeGoalId, @{}];
    
    CouchQuery *query = [_couchCocoa queryViewNamed:@"EarnedPointsByActiveGoalTaskBeginDate" startKey:startKey endKey:endKey];
//    [query setGroupLevel:1];
//    [query setGroup:YES];
    [query setPrefetch:YES];
    return [_couchCocoa asLiveQuery:query];;
}
- (CouchLiveQuery *)liveQueryForEarnedPointsByActiveGoal:(GOActiveGoal *)activeGoal forWeekUntilDate:(NSDate *)forDate {
    NSString *activeGoalId = [[activeGoal document] documentID];
    NSArray *startKey;
    if(forDate) {
        NSString *forString = [RESTBody JSONObjectWithDate:[AbstractTimeWindow startDateForDate:forDate calendar:nil aboveUnit:nil]];
        startKey = @[activeGoalId, forString];
    }
    else
        startKey = @[activeGoalId];
    NSArray *endKey = @[activeGoalId, @{}];
    
    CouchQuery *query = [_couchCocoa queryViewNamed:@"BrewsByActiveGoalEndDate" startKey:startKey endKey:endKey];
    [query setGroupLevel:1];
    [query setGroup:YES];
    return [_couchCocoa asLiveQuery:query];;
}
#pragma mark Brew returning methods

- (GOTaskBrew *)brewById:(NSString *)brewDocId {
    CouchDocument *document = [_couchCocoa getDocumentById:brewDocId];
    GOTaskBrew *brew = [[CouchModelFactory sharedInstance] modelForDocument:document];
    return brew;
}

- (NSArray *)brewsFromQuery:(CouchQuery *)query filterBlock:(bool (^)(GOTaskBrew *brew))filterBlock {
    NSMutableArray *brews = nil;
    CouchQueryEnumerator *enumerator = [query rows];
    if(enumerator) {
        brews = [[NSMutableArray alloc] initWithCapacity:[enumerator count]];
        CouchQueryRow *row;
        CouchModelFactory *modelFactory = [CouchModelFactory sharedInstance];
        while((row = [enumerator nextRow]) != nil) {
            CouchDocument *doc = [row document];
            GOTaskBrew *brew = [modelFactory modelForDocument:doc];
            bool allowed = true;
            if(filterBlock)
                allowed =  filterBlock(brew);
            if(allowed)
                [brews addObject:brew];
        }
    }
    
    return brews;
}

- (NSArray *)brewsFromDate:(NSDate *)fromDate limit:(NSUInteger)limit {
    CouchQuery *query = [self queryForBrewsFromDate:fromDate limit:limit];
    return [self brewsFromQuery:query filterBlock:nil];
}

- (NSArray *)brewsByActiveGoal:(GOActiveGoal *)activeGoal forDate:(NSDate *)forDate {
    CouchQuery *query = [self queryForBrewsByActiveGoal:activeGoal forDate:forDate];
    [query setPrefetch:NO];
    return [self brewsFromQuery:query filterBlock:^bool(GOTaskBrew *brew) {
        return [[brew timeWindow] isDateInWindow:forDate];
    }];
}

- (NSArray *)uncompletedBrewsByActiveGoalQuery:(GOActiveGoal *)activeGoal forDate:(NSDate *)forDate {
    NSString *docId = [[activeGoal document] documentID];
    NSString *forDateString = [RESTBody JSONObjectWithDate:forDate];
    NSArray *startKey = @[docId, forDateString];
    NSArray *endKey = @[docId, @{}];
    CouchQuery *query = [_couchCocoa queryViewNamed:@"UncompletedBrewsByActiveGoalEndDate" startKey:startKey endKey:endKey];
    [query setPrefetch:YES];
    
    return [self brewsFromQuery:query filterBlock:^bool(GOTaskBrew *brew) {
        return [[brew timeWindow] isDateInWindow:forDate];
    }];
}

- (NSArray *)brewsForTask:(GOTask *)task beginDate:(NSDate *)beginDate endDate:(NSDate *)endDate {
    NSString *beginString = [RESTBody JSONObjectWithDate:beginDate];
    NSString *endString = [RESTBody JSONObjectWithDate:endDate];
    NSString *taskDocId = [[task document] documentID];
    NSArray *startKey = @[taskDocId, beginString];
    NSArray *endKey = @[taskDocId, endString];
    
    CouchQuery *query = [_couchCocoa queryViewNamed:@"BrewsByTaskEndDate" startKey:startKey endKey:endKey];
    [query setPrefetch:YES];
    
    return [self brewsFromQuery:query filterBlock:nil];
}

- (NSArray *)brewsForTask:(GOTask *)task forDate:(NSDate *)forDate {
    //NSMutableArray *brews = [[NSMutableArray alloc] initWithCapacity:4];
    NSString *beginString = [RESTBody JSONObjectWithDate:forDate];
    NSString *taskDocId = [[task document] documentID];
    
    CouchQuery *query = [_couchCocoa queryViewNamed:@"BrewsByTaskEndDate" startKey:@[taskDocId, beginString] endKey:@[taskDocId, @{}]];
    [query setPrefetch:YES];
    
    return [self brewsFromQuery:query filterBlock:^bool(GOTaskBrew *brew) {
        return [[brew timeWindow] isDateInWindow:forDate];
    }];
    
    /*
    CouchQueryEnumerator *enumerator = [query rows];
    CouchQueryRow *row;
    CouchModelFactory *modelFactory = [CouchModelFactory sharedInstance];
    while((row = [enumerator nextRow]) != nil) {
        NSString *beginDateString = [row value];
        NSDate *beginDate = [RESTBody dateWithJSONObject:beginDateString];
        if([beginDate compare:forDate] == NSOrderedAscending) {
            CouchDocument *doc = [row document];
            GOTaskBrew *brew = [modelFactory modelForDocument:doc];
            [brews addObject:brew];
        }
    }
    
    return brews;
     */
}

#pragma mark Task array returning methods

- (NSArray *)tasksByType:(NSString *)typeName {
    id keys = nil;
    if(typeName)
        keys = @[typeName];
    CouchQuery *query;
    if(keys)
        query = [_couchCocoa queryViewNamed:@"TasksByType" keys:keys];
    else
        query = [_couchCocoa queryViewNamed:@"TasksByType"];
    CouchQueryEnumerator *enumerator = [query rows];
    CouchQueryRow *row;
    NSMutableArray *tasks = [[NSMutableArray alloc] initWithCapacity:8];
    while((row = [enumerator nextRow]) != nil) {
        CouchDocument *doc = [row document];
        GOTask *task = [[CouchModelFactory sharedInstance] modelForDocument:doc];
        [tasks addObject:task];
    }
    return tasks;
}


- (NSArray *)motionTasks {
    static NSArray *motionTasks = nil;
    if(!motionTasks) {
        motionTasks = [self tasksByType:@"MotionTask"];
    }
    return motionTasks;
}

- (NSArray *)sleepTasks {
    static NSArray *sleepTasks = nil;
    if(!sleepTasks) {
        sleepTasks = [self tasksByType:@"SleepTask"];
    }
    return sleepTasks;
}


# pragma mark Saving

- (void)putChanges:(NSArray *)properties {
    NSLog(@"[GOCouchCocoa putChanges:%d]", [properties count]);
    RESTOperation *op = [_couchCocoa.database putChanges:properties];
    NSError *error;
    if([op wait:&error] != YES) {
        NSLog(@"[GOCouchCocoa putChanges:] Error while saving properties %@", [error localizedDescription]);
    }
}


#pragma mark User interface

- (void)processBrewEvent:(GOTaskBrew *)brew firstAlert:(bool)firstAlert title:(NSString *)title body:(NSString *)body {
    if(!brew) {
        NSLog(@"%s Brew missing", __PRETTY_FUNCTION__);
        return;
    }
    if(firstAlert) {
        _eventBrew = brew;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:body
                                                       delegate:self
                                              cancelButtonTitle:@"Annuleren"
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else {
        [[GOMainApp sharedMainApp] presentBrewAfterEvent:brew];
    }
}

- (void)processLocalNotification:(UILocalNotification *)notification whileInForeground:(bool)whileInForeground {
    NSDictionary *userInfo = [notification userInfo];
    if(userInfo) {
        NSString *brewDocId = [userInfo objectForKey:@"brewDocId"];
        if(brewDocId) {
            NSLog(@"%s brewDocId:%@", __PRETTY_FUNCTION__, brewDocId);
            GOTaskBrew *brew = [self brewById:brewDocId];
            if(brew) {
                [self processBrewEvent:brew firstAlert:whileInForeground title:@"Goalie melding" body:[notification alertBody]];
            }
        }
        NSString *type = [userInfo objectForKey:@"type"];
        if([type isEqualToString:@"deadman"]) {
            [[GOMainApp sharedMainApp] setIsTesting:YES];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(![alertView cancelButtonIndex] == buttonIndex) {
        [[GOMainApp sharedMainApp] presentBrewAfterEvent:_eventBrew];
    }
}

- (void)deliverLocalNotificationForBrew:(GOTaskBrew *)brew title:(NSString *)title body:(NSString *)body {
    UIApplication *application = [UIApplication sharedApplication];
    UIApplicationState applicationState = [application applicationState];
    bool isInBackground = (applicationState == UIApplicationStateBackground);
    if(isInBackground) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        [notification setAlertBody:body];
        [notification setUserInfo:@{@"brewDocId":[[brew document] documentID]}];
        [notification setSoundName:UILocalNotificationDefaultSoundName];
        [application presentLocalNotificationNow:notification];
    }
    else {
        bool firstAlert = (isInBackground ? NO : YES);
        [self processBrewEvent:brew firstAlert:firstAlert title:title body:body];
    }
    
}

#pragma mark Misc

- (void)processActiveGoalEndDateEdge {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    [self restart];
    [mainApp performSelector:@selector(syncActiveGoals) withObject:nil afterDelay:5.0];
}

- (NSArray *)getActiveMotionBrews {
    NSDate *nowDate = [[GOMainApp sharedMainApp] nowDate];
    NSTimeInterval timeInterval = 0;
    if(lastBrewsLookup)
        timeInterval = [nowDate timeIntervalSinceDate:lastBrewsLookup];
    if(lastBrewsLookup == nil || timeInterval > 10*60 || timeInterval < 0) {
        NSArray *motionTasks = [self motionTasks];
        [motionTasks enumerateObjectsUsingBlock:^(GOMotionTask *motionTask, NSUInteger idx, BOOL *stop) {
            motionBrews = [self brewsForTask:motionTask forDate:nowDate];
        }];
        lastBrewsLookup = nowDate;
    }
    return motionBrews;
}

- (void)dirtMotionBrews {
    lastBrewsLookup = nil;
    motionBrews = nil;
}

- (void)processTimeActiveInterval:(NSTimeInterval)timeActiveInterval {
    NSArray *brews = [self getActiveMotionBrews];
    [brews enumerateObjectsUsingBlock:^(GOTaskBrew *brew, NSUInteger idx, BOOL *stop) {
        GOActiveMotionTask *activeMotionTask = (id)[brew activeTask];
        NSDate *completionDate = [brew completionDate];
        NSTimeInterval currentInterval = [activeMotionTask timeActiveIntervalFromBrew:brew];
        [activeMotionTask updateBrew:brew timeActiveInterval:timeActiveInterval];
        NSDate *newCompletionDate = [brew completionDate];
        NSTimeInterval diff = timeActiveInterval - currentInterval;
        if(diff < 0)
            diff *= -1;
        // Save the brew every 5 minutes or when the task becomes complete
        if(diff > 5*60 || completionDate != newCompletionDate)
            [brew save];
    }];
    [self pushDeadmanControl];
}

- (void)processNewActiveGoalsDictionaries:(NSArray *)activeGoalsDictionaries {
    int __block nofNewGoals = 0;
    int __block nofDeletedGoals = 0;
    
    CouchQueryEnumerator *enumerator = [self.activeGoalsQuery rows];
    CouchQueryRow *row;
    NSMutableDictionary *currentGoalNames = [[NSMutableDictionary alloc] initWithCapacity:[enumerator count]];
    while((row = [enumerator nextRow])) {
        CouchDocument *doc = [row document];
        GOActiveGoal *activeGoal = [[CouchModelFactory sharedInstance] modelForDocument:doc];
        NSString *type = [activeGoal type];
        if(type)
            [currentGoalNames setObject:activeGoal forKey:type];
    }
        
    [activeGoalsDictionaries enumerateObjectsUsingBlock:^(id activeGoal, NSUInteger idx, BOOL *stop) {
        if([self processActiveGoal:activeGoal])
            nofNewGoals++;
        NSString *type = [activeGoal valueForKey:@"type"];
        [currentGoalNames removeObjectForKey:type];
    }];
    
    NSLog(@"%@", currentGoalNames);
    [currentGoalNames enumerateKeysAndObjectsUsingBlock:^(id key, GOActiveGoal *activeGoal, BOOL *stop) {
        CouchDocument *doc = [activeGoal document];
        [[doc database] deleteDocuments:@[doc]];
        nofDeletedGoals++;
    }];
    
    if(nofNewGoals != 0 || nofDeletedGoals != 0)
       [[GOMainApp sharedMainApp] restart];
    
}

- (void)reloadActiveGoals {
    _activeGoalsQuery = nil;
    self.activeGoalsQuery = [self activeGoalsQuery];
    
}

- (void)processSleepState:(GOSleepState *)sleepState {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // It is about the end dates of the brews
    //AbstractTimeWindow *abstractWindow = [[AbstractTimeWindow alloc] initWithBeginHour:-4 minute:5 endHour:19 endMinute:55];
    
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    NSDate *now = [mainApp nowDate];
    //TimeWindow *timeWindow = [abstractWindow firstValidTimeWindowFromDate:now allowStarted:YES];
    
    bool __block correctSleep = NO;
    bool __block correctWakeup = NO;
    int __block earnedPoints = 0;
    GOTaskBrew __block *notificationBrew = nil;
    int __block nofNoonReports = 0;
    
    /* For debugging
    NSCalendar *curCal = [GOMainApp currentCalendar]; 
    NSDateComponents *todayComponents = [curCal components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:now];
    [todayComponents setHour:7];
    [todayComponents setMinute:12];
    sleepState.endDate = [curCal dateFromComponents:todayComponents];
    [todayComponents setHour:22];
    [todayComponents setMinute:12];
    [todayComponents setDay:[todayComponents day] - 1];
    sleepState.startDate = [curCal dateFromComponents:todayComponents];
     */
    
    NSDate *wakeupDate = [sleepState endDate];
    NSDate *sleepDate = [sleepState startDate];
    bool __block validSleepDate = NO;
    bool __block validWakeupDate = NO;
    
    NSArray *sleepTasks = [self sleepTasks];
    [sleepTasks enumerateObjectsUsingBlock:^(GOSleepTask *sleepTask, NSUInteger idx, BOOL *stop) {
        NSArray *brews = [self brewsForTask:sleepTask forDate:now];
        [brews enumerateObjectsUsingBlock:^(GOTaskBrew *brew, NSUInteger idx, BOOL *stop) {
            if (![sleepTask isWakeup]) {
                if([brew.timeWindow isDateInWindow:sleepDate])
                    validSleepDate = YES;
            }
            else {
                if([brew.timeWindow isDateInWindow:wakeupDate])
                    validWakeupDate = YES;
            }
    
            // Some some brew for later
            if([sleepTask isWakeup])
                notificationBrew = brew;
            else if(!notificationBrew)
                notificationBrew = brew;
    
            if(([sleepTask isWakeup] && validWakeupDate) || (![sleepTask isWakeup] && validSleepDate)) {
                GOActiveSleepTask *activeSleepTask = (id)[brew activeTask];
                bool noonReported = [activeSleepTask noonReportedForBrew:brew];
                [activeSleepTask updateBrew:brew sleepState:sleepState];
                [brew save];
                if(!noonReported && [activeSleepTask noonReportedForBrew:brew]) {
                    nofNoonReports++;
                    earnedPoints += [[brew earnedPoints] intValue];
                    if([sleepTask isWakeup])
                        correctWakeup = [activeSleepTask correctBehaviorForBrew:brew];
                    else
                        correctSleep = [activeSleepTask correctBehaviorForBrew:brew];
                }
            }
        }];
    }];
    
    if(nofNoonReports > 0) {
        NSString *factString = nil;
        NSString *earnedString = @"";
        NSString *adviseString = @"";
        if(correctSleep && correctWakeup) {
            factString = @"Je bent op tijd naar bed gegaan en op tijd opgestaan.";
            earnedString = [NSString stringWithFormat:@"Je verdient %d punten!", earnedPoints];
        }
        else if(correctWakeup) {
            factString = @"Je bent op tijd opgestaan.";
            earnedString = [NSString stringWithFormat:@"Je verdient %d punten.", earnedPoints];
            if(validSleepDate)
                adviseString = @"Probeer ook op tijd naar bed te gaan.";
        }
        else if(correctSleep) {
            factString = @"Je bent op tijd naar bed gegaan.";
            earnedString = [NSString stringWithFormat:@"Je verdient %d punten.", earnedPoints];
            if(validWakeupDate)
                adviseString = @"Probeer ook op tijd op te staan.";
        }
        else {
            if(validWakeupDate || validWakeupDate)
                factString = @"Helaas geen punten verdient met slapen.";
            else
                factString = @"Afgelopen nacht is je slaapgedrag niet gemeten.";
        }
        
        NSString *notificationMessage = [NSString stringWithFormat:@"%@ %@ %@", factString, earnedString, adviseString];
        NSLog(@"%s noficationMessage: %@", __PRETTY_FUNCTION__, notificationMessage);
        [self deliverLocalNotificationForBrew:notificationBrew title:@"Gezond slaapritme" body:notificationMessage];
    }
}

- (void)programLocalNotifications {
    NSLog(@"%s ", __PRETTY_FUNCTION__);
    NSDate *now = [[GOMainApp sharedMainApp] nowDate];
    NSArray *brews = [self brewsFromDate:now limit:64];
    NSArray * __block allTriggers = @[];
    NSMutableArray *newTimers = [[NSMutableArray alloc] init];
    
    // Retrieving all triggers
    [brews enumerateObjectsUsingBlock:^(GOTaskBrew *brew, NSUInteger idx, BOOL *stop) {
        NSArray *triggers = [brew triggers];
        allTriggers = [allTriggers arrayByAddingObjectsFromArray:triggers];
    }];
    
    // Filtering only future triggers
    NSMutableArray *futureTriggers = [[NSMutableArray alloc] initWithCapacity:[allTriggers count]];
    [allTriggers enumerateObjectsUsingBlock:^(GOActiveTrigger *trigger, NSUInteger idx, BOOL *stop) {
        if([[trigger pointInTime] compare:now] == NSOrderedDescending)
            [futureTriggers addObject:trigger];
    }];
    
    // Sorting the triggers on pointInTime
    NSArray *sortedTriggers = [futureTriggers sortedArrayUsingComparator:^NSComparisonResult(GOActiveTrigger *trigger1, GOActiveTrigger *trigger2) {
        NSDate *date1 = [trigger1 pointInTime];
        NSDate *date2 = [trigger2 pointInTime];
        return [date1 compare:date2];
        ;
    }];
    
    
    NSMutableArray *localNotifications = [[NSMutableArray alloc] initWithCapacity:[sortedTriggers count]];
    [sortedTriggers enumerateObjectsUsingBlock:^(GOActiveTrigger *trigger, NSUInteger idx, BOOL *stop) {
        NSTimeInterval timeInterval = [[trigger pointInTime] timeIntervalSinceDate:now];
        NSDate *realTriggerDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
        if([trigger notificationMessage]) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            [notification setAlertBody:[trigger notificationMessage]];
            [notification setFireDate:realTriggerDate];
            [notification setUserInfo:@{@"brewDocId":[[[trigger brew] document] documentID]}];
            [notification setSoundName:UILocalNotificationDefaultSoundName];
            [localNotifications addObject:notification];
        }
        else if([trigger needsFire]) {
            NSTimer *timer = [[NSTimer alloc] initWithFireDate:realTriggerDate
                                                      interval:0
                                                        target:trigger
                                                      selector:@selector(firedByTimer:)
                                                      userInfo:trigger
                                                       repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            [newTimers addObject:timer];
        }
    }];
    
    [self cancelAllCurrentTimers];
    
    _activeTimers = newTimers;
    
    UILocalNotification *deadmanNotification = [self deadmanNotification];
    if(deadmanNotification)
        [localNotifications addObject:deadmanNotification];
    [UIApplication sharedApplication].scheduledLocalNotifications = localNotifications;
}

- (void)cancelAllCurrentTimers {
    // Cancel all current timers
    [_activeTimers enumerateObjectsUsingBlock:^(NSTimer *timer, NSUInteger idx, BOOL *stop) {
        [timer invalidate];
    }];
}

- (void)setValidUsername:(NSString *)validUsername {
    CouchDocument *document = [_couchCocoa getDocumentById:@"validUsername"];
    NSMutableDictionary *properties = [[document properties] mutableCopy];
    if(!validUsername)
        [properties removeObjectForKey:@"username"];
    else
        [properties setValue:validUsername forKey:@"username"];
    [document putProperties:properties];
}

- (NSString *)validUsername {
    CouchDocument *document = [_couchCocoa getDocumentById:@"validUsername"];
    if(!document)
        return nil;
    return [document propertyForKey:@"username"];
}

- (void)updateNofUncompletedTasks {
    NSMutableDictionary *currentNofUncompletedDict = self.nofUncompletedTasksPerActiveGoal;
    NSDate *nowDate = [[GOMainApp sharedMainApp] nowDate];
    CouchModelFactory *modelFactory = [CouchModelFactory sharedInstance];
    CouchQueryEnumerator *enumerator = [_activeGoalsQuery rows];
    CouchQueryRow *row;
    while((row = [enumerator nextRow]) != nil) {
        CouchDocument *doc = [row document];
        GOActiveGoal *activeGoal = [modelFactory modelForDocument:doc];
        NSString *activeGoalId = [doc documentID];
        if(activeGoal) {
            NSInteger newNofUncompleted = [activeGoal nofUncompletedTasksForDate:nowDate];
            NSNumber *currentNofUncompleted = [currentNofUncompletedDict objectForKey:activeGoalId];
            NSInteger currentNof = -1;
            if(currentNofUncompleted)
                currentNof = [currentNofUncompleted integerValue];
            if(newNofUncompleted != currentNof) {
                NSNumber *newNof = [NSNumber numberWithInteger:newNofUncompleted];
                [currentNofUncompletedDict setValue:newNof forKey:activeGoalId];
            }
        }
    }
}

- (void)restart {
    [self programLocalNotifications];
    [self reloadActiveGoals];
    [self dirtMotionBrews];
}

- (void)dealloc {
    
}

@end
