//
//  GOReachabilityManager.m
//  Goalie
//
//  Created by Stefan Kroon on 22-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOReachabilityManager.h"

// Services
#import "GOMainApp.h"
#import "GOKeychain.h"

#import "Reachability.h"

@implementation GOReachabilityManager {
    Reachability *_reachability;
    NetworkStatus oldStatus;
}

- (id)init {
    self = [super init];
    if(self) {
        oldStatus = NotReachable;
        _isOnline = NO;
        _reachability = [Reachability reachabilityWithHostName:@"api.sense-os.nl"];
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(processReachabilityChange) name:kReachabilityChangedNotification object:nil];
        [_reachability startNotifier];
    }
    return self;
}


- (void)processReachabilityChange {
    NetworkStatus newStatus = [_reachability currentReachabilityStatus];
    self.isOnline = (newStatus != NotReachable);
    oldStatus = newStatus;
}

- (void)dealloc {
    [_reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
