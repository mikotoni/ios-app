//
//  GOSleepState.m
//  Goalie
//
//  Created by Stefan Kroon on 23-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOSleepState.h"

@implementation GOSleepState {
    NSDate *_startDate;
    NSDate *_endDate;
    NSUInteger _hours;
    NSDictionary *_sleep_time;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if(self) {
        _sleep_time = dict;
        _hours = NSUIntegerMax;
    }
    return self;
}

- (void)setStartDate:(NSDate *)startDate {
    _startDate = startDate;
}

- (void)setEndDate:(NSDate *)endDate {
    _endDate = endDate;
}

- (NSDate *)startDate {
    if(!_startDate) {
        NSNumber *startDateNumber = [_sleep_time objectForKey:@"start_date"];
        NSTimeInterval startDateTimeInterval = [startDateNumber floatValue];
        _startDate = [NSDate dateWithTimeIntervalSince1970:startDateTimeInterval];
    }
    return _startDate;
}

- (NSDate *)endDate {
    if(!_endDate) {
        NSNumber *endDateNumber = [_sleep_time objectForKey:@"end_date"];
        NSTimeInterval endDateTimeInterval = [endDateNumber floatValue];
        _endDate = [NSDate dateWithTimeIntervalSince1970:endDateTimeInterval];
    }
    return _endDate;
}

- (NSUInteger)hours {
    if(_hours == NSUIntegerMax) {
        NSNumber *hoursNumber = [_sleep_time objectForKey:@"sleepTime"];
        _hours = [hoursNumber unsignedIntegerValue];
    }
    return _hours;
}

@end
