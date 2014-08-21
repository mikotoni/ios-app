//
//  GOCouchCocoa.m
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOCouchCocoa.h"
#import <CouchCocoa/CouchModelFactory.h>
#import "GOModelClasses.h"
#import "PaigeConnection.h"
#import "GOMainApp.h"


@implementation GOCouchCocoa

extern BOOL gRESTWarnRaisesException;

#pragma mark Conifuguration

#pragma mark Initialization

- (id)init {
    self = [super init];
    if(self) {
        gRESTWarnRaisesException = YES;
        [GOCouchCocoa registerCouchModelClasses];
    }
    return self;
}

- (NSString *)loadJson:(NSString *)filename {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(!string || [string isEqualToString:@""]) {
        NSLog(@"Failed to load json from file %@", filename);
    }
    return string;
}

- (NSString *)loadJavascript:(NSString *)filename {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"js"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(!string || [string isEqualToString:@""]) {
        NSLog(@"Failed to load javascript from file %@", filename);
    }
    return string;
}

/*
- (CouchDatabase *)database:(NSString *)database username:(NSString *)user password:(NSString *)password {
    NSURL *serverURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@@server.ankr.nl:10001", user, password]];
    CouchServer *server = [[CouchServer alloc] initWithURL:serverURL];
    CouchDatabase *databaseForAdmin = [server databaseNamed:database];
    
    return databaseForAdmin;
}
 */

- (CouchDesignDocument *)createCouchDesignForDatabase:(CouchDatabase *)databaseForAdmin {
    
    // Define the design document and the view
    _design = [databaseForAdmin designDocumentWithName:@"GoalieApp"];
    
    [_design defineViewNamed:@"AllGoals"
                         map:[self loadJavascript:@"AllGoals"]];
    [_design defineViewNamed:@"AllTasks"
                         map:[self loadJavascript:@"AllTasks"]];
    [_design defineViewNamed:@"TasksByGoal"
                         map:[self loadJavascript:@"TasksByGoal"]];
    [_design defineViewNamed:@"CompletionRateByGoal"
                         map:[self loadJavascript:@"CompletionRateByGoalMap"]
                      reduce:[self loadJavascript:@"CompletionRateByGoalReduce"]];
    [_design defineViewNamed:@"MostRecentActivityByGoal"
                         map:[self loadJavascript:@"MostRecentActivityByGoalMap"]
                      reduce:[self loadJavascript:@"MostRecentActivityByGoalReduce"]];
    [_design defineViewNamed:@"ActiveGoalsByType"
                         map:[self loadJavascript:@"ActiveGoalsByTypeMap"]];
    [_design defineViewNamed:@"GoalsByGoalType"
                         map:[self loadJavascript:@"GoalsByGoalType"]];
    [_design defineViewNamed:@"BrewsByActiveGoalTaskOccurrence"
                         map:[self loadJavascript:@"BrewsByActiveGoalTaskOccurrenceMap"]];
    [_design defineViewNamed:@"BrewsByActiveGoalTaskBeginDate"
                         map:[self loadJavascript:@"BrewsByActiveGoalTaskBeginDate"]];
    [_design defineViewNamed:@"ActiveGoalsByBeginDate"
                         map:[self loadJavascript:@"ActiveGoalsByBeginDate"]];
    [_design defineViewNamed:@"EarnedPointsByActiveGoalTaskBeginDate"
                         map:[self loadJavascript:@"EarnedPointsByActiveGoalTaskBeginDateMap"]
                      reduce:[self loadJavascript:@"EarnedPointsByActiveGoalTaskBeginDateReduce"]];
    [_design defineViewNamed:@"BrewsByBeginDate"
                         map:[self loadJavascript:@"BrewsByBeginDate"]];
    [_design defineViewNamed:@"BrewsByEndDate"
                         map:[self loadJavascript:@"BrewsByEndDate"]];
    [_design defineViewNamed:@"BrewsByTaskEndDate"
                         map:[self loadJavascript:@"BrewsByTaskEndDateMap"]];
    [_design defineViewNamed:@"TasksByType"
                         map:[self loadJavascript:@"TasksByType"]];
    return _design;
}

