//
//  GORestKit.m
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GORestKit.h"

@implementation GORestKit

//@synthesize objectManager = _objectManager;
//@synthesize managedObjectStore = _managedObjectStore;


- (id)init {
    self = [super init];
    if(self) {
    //[mainApp configureRestkitWithServerURL:serverURL modelURL:modelURL databaseFile:sqliteFile];
    }
    return self;
}

/*
- (RKEntityMapping *)createTaskMapping:(NSString *)taskName attributes:(NSDictionary *)attributesDict {
    static NSDictionary *taskDictionary = nil;
    if(!taskDictionary)
        taskDictionary = @{ @"uuid": @"uuid",
                            @"name": @"name",
                            @"completed":@"completed",
                            @"manual":@"manual"
        };
    
    // Map the task objects
    NSMutableDictionary *specificTaskDict = [taskDictionary mutableCopy];
    [specificTaskDict addEntriesFromDictionary:attributesDict];
    RKEntityMapping *specificTaskMapping =
            [RKEntityMapping mappingForEntityForName:taskName inManagedObjectStore:_managedObjectStore];
    specificTaskMapping.identificationAttributes = @[@"uuid"];
    [specificTaskMapping addAttributeMappingsFromDictionary:specificTaskDict];
    return specificTaskMapping;
}
*/

/*
- (void)configureRestkitWithServerURL:(NSURL *)serverURL
                             modelURL:(NSURL *)modelURL
                         databaseFile:(NSString *)databaseFile {
    // Enable loggin
    RKLogConfigureByName("RestKit/CoreData", RKLogLevelDebug);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelDebug);
    
    // Create the RKObjectManager
    _objectManager = [RKObjectManager managerWithBaseURL:serverURL];
    _objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    _managedObjectModel =
            [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    if(!_managedObjectModel) {
        NSLog(@"Failed to create a managedObjectModel");
    }
    
    // Create the RKManagedObjectStore
    _managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:_managedObjectModel];
    if(!_managedObjectStore) {
        NSLog(@"Failed to create a managedObjectStore");
    }
    
    // Add the SQL store
    NSError *error = nil;
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:databaseFile];
    NSPersistentStore *persistentStore =
        [_managedObjectStore addSQLitePersistentStoreAtPath:storePath
                                     fromSeedDatabaseAtPath:nil
                                          withConfiguration:nil
                                                    options:nil
                                                      error:&error];
    if(persistentStore == nil) {
        NSLog(@"Failed to add store: %@", [error localizedDescription]);
        if([error code] == 134130) {
            NSURL *storeURL = [NSURL fileURLWithPath:storePath];
            BOOL success = [RKManagedObjectStore migratePersistentStoreOfType:nil atURL:storeURL toModelAtURL:modelURL error:&error configuringModelsWithBlock:^(NSManagedObjectModel *model, NSURL *sourceURL) {
                NSLog(@"Model versionIdentifiers: %@", [model versionIdentifiers]);
                NSLog(@"sourceURL: %@", sourceURL);
            }];
            if(!success)
                NSLog(@"Failed to migrate the persistent store.");
        }
    }
    [_managedObjectStore createManagedObjectContexts];
    _managedObjectContext = _managedObjectStore.mainQueueManagedObjectContext;
    
    // Link the RKObjectManager and the RKManagedObjectStore
    _objectManager.managedObjectStore = _managedObjectStore;
    //objectManager.client.cachePolicy = 0;
    
    // Map the GOGoal object
    RKEntityMapping *goalMapping =
            [RKEntityMapping mappingForEntityForName:@"Goal" inManagedObjectStore:_managedObjectStore];
    [goalMapping addAttributeMappingsFromDictionary:@{
        @"uuid":        @"uuid",
        @"headline":    @"headline",
        @"explanation": @"explanation",
        @"deadline":    @"deadline"
     }];
    goalMapping.identificationAttributes = @[@"uuid"];
    
    NSEntityDescription *goalEntity = [NSEntityDescription entityForName:@"Goal" inManagedObjectContext:_managedObjectContext];
    NSRelationshipDescription *tasksRelationship = [goalEntity relationshipsByName][@"tasks"];
    RKConnectionDescription *goalTaskConnection = [[RKConnectionDescription alloc] initWithRelationship:tasksRelationship keyPath:@"tasks"];
    [goalMapping addConnection:goalTaskConnection];
    
    
    // All tasks
    RKEntityMapping *openQuestionTaskMapping =
        [self createTaskMapping:@"OpenQuestionTask"
                     attributes:@{
         @"question":@"question",
         @"answer":@"answer"
     }];
    RKEntityMapping *mealTaskMapping =
        [self createTaskMapping:@"MealTask"
                     attributes:@{
         @"kind":@"kind"
    }];
    RKEntityMapping *moodTaskMapping =
        [self createTaskMapping:@"MoodTask"
                     attributes:@{
         @"arousal":@"arousal",
         @"dominance":@"dominance",
         @"pleasure":@"pleasure"
     }];
    RKEntityMapping *shootPhotoTaskMapping =
        [self createTaskMapping:@"ShootPhotoTask"
                     attributes:@{
        @"photoData": @"photoData"
    }];
    
    RKDynamicMapping *taskMapping = [RKDynamicMapping new];
    [taskMapping addMatcher:[RKObjectMappingMatcher matcherWithKeyPath:@"type"
                                                         expectedValue:@"OpenQuestionTask"
                                                         objectMapping:openQuestionTaskMapping]];
    [taskMapping addMatcher:[RKObjectMappingMatcher matcherWithKeyPath:@"type"
                                                         expectedValue:@"MealTask"
                                                         objectMapping:mealTaskMapping]];
    [taskMapping addMatcher:[RKObjectMappingMatcher matcherWithKeyPath:@"type"
                                                         expectedValue:@"MoodTask"
                                                         objectMapping:moodTaskMapping]];
    [taskMapping addMatcher:[RKObjectMappingMatcher matcherWithKeyPath:@"type"
                                                          expectedValue:@"ShootPhotoTask"
                                                          objectMapping:shootPhotoTaskMapping]];
    
    RKRelationshipMapping *tasksRelationMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"tasks"
                                                                                              toKeyPath:@"tasks"
                                                                                            withMapping:taskMapping];
    //[tasksRelationMapping setAssignmentPolicy:RKReplaceAssignmentPolicy];
    [goalMapping addPropertyMapping:tasksRelationMapping];
    
     // Define the response descriptor
    NSIndexSet *goalStatusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *goalDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:goalMapping
                                                pathPattern:nil
                                                    keyPath:@"goals"
                                                statusCodes:goalStatusCodes];
     // Map errors
    RKObjectMapping *errorMapping =
        [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"messsage"]];
    NSIndexSet *errorStatusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError);
    RKResponseDescriptor *errorDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:errorMapping
                                                pathPattern:nil
                                                    keyPath:@"errors"
                                                statusCodes:errorStatusCodes];
    [_objectManager addResponseDescriptorsFromArray:@[goalDescriptor, errorDescriptor]];
    
    
    // Define the request descriptor
    //RKRequestDescriptor *goalRequestDescriptor =
    //[RKRequestDescriptor requestDescriptorWithMapping:goalMapping objectClass:[GOGoal class] rootKeyPath:nil];
    
    //[_objectManager addRequestDescriptor:goalRequestDescriptor];
}
*/

@end
