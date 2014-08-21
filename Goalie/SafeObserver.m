//
//  SafeObserver.m
//  Goalie
//
//  Created by Stefan Kroon on 20-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "SafeObserver.h"

@implementation SafeObserver

- initWithInterestedObject:(id)interestedObject observedObject:(id)observedObject keypath:(NSString *)keypath options:(NSKeyValueObservingOptions)options context:(void *)context {
    self = [super init];
    if(self) {
        _observedObject = observedObject;
        _interestedObject = interestedObject;
        _keypath = keypath;
        _context = context;
        [observedObject addObserver:interestedObject forKeyPath:keypath options:options context:context];
    }
    return self;
}

+ (SafeObserver *)safeObserverInterestedObject:(id)interestedObject
                                observedObject:(id)observedObject
                                       keypath:(NSString *)keypath
                                       options:(NSKeyValueObservingOptions)options
                                       context:(void *)context {
    if(!interestedObject)
        return nil;
    if(!observedObject)
        return nil;
    
    SafeObserver *so = [[SafeObserver alloc] initWithInterestedObject:interestedObject observedObject:observedObject keypath:keypath options:options context:context];
    
    return so;
}

+ (SafeObserver *)safeObserverInterestedObject:(id)interestedObject observedObject:(id)observedObject keypath:(NSString *)keypath {
    return [SafeObserver safeObserverInterestedObject:interestedObject observedObject:observedObject keypath:keypath options:0 context:nil];
}

- (void)dealloc {
    [_observedObject removeObserver:_interestedObject forKeyPath:_keypath context:_context];
}

@end