+ (NSArray *)definedTasks {
    NSArray *definedTasks = nil;
    if(!definedTasks) {
        definedTasks = @[ @"ShootPhotoTask",
                          @"SliderTask",
                          @"SwitchTask",
                          @"DescriptiveTask",
                          @"MealTask",
                          @"SleepTask",
                          @"MotionTask",
                          @"VisitTask",
                          @"MoodTask"];
    }
    return definedTasks;
}

+ (NSArray *)definedActiveGoals {
    NSArray *definedActiveGoals = nil;
    if(!definedActiveGoals) {
        definedActiveGoals = @[@"regular_meals",
                               @"physical_activity",
                               @"regular_sleep",
                               @"emotion_awareness",
                               @"agoraphobia"];
        
    }
    return definedActiveGoals;
}

- (CouchDesignDocument *)createCouchViewsForLocalDatabase:(CouchDatabase *)databaseForAdmin {
    // Define the design document and the view
    _design = [databaseForAdmin designDocumentWithName:@"GoalieApp3"];
    
    [_design defineViewNamed:@"BrewsByEndDate"
                    mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
                        NSString *docType = [doc objectForKey:@"type"];
                        if([docType isEqualToString:@"TaskBrew"]) {
                            NSString *endDate = [doc objectForKey:@"endDate"];
                            //NSLog(@"view/BrewsByEndDate: docType:%@ endDate:%@", docType, endDate);
                            emit(endDate, [NSNull null]);
                        }
                    }
                     version:@"1.0"];
    
    [_design defineViewNamed:@"ActiveGoalsByBeginDate"
                    mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
                        NSArray *definedActiveGoals = [GOCouchCocoa definedActiveGoals];
                        NSString *docType = [doc objectForKey:@"type"];
                        if([definedActiveGoals containsObject:docType])
                            emit([doc objectForKey:@"beginDate"], doc);
                    }
                     version:@"1.0"];
    
    [_design defineViewNamed:@"BrewsByActiveGoalEndDate"
                    mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
                        NSString *docType = [doc objectForKey:@"type"];
                        if([docType isEqualToString:@"TaskBrew"]) {
                            NSString *activeGoal = [doc objectForKey:@"activeGoal"];
                            NSString *endDate = [doc objectForKey:@"endDate"];
                            NSArray *key = @[activeGoal, endDate];
                            emit(key, [NSNumber numberWithInt:1]);
                        }
                    } version:@"1.0"];
    
    [_design defineViewNamed:@"UncompletedBrewsByActiveGoalEndDate"
                    mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
                        NSString *docType = [doc objectForKey:@"type"];
                        if([docType isEqualToString:@"TaskBrew"]) {
                            id completedDate = [doc objectForKey:@"completedDate"];
                            if(completedDate == nil || completedDate == [NSNull null]) {
                                NSString *activeGoal = [doc objectForKey:@"activeGoal"];
                                //NSString *task = [doc objectForKey:@"task"];
                                NSString *endDate = [doc objectForKey:@"endDate"];
                                NSArray *key = @[activeGoal, endDate];
                                emit(key, [NSNumber numberWithInt:1]);
                            }
                        }
                    }
     /*
                 reduceBlock:^id(NSArray *keys, NSArray *values, BOOL rereduce) {
                     if(rereduce) {
                         id result = [values valueForKeyPath:@"@sum.self"];
                         return result;
                     }
                     else {
                         return [NSNumber numberWithUnsignedInteger:[values count]];
                     }
                 }
      */
                     version:@"1.0"];
    
    [_design defineViewNamed:@"EarnedPointsByActiveGoalTaskBeginDate"
                    mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
                        NSString *docType = [doc objectForKey:@"type"];
                        if([docType isEqualToString:@"TaskBrew"]) {
                            NSString *activeGoal = [doc objectForKey:@"activeGoal"];
                            NSString *task = [doc objectForKey:@"task"];
                            NSString *beginDate = [doc objectForKey:@"beginDate"];
                            NSArray *key = @[activeGoal, task, beginDate];
                            NSNumber *earnedPoints = [doc objectForKey:@"earnedPoints"];
                            //NSLog(@"EarnedPointsByActiveGoalTaskBeginDate: key:[%@, %@, %@] value:%@", activeGoal, task, beginDate, earnedPoints);
                            emit(key, earnedPoints);
                        }
                    }
                 reduceBlock:^id(NSArray *keys, NSArray *values, BOOL rereduce) {
                     id result = [values valueForKeyPath:@"@sum.self"];
                     //NSLog(@"EarnedPointsByActiveGoalTaskBeginDate: reduce nofKeys:%d nofValues:%d result:%@", [keys count], [values count], result);
                     return result;
                 }
                 version:@"1.0"];
    
     [_design defineViewNamed:@"GoalsByGoalType"
                    mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
                        NSString *docType = [doc objectForKey:@"type"];
                        if([docType isEqualToString:@"Goal"]) {
                            NSString *goalType = [doc objectForKey:@"goalType"];
                            emit(goalType, doc);
                        }
                    }
                     version:@"1.0"];
    
    [_design defineViewNamed:@"TasksByGoal"
                    mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
                        NSString *docType = [doc objectForKey:@"type"];
                        NSArray *definedTasks = [GOCouchCocoa definedTasks];
                        if([definedTasks containsObject:docType]) {
                            NSString *goalId = [doc objectForKey:@"goalId"];
                                emit(goalId, doc);
                            
                        }
                    }
                     version:@"1.0"];
    
     [_design defineViewNamed:@"BrewsByActiveGoalTaskBeginDate"
                    mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
                        NSString *docType = [doc objectForKey:@"type"];
                        if([docType isEqualToString:@"TaskBrew"]) {
                            NSString *activeGoal = [doc objectForKey:@"activeGoal"];
                            NSString *task = [doc objectForKey:@"task"];
                            NSString *beginDate = [doc objectForKey:@"beginDate"];
                            NSArray *key = @[activeGoal, task, beginDate];
                            emit(key, doc);
                        }
                    }
                     version:@"1.0"];
     
     [_design defineViewNamed:@"BrewsByTaskEndDate"
                    mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
                        NSString *docType = [doc objectForKey:@"type"];
                        if([docType isEqualToString:@"TaskBrew"]) {
                            NSString *task = [doc objectForKey:@"task"];
                            NSString *endDate = [doc objectForKey:@"endDate"];
                            NSString *beginDate = [doc objectForKey:@"beginDate"];
                            NSArray *key = @[task, endDate];
                            emit(key, beginDate);
                        }
                    }
                     version:@"1.0"];
     
     [_design defineViewNamed:@"TasksByType"
                    mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
                        NSString *docType = [doc objectForKey:@"type"];
                        NSArray *definedTasks = [GOCouchCocoa definedTasks];
                        if([definedTasks containsObject:docType]) {
                            emit(docType, doc);
                        }
                    }
                     version:@"1.0"];
     
    /*
     [_design defineViewNamed:@""
                    mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
                    }
                     version:@"1.0"];
     
     [_design defineViewNamed:@""
                    mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
                    }
                     version:@"1.0"];
     
     [_design defineViewNamed:@""
                    mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
                    }
                     version:@"1.0"];
     
     [_design defineViewNamed:@""
                    mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
                    }
                     version:@"1.0"];
     
     [_design defineViewNamed:@""
                    mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
                    }
                     version:@"1.0"];
    */
    
    [_design defineViewNamed:@"AllGoals"
                    mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
                        NSString *docType = [doc objectForKey:@"type"];
                        if([docType isEqualToString:@"Goal"])
                            emit([doc objectForKey:@"documentID"], doc);
                    } version:@"1.0"];
    
    return _design;
}

+ (BOOL)registerCouchModelClasses {
    static bool didCreateModelClasses = NO;
    if(!didCreateModelClasses) {
        CouchModelFactory *factory = (id)[CouchModelFactory sharedInstance];
        [factory registerClass:[GOGoal class] forDocumentType:@"Goal"];
        [factory registerClass:[GOActiveGoal class] forDocumentType:@"ActiveGoal"];
        [factory registerClass:[GOTask class] forDocumentType:@"Task"];
        [factory registerClass:[GOTaskBrew class] forDocumentType:@"TaskBrew"];
        [factory registerClass:[GOExerciseStateSensor class] forDocumentType:@"ExerciseStateSensor"];
        
        // Create all active goal class models
        [factory registerClass:[GORegularMealsGoal class] forDocumentType:@"regular_meals"];
        [factory registerClass:[GOAgoraphobiaGoal class] forDocumentType:@"agoraphobia"];
        [factory registerClass:[GORegularSleepGoal class] forDocumentType:@"regular_sleep"];
        [factory registerClass:[GOPhysicalActivityGoal class] forDocumentType:@"physical_activity"];
        [factory registerClass:[GOEmotionAwarenessGoal class] forDocumentType:@"emotion_awareness"];
        
        // Create all task class models
        [[GOCouchCocoa definedTasks] enumerateObjectsUsingBlock:^(NSString *taskName, NSUInteger idx, BOOL *stop) {
            NSString *className = [NSString stringWithFormat:@"GO%@", taskName];
            Class klass = NSClassFromString(className);
            if(!klass) {
                NSLog(@"WARNING: %s Failed to get class with name %@", __PRETTY_FUNCTION__, className);
            }
            else {
                [factory registerClass:klass forDocumentType:taskName];
            }
        }];
        
        didCreateModelClasses = YES;
    }
    
    return YES;
}

