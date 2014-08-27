//
//  GOShootPhotoTask.m
//  Goalie
//
//  Created by Stefan Kroon on 28-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOShootPhotoTask.h"

// Model
#import "GOGenericModelClasses.h"

// Services
#import "GOMainApp.h"

// Framework
#import <AssetsLibrary/AssetsLibrary.h>


@implementation GOShootPhotoTask

#ifdef USE_COREDATA
+ (GOShootPhotoTask *)shootPhotoTaskInManagedObjectContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:@"ShootPhotoTask" inManagedObjectContext:context];
}
#endif

+ (Class)relatedActiveTaskClass {
    return [GOActiveShootPhotoTask class];
}

- (bool)countAsUncompleted {
    return NO;
}

@end


@implementation GOActiveShootPhotoTask {
    AbstractTimeWindow *_abstractVisibleWindow;
    id _assetDelegate;
    ALAssetsGroup *_assetsGroup;
    ALAssetsLibrary *_assetsLibrary;
    NSArray *_allAssets;
}

- (void)addAssetToAlbum:(ALAssetsGroup *)group assetURL:(NSURL *)assetURL handler:(void (^)(bool success))handler {
    [[self assetsLibrary] assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        [group addAsset:asset];
        handler(YES);
    } failureBlock:^(NSError *error) {
        NSLog(@"WARNING: Failed to save image to the new album: %@", [error localizedDescription]);
        handler(NO);
    }];
}

- (void)addAssetToGoalieAlbum:(NSURL *)assetURL handler:(void (^)(bool success))handler {
    [[self assetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(!group) {
            [[self assetsLibrary] addAssetsGroupAlbumWithName:kGOGoalieAlbumName resultBlock:^(ALAssetsGroup *newGroup) {
                [self addAssetToAlbum:newGroup assetURL:assetURL handler:^(bool success) {
                    handler(success);
                }];
            } failureBlock:^(NSError *error) {
                NSLog(@"WARNING: Failed to create a new album for Goalie: %@", [error localizedDescription]);
                handler(NO);
            }];
        }
        else if([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:kGOGoalieAlbumName]) {
            *stop = YES;
            [self addAssetToAlbum:group assetURL:assetURL handler:^(bool success) {
                handler(success);
            }];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"WARNING: Failed to enumerate asset library: %@", [error localizedDescription]);
    }];
}

- (void)updateBrew:(GOTaskBrew *)brew image:(UIImage *)photo metadata:(NSDictionary *)metadata {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    
    [[self assetsLibrary] writeImageToSavedPhotosAlbum:[photo CGImage] metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
        [self addAssetToGoalieAlbum:assetURL handler:^(bool success) {
            if(success) {
                [brew setCompletionDate:[mainApp nowDate]];
                [brew.activeGoal didUpdateBrew:brew];
            }
        }];
    }];
    
    
    /*
    NSData *photoData = UIImageJPEGRepresentation(photo, 0.9);
    [brew setValue:photoData forKey:@"photoData"];
     */
}

- (ALAssetsLibrary *)assetsLibrary {
    if(!_assetsLibrary)
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    return _assetsLibrary;
}

- (void)allAssetsWithBlock:(void (^)(NSArray *allAssets))block {
    if(_allAssets) {
        block(_allAssets);
    }
    else {
        _assetsLibrary = [self assetsLibrary];
        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:kGOGoalieAlbumName]) {
                *stop = YES;
                NSMutableArray * __block newAssets = [[NSMutableArray alloc] initWithCapacity:[group numberOfAssets]];
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if(!result)
                        *stop = YES;
                    else
                        [newAssets addObject:result];
                }];
                _allAssets = [newAssets sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(ALAsset *asset1, ALAsset *asset2) {
                    NSDate *date1 = [asset1 valueForProperty:ALAssetPropertyDate];
                    NSDate *date2 = [asset2 valueForProperty:ALAssetPropertyDate];
                    return [date1 compare:date2];
                }];
                block(_allAssets);
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"WARNING: Failed to enumerate the asset library %@", [error localizedDescription]);
        }];
    }
}

- (void)latestPhotoWithBlock:(void (^)(UIImage *))block {
    [self allAssetsWithBlock:^(NSArray *allAssets) {
        ALAssetRepresentation *rep = [[allAssets lastObject] defaultRepresentation];
        UIImage *image = [UIImage imageWithCGImage:[rep fullScreenImage]];
        block(image);
    }];
}

- (AbstractTimeWindow *)abstractTaskWindow {
    if(!_abstractVisibleWindow) {
        _abstractVisibleWindow = [self abstractWeekTask];
    }
    return _abstractVisibleWindow;
}

- (NSString *)activeCellIdentifier {
    return @"ActiveShootPhotoCell";
}


@end