//
//  GOCouchCocoa.h
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchModelFactory.h>

@interface GOCouchCocoa : NSObject <RESTResourceDelegate> {
}

@property (nonatomic, retain) CouchDatabase *database;
@property (nonatomic, retain) CouchDesignDocument *design;

//- (void)initialize:(void (^)(bool success))handler;
- (CouchDocument *)getDocumentById:(NSString *)docId;
- (CouchQuery *)queryViewNamed:(NSString *)name;
- (CouchQuery *)queryViewNamed:(NSString *)name startKey:(id)startKeys;
- (CouchQuery *)queryViewNamed:(NSString *)name keys:(NSArray *)keys;
- (CouchQuery *)queryViewNamed:(NSString *)name startKey:(id)startKeys endKey:(id)endKeys;
- (CouchLiveQuery *)asLiveQuery:(CouchQuery *)query;
- (CouchQuery *)queryViewNamed:(NSString *)name startEndDocument:(CouchDocument *)document;
- (CouchDesignDocument *)createCouchDesignForDatabase:(CouchDatabase *)databaseForAdmin;
- (CouchDesignDocument *)createCouchViewsForLocalDatabase:(CouchDatabase *)databaseForAdmin;
    
- (void)openCouchServerWithCredential:(NSURLCredential *)credential
                             database:(NSString *)databaseName
                              handler:(void (^)(bool success, CouchDatabase *database))handler;
+ (CouchDatabase *)openCouchServerWithCredential:(NSURLCredential *)credential database:(NSString *)databaseName;
- (CouchDatabase *)openTouchDatabaseForUser:(NSString *)username;
    
- (void)logout;
    
@end

@interface CouchNullQuery : CouchQuery

@end