/*
- (void)logQueryRows:(CouchQueryEnumerator *)enumerator {
    CouchQueryRow *row;
    while((row = [enumerator nextRow])) {
        CouchDocument *document = [row document];
        NSString *docId = [document documentID];
        NSString *name = [document propertyForKey:@"name"];
        if(!name)
            name = [document propertyForKey:@"type"];
        NSLog(@"[GOCouchCocoa logQueryRows:]: [%@, %@]", docId, name);
    }
}
 */

#pragma mark Querying

- (CouchDocument *)getDocumentById:(NSString *)docId {
    CouchQuery *query = [_database getDocumentsWithIDs:@[docId]];
    [query setPrefetch:YES];
    CouchQueryRow *row = [[query rows] nextRow];
    CouchDocument *doc = [row document];
    return doc;
}

- (CouchQuery *)queryViewNamed:(NSString *)name {
    //NSLog(@"[GOCouchCocoa queryViewNamed:@\"%@\"]", name);
    CouchQuery *query = [_design queryViewNamed:name];
    [query setDelegate:self];
    return query;
}

- (CouchQuery *)queryViewNamed:(NSString *)name startKey:(id)startKeys {
        NSString *startKeysString = nil;
    if([startKeys isKindOfClass:[NSArray class]]) {
        if([startKeys count] == 1)
            startKeysString = [NSString stringWithFormat:@"@[%@]", [startKeys objectAtIndex:0]];
        else
            startKeysString = [startKeys description];
    }
    else
        startKeysString = startKeys;
    //NSLog(@"[GOCouchCocoa queryViewNamed:@\"%@\" startKeys:***]", name);
    //NSLog(@"[GOCouchCocoa queryViewNamed:@\"%@\" startKeys:%@]", name, startKeysString);
    CouchQuery *query = [_design queryViewNamed:name];
    [query setStartKey:startKeys];
    [query setDelegate:self];
    return query;
}

- (CouchQuery *)queryViewNamed:(NSString *)name keys:(NSArray *)keys {
    NSString *keysString = nil;
    if([keys count] == 1)
        keysString = [NSString stringWithFormat:@"@[%@]", [keys objectAtIndex:0]];
    else
        keysString = [keys description];
    //NSLog(@"[GOCouchCocoa queryViewNamed:@\"%@\" keys:***]", name);
    //NSLog(@"[GOCouchCocoa queryViewNamed:@\"%@\" keys:%@]", name, keysString);
    CouchQuery *query = [_design queryViewNamed:name];
    [query setKeys:keys];
    [query setDelegate:self];
    return query;
}

- (CouchQuery *)queryViewNamed:(NSString *)name startKey:(id)startKeys endKey:(id)endKeys {
    //NSLog(@"[GOCouchCocoa queryViewNamed:@\"%@\" startKey:*** endKey:***]", name);
    //NSLog(@"[GOCouchCocoa queryViewNamed:@\"%@\" startKey:%@ endKey:%@]", name, startKeys, endKeys);
    CouchQuery *query = [_design queryViewNamed:name];
    [query setStartKey:startKeys];
    [query setEndKey:endKeys];
    [query setDelegate:self];
    return query;
}

- (CouchQuery *)queryViewNamed:(NSString *)name startEndDocument:(CouchDocument *)document {
    //NSLog(@"[GOCouchCocoa queryViewNamed:@\"%@\" documentID:%@]", name, [document abbreviatedID]);
    CouchQuery *query = [_design queryViewNamed:name];
    NSString *docId = [document documentID];
    [query setStartKey:@[docId]];
    [query setEndKey:@[docId, @{}]];
    [query setDelegate:self];
    return query;
    
}

