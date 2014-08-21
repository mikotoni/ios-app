//
//  GOSleepState.h
//  Goalie
//
//  Created by Stefan Kroon on 23-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOSleepState : NSObject

- (id)initWithDictionary:(NSDictionary *)dict;

@property NSDate *startDate;
@property NSDate *endDate;
@property (readonly) NSUInteger hours;

@end
