//
//  GOActiveShootPhotoCell.m
//  Goalie
//
//  Created by Stefan Kroon on 29-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOActiveShootPhotoCell.h"

// Frameworks
#import <AssetsLibrary/AssetsLibrary.h>

// Model
#import "GOShootPhotoTask.h"

@implementation GOActiveShootPhotoCell {
    GOActiveShootPhotoTask *_activePhotoTask;
    NSArray *_assets;
    int _assetIndex;
    UISwipeGestureRecognizer *_nextSwipe;
    UISwipeGestureRecognizer *_previousSwipe;
}

- (void)displayPhotoAtIndex:(int)index {
    if([_assets count] <= 0)
        return;
    ALAsset *asset = [_assets objectAtIndex:index];
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    UIImage *image = [UIImage imageWithCGImage:[rep fullScreenImage]];
    self.photoImageView.image = image;
}

- (void)updateDisplayedValuesAnimated:(bool)animated {
    [super updateDisplayedValuesAnimated:animated];
    
    if(!_nextSwipe) {
        _nextSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextPhoto:)];
        _nextSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        [self.photoImageView addGestureRecognizer:_nextSwipe];
    }
    
    if(!_previousSwipe) {
        _previousSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previousPhoto:)];
        _previousSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.photoImageView addGestureRecognizer:_previousSwipe];
    }
    
    self.nextButton.hidden = YES;
    self.previousButton.hidden = YES;
    
    _activePhotoTask = (id)[_brew activeTask];
    GOShootPhotoTask *shootPhotoTask = (id)[_activePhotoTask task];
    
    self.titleLabel.text = [shootPhotoTask title];
    
    [self updatePhoto];
    
}

- (void)updatePhoto {
    [_activePhotoTask allAssetsWithBlock:^(NSArray *allAssets) {
        _assets = allAssets;
        _assetIndex = [allAssets count] - 1;
        [self displayPhotoAtIndex:_assetIndex];
    }];
}

- (void)nextPhoto:(id)sender {
    _assetIndex++;
    if(_assetIndex >= [_assets count])
        _assetIndex = 0;
    [self displayPhotoAtIndex:_assetIndex];
}

- (void)previousPhoto:(id)sender {
    _assetIndex--;
    if(_assetIndex <= 0)
        _assetIndex = [_assets count] - 1;
    [self displayPhotoAtIndex:_assetIndex];
}

@end