- (CouchLiveQuery *)asLiveQuery:(CouchQuery *)query {
    CouchLiveQuery *liveQuery = [query asLiveQuery];
    [liveQuery setDelegate:self];
    return liveQuery;
}

#pragma mark Logging

- (void)resource:(RESTResource *)resource willSendRequest:(NSMutableURLRequest *)request {
    //NSLog(@"Resource %@ will send request: %@", [resource relativePath], [request HTTPMethod]);
}

- (void)resource:(RESTResource *)resource didReceiveResponse:(NSHTTPURLResponse *)response {
    int statusCode = [response statusCode];
    if(statusCode != 200) {
        if([resource isKindOfClass:[CouchLiveQuery class]])
            NSLog(@"CouchLiveQuery resource %@ did receive response: %d", [resource relativePath], statusCode);
        else
            NSLog(@"Resource %@ did receive response: %d", [resource relativePath], statusCode);
    }
}

/*
- (CouchQueryEnumerator *)rowsForQuery:(CouchQuery *)query {
    if([query isKindOfClass:[CouchLiveQuery class]]) {
        CouchLiveQuery *liveQuery = (id)query;
        [liveQuery wait];
    }
    CouchQueryEnumerator *enumerator = [query rows];
    [self logQueryRows:enumerator];
    return enumerator;
}
 */

#pragma  mark Remote database

+ (CouchDatabase *)openCouchServerWithCredential:(NSURLCredential *)credential database:(NSString *)databaseName {
    CFStringRef chars = CFSTR(":/?#[]@!$&'()*+,;=");
    CFStringRef encodedUsername = CFURLCreateStringByAddingPercentEscapes(
                                                                          kCFAllocatorDefault,
                                                                          (__bridge CFStringRef)([credential user]),
                                                                          NULL, chars,
                                                                          kCFStringEncodingUTF8);
    CFStringRef encodedPassword = CFURLCreateStringByAddingPercentEscapes(
                                                                          kCFAllocatorDefault,
                                                                          (__bridge CFStringRef)([credential password]),
                                                                          NULL, chars,
                                                                          kCFStringEncodingUTF8);
    NSURL *serverURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@@server.ankr.nl:10001", encodedUsername, encodedPassword]];
    
    CouchServer *server = [[CouchServer alloc] initWithURL:serverURL];
    CouchDatabase *database = [server databaseNamed:databaseName];
    RESTOperation *operation = [database GET];
    NSError *error;
    if([operation wait:&error]) {
        NSURLCredential *sessionCredential = [NSURLCredential credentialWithUser:[credential user] password:[credential password] persistence:NSURLCredentialPersistenceForSession];
        [database setCredential:sessionCredential];
        return  database;
    }
    else {
        NSString *errorText = [NSString stringWithFormat:
                               @"Failed to open database %@ on server %@. Error: %@",
                               databaseName,
                               [serverURL absoluteString],
                               [[operation error] localizedDescription]];
        [[GOMainApp sharedMainApp] errorAlertMessage:errorText];
        //handler(NO);
        return nil;
    }
    
    //[operation onCompletion:^{
        //if(!operation.isSuccessful) {
        //}
        //else {
    //}];
}

- (void)openCouchServerWithCredential:(NSURLCredential *)credential
                             database:(NSString *)databaseName
                              handler:(void (^)(bool success, CouchDatabase *database))handler {
    CouchDatabase *serverDatabase = [GOCouchCocoa openCouchServerWithCredential:credential database:databaseName];
    dispatch_async(dispatch_get_main_queue(), ^{
        handler(serverDatabase != nil, serverDatabase);
    });
}

- (void)logout {
    self.design = nil;
    self.database = nil;
}

/*
- (void)initialize:(void (^)(bool success))handler {
    [self openCouchServer:^(bool success) {
        if(success)
            [self createCouchDesign];
        handler(success);
    }];
}
 */

#pragma mark Local database

