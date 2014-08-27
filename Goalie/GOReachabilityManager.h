//
//  GOReachabilityManager.h
//  Goalie
//
//  Created by Stefan Kroon on 22-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;

static NSString * const kGOIsOnline = @"isOnline";

@interface GOReachabilityManager : NSObject

@property (atomic) bool isOnline;

@end
