//
//  GOShootPhotoTask.h
//  Goalie
//
//  Created by Stefan Kroon on 28-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOTask.h"
#import "GOActiveTask.h"

static NSString * const kGOGoalieAlbumName = @"Goalie";

@interface GOShootPhotoTask : GOTask

#ifdef USE_COREDATA
+ (GOShootPhotoTask *)shootPhotoTaskInManagedObjectContext:(NSManagedObjectContext *)context;
#endif
    
//@property (nonatomic, retain) NSData * photoData;

@end

@interface GOActiveShootPhotoTask : GOActiveTask

- (void)updateBrew:(GOTaskBrew *)brew image:(UIImage *)photo metadata:(NSDictionary *)metadata;
- (void)allAssetsWithBlock:(void (^)(NSArray *allAssets))block;
- (void)latestPhotoWithBlock:(void (^)(UIImage *))block;
    
@end