- (bool)createBasicDocumentsForDatabase:(CouchDatabase *)database {
    NSMutableSet *activeOperations = [[NSMutableSet alloc] initWithCapacity:20];
    NSError *error;
    
    NSString *goalsJson = [self loadJson:@"AllGoals"];
    NSData *goalsData = [goalsJson dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *goalsResultDict = [NSJSONSerialization JSONObjectWithData:goalsData options:0 error:&error];
    if(!goalsResultDict) {
        NSLog(@"%s Failed to parse json goals data", __PRETTY_FUNCTION__);
        return false;
    }
    
    NSArray *goalRows = [goalsResultDict objectForKey:@"rows"];
    //NSMutableArray *documents = [[NSMutableArray alloc] initWithCapacity:[rows count]];
    [goalRows enumerateObjectsUsingBlock:^(NSDictionary *row, NSUInteger idx, BOOL *stop) {
        NSDictionary *docValue = [row valueForKey:@"value"];
        NSString *documentID = [docValue objectForKey:@"_id"];
        NSMutableDictionary *targetDict = [docValue mutableCopy];
        [targetDict removeObjectForKey:@"_id"];
        [targetDict removeObjectForKey:@"_rev"];
        CouchDocument *document = [database documentWithID:documentID];
        if([document currentRevisionID])
            [targetDict setObject:[document currentRevisionID] forKey:@"_rev"];
        RESTOperation *op = [[document putProperties:targetDict] start];
        [activeOperations addObject:op];
    }];
    
    NSString *tasksJson = [self loadJson:@"AllTasks"];
    NSData *tasksData = [tasksJson dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *tasksResultDict = [NSJSONSerialization JSONObjectWithData:tasksData options:0 error:&error];
    if(!tasksResultDict) {
        NSLog(@"%s Failed to parse json tasks data", __PRETTY_FUNCTION__);
        return false;
    }
    
    //gRESTLogLevel = kRESTLogRequestURLs;
    NSArray *taskRows = [tasksResultDict objectForKey:@"rows"];
    [taskRows enumerateObjectsUsingBlock:^(NSDictionary *row, NSUInteger idx, BOOL *stop) {
        NSDictionary *docValue = [row valueForKey:@"value"];
        NSString *documentID = [docValue objectForKey:@"_id"];
        NSMutableDictionary *targetDict = [docValue mutableCopy];
        [targetDict removeObjectForKey:@"_id"];
        [targetDict removeObjectForKey:@"_rev"];
        CouchDocument *document = [database documentWithID:documentID];
        [document properties];
        NSString *currentRevisionId = [document currentRevisionID];
        NSLog(@"%s currentRevisionID:%@", __PRETTY_FUNCTION__, currentRevisionId);
        if(currentRevisionId) {
            [targetDict setObject:[document documentID] forKey:@"_id"];
            [targetDict setObject:[document currentRevisionID] forKey:@"_rev"];
        }
        RESTOperation *op = [[document putProperties:targetDict] start];
        [activeOperations addObject:op];
        
        /*
        NSError *error;
        bool success = [op wait:&error];
        if(!success)
            NSLog(@"Error %@ on %@", [error localizedDescription], op);
         */
    }];
    
    [RESTOperation wait:activeOperations];
    
    return YES;
}

- (CouchDatabase *)openTouchDatabaseForUser:(NSString *)username {
    CouchTouchDBServer *couchTouchServer = [CouchTouchDBServer sharedInstance];
    if(couchTouchServer.error) {
        NSLog(@"%s Failed to start the CouchTouchServer: %@", __PRETTY_FUNCTION__, [couchTouchServer.error localizedDescription]);
        return NO;
    }
    
    NSString *md5username = [[PaigeConnection md5:username] lowercaseString];
    NSString *databaseName = [NSString stringWithFormat:@"goalie_%@", md5username];
    CouchTouchDBDatabase *couchTouchDatabase = (CouchTouchDBDatabase *)[couchTouchServer databaseNamed:databaseName];
    NSError *error = nil;
    if(![couchTouchDatabase ensureCreated:&error]) {
        NSLog(@"%s Failed to open CouchTouchDatabase: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
        RESTOperation *op = [couchTouchDatabase create];
        NSError *error;
        bool success = [op wait:&error];
        if(!success) {
            NSLog(@"%s Failed to create the database: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
            return nil;
        }
        return nil;
    }
    
    [self createBasicDocumentsForDatabase:couchTouchDatabase];
    
    return couchTouchDatabase;
}


@end

@implementation CouchNullQuery

- (CouchQueryEnumerator *)rows {
    return (CouchQueryEnumerator *)@[];
}

@end