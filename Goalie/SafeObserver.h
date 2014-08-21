//
//  SafeObserver.h
//  Goalie
//
//  Created by Stefan Kroon on 20-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SafeObserver : NSObject {
    id __weak _observedObject;
    id __weak _interestedObject;
    NSString *_keypath;
    void *_context;
}

+ (SafeObserver *) safeObserverInterestedObject:(id)interestedObject
                                 observedObject:(id)observedObject
                                        keypath:(NSString *)keypath
                                        options:(NSKeyValueObservingOptions)options
                                        context:(void *)context;

+ (SafeObserver *)safeObserverInterestedObject:(id)interestedObject observedObject:(id)observedObject keypath:(NSString *)keypath;

@end
