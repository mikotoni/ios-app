//
//  TimeWindow.m
//  DateTest
//
//  Created by Stefan Kroon on 05-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Security/Security.h>
#import <Security/SecRandom.h>
#import "TimeWindow.h"
#import "GOMainApp.h"

@implementation TimeWindow

static bool _doLog = NO;

+ (void)setVerbose:(bool)isVerbose {
    _doLog = isVerbose;
}

+ (NSDateFormatter *)debugDateFormatter {
    static NSDateFormatter *formatter = nil;
    if(!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return formatter;
}

- (id)init {
    self = [super init];
    if(self) {
        _curLocale = [NSLocale currentLocale];
    }
    return self;
}

- (id)initWithBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate {
    self = [self init];
    if(self) {
        _beginDate = beginDate;
        _endDate = endDate;
    }
    return self;
}

- (bool)isDateInWindow:(NSDate *)testDate {
    if(_doLog) {
        NSLog(@"[TimeWindow isDateInWindow:]  testDate:%@", [[TimeWindow debugDateFormatter] stringFromDate:testDate]);
        NSLog(@"[TimeWindow isDateInWindow:] beginDate:%@", [[TimeWindow debugDateFormatter] stringFromDate:_beginDate]);
        NSLog(@"[TimeWindow isDateInWindow:]   endDate:%@", [[TimeWindow debugDateFormatter] stringFromDate:_endDate]);
    }
    NSComparisonResult beginResult = [testDate compare:_beginDate];
    if(beginResult == NSOrderedDescending || beginResult == NSOrderedSame) {
        NSComparisonResult endResult = [testDate compare:_endDate];
        if(endResult == NSOrderedAscending || endResult == NSOrderedSame)
            return true;
    }
    return false;
}

- (NSString *)descriptionWithLocale:(NSLocale *)locale {
    return [NSString stringWithFormat:@"TimeWindow([%@, %@])",
            [[TimeWindow debugDateFormatter] stringFromDate:[self beginDate]],
            [[TimeWindow debugDateFormatter] stringFromDate:[self endDate]]];
}

- (NSString *)description {
    return [self descriptionWithLocale:nil];
}

- (NSDate *)getRandomDateInWindow {
    NSTimeInterval start = [self.beginDate timeIntervalSince1970];
    NSTimeInterval end = [self.endDate timeIntervalSince1970];
    NSTimeInterval diff = end - start;
    NSUInteger randomInt;
    SecRandomCopyBytes(kSecRandomDefault, sizeof(NSInteger), (uint8_t *)&randomInt);
    NSTimeInterval offsetUInt = randomInt % (int)diff;
    NSTimeInterval randomTimeInterval = start + offsetUInt;
    return [NSDate dateWithTimeIntervalSince1970:randomTimeInterval];
}

- (NSString *)relativeDescriptionFromDate:(NSDate *)forDate {
    NSDateFormatter *weekdayFormatter = nil;
    if(!weekdayFormatter) {
        weekdayFormatter = [[NSDateFormatter alloc] init];
        [weekdayFormatter setDateFormat:@"EEEE"];
    }
    
    NSString *dateString;
    NSCalendar *curCal = [NSCalendar currentCalendar];
    NSDateComponents *beginComps =
        [curCal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit| NSHourCalendarUnit
                  fromDate:_beginDate];
    NSDateComponents *diffComponents = [curCal components:NSDayCalendarUnit|NSHourCalendarUnit
                                                 fromDate:_beginDate
                                                   toDate:_endDate
                                                  options:0];
    // Prefix
    NSString *weekday = [weekdayFormatter stringFromDate:_beginDate];
    bool isToday = YES;
    NSDateComponents *nowComps =
    [curCal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
              fromDate:forDate];
    if([nowComps day] != [beginComps day] ||
       [nowComps month] != [beginComps month] ||
       [nowComps year] != [beginComps year])
        isToday = NO;
    
    int daysDiff = [diffComponents day];
    int hoursDiff = [diffComponents hour];
    if(daysDiff == 0) {
        int beginHour = [beginComps hour];
        //int endHour = [endComponents hour];
        if(hoursDiff <= 11) {
            NSString *prefix;
            if(isToday)
                prefix = NSLocalizedString(@"deze", nil);
            else
                prefix = weekday;
            if(beginHour >= 16)
                dateString = [NSString stringWithFormat:NSLocalizedString(@"%@ avond", nil), prefix];
            else if(beginHour > 10)
                dateString = [NSString stringWithFormat:NSLocalizedString(@"%@ middag", nil), prefix];
            else if (beginHour > 4)
                dateString = [NSString stringWithFormat:NSLocalizedString(@"%@ ochtend", nil), prefix];
            else
                dateString = [NSString stringWithFormat:NSLocalizedString(@"%@ nacht", nil), prefix];
        }
        else {
            if(isToday)
                dateString = NSLocalizedString(@"vandaag", nil);
            else
                dateString = weekday;
        }
    }
    else {
        if(daysDiff == 7)
            dateString = @"deze week";
        else {
            NSString *endWeekday = [weekdayFormatter stringFromDate:_endDate];
            dateString = [NSString stringWithFormat:@"%@ - %@", weekday, endWeekday];
        }
    }
    return dateString;
}

@end

@implementation AbstractTimeWindow

#pragma mark Creating and initializing Abstract Time Windows

+ (NSDateComponents *)abstractFromHourMinuteString:(NSString *)string {
    NSCharacterSet *charSplitSet = [NSCharacterSet characterSetWithCharactersInString:@":"];
    NSArray *paramArray = [string componentsSeparatedByCharactersInSet:charSplitSet];
    NSInteger mealHour = [[paramArray objectAtIndex:0] integerValue];
    NSInteger mealMinute = [[paramArray objectAtIndex:1] integerValue];
    return [AbstractTimeWindow componentsForHour:mealHour minute:mealMinute];
}

+ (AbstractTimeWindow *)windowWithBeginHour:(NSUInteger)beginHour minute:(NSUInteger)beginMinute endHour:(NSUInteger)endHour minute:(NSUInteger)endMinte {
    return [[AbstractTimeWindow alloc] initWithBeginHour:beginHour minute:beginMinute endHour:endHour endMinute:endMinte];
}


- (id)init {
    self = [super init];
    if(self) {
        _curCal = [GOMainApp currentCalendar];
        //_beginComponents = [[NSDateComponents alloc] init];
        //_endComponents = [[NSDateComponents alloc] init];
    }
    return self;
}

- (id)initWithBeginComponents:(NSDateComponents *)beginComponents
                endComponents:(NSDateComponents *)endComponents
                    aboveUnit:(NSCalendarUnit)aboveUnit {
    self = [self init];
    if(self) {
        _beginComponents = beginComponents;
        _endComponents = endComponents;
        _aboveUnit = aboveUnit;
        //_descr = [NSString stringWithFormat:@"%@ - %@", [_beginComponents description], [_endComponents description]];
    }
    return self;
}

- (id)initWithBeginHour:(NSUInteger)beginHour minute:(NSUInteger)beginMinute endHour:(NSInteger)endHour endMinute:(NSInteger)endMinute {
    self = [self init];
    if(self) {
        _descr = [NSString stringWithFormat:@"[%d:%d] - [%d:%d]", (int)beginHour, (int)beginMinute, (int)endHour, (int)endMinute];
        _beginComponents = [AbstractTimeWindow componentsForHour:beginHour minute:beginMinute];
        _endComponents = [AbstractTimeWindow componentsForHour:endHour minute:endMinute];
        _aboveUnit = NSDayCalendarUnit;
        //_majorUnit = NSHourCalendarUnit;
    }
    return self;
}

- (id)initWithWeekdayBegin:(NSUInteger)beginWeekday weekdayEnd:(NSUInteger)endWeekday {
    self = [self init];
    if(self) {
        _descr = [NSString stringWithFormat:@"weekday %d - weekday %d", (int)beginWeekday, (int)endWeekday];
        _beginComponents = [AbstractTimeWindow componentsForWeekday:beginWeekday];
        _endComponents = [AbstractTimeWindow componentsForWeekday:endWeekday];
        _aboveUnit = NSWeekCalendarUnit;
        //_majorUnit = NSWeekdayCalendarUnit;
    }
    return self;
}

- (id)initWithBeginMinute:(NSUInteger)beginMinute endMinute:(NSUInteger)endMinute {
    self = [self init];
    if(self) {
        _descr = [NSString stringWithFormat:@"[:%d] - [:%d]", (int)beginMinute, (int)endMinute];
        _beginComponents = [AbstractTimeWindow componentsForMinute:beginMinute];
        _endComponents = [AbstractTimeWindow componentsForMinute:endMinute];
        _aboveUnit = NSHourCalendarUnit;
        //_majorUnit = NSMinuteCalendarUnit;
    }
    return self;
}

#pragma mark Deriving dates from Abstract Time Windows

+ (NSDate *)startDateForDate:(NSDate *)forDate calendar:(NSCalendar *)curCal aboveUnit:(NSCalendarUnit)aboveUnit {
    if(_doLog)
        NSLog(@"[AbstractTimeWindow startDateForDate:] forDate:%@", [[TimeWindow debugDateFormatter] stringFromDate:forDate]);
    NSDate *startDate;
    NSTimeInterval timeInterval;
    bool success = [curCal rangeOfUnit:aboveUnit startDate:&startDate interval:&timeInterval forDate:forDate];
    if(_doLog)
        NSLog(@"[AbstractTimeWindow startDateForDate:] success:%d", success);
    if(!success)
        return nil;
    if(_doLog)
        NSLog(@"[AbstractTimeWindow startDateForDate:] startDate:%@ timeInterval:%f", 
            [[TimeWindow debugDateFormatter] stringFromDate:startDate], 
            timeInterval);
    
    return startDate;
}

+ (NSDate *)dateForStartDate:(NSDate *)startDate calendar:(NSCalendar *)curCal components:(NSDateComponents *)dateComponentsIn {
    if(!startDate)
        return nil;
    NSDateComponents *dateComponents = [dateComponentsIn copy];
    if(dateComponents.day != NSUndefinedDateComponent)
        dateComponents.day -= 1;
    if(dateComponents.week != NSUndefinedDateComponent)
        dateComponents.week -= 1;
    if(dateComponents.weekday != NSUndefinedDateComponent)
        dateComponents.weekday -= 1;
    if(dateComponents.month != NSUndefinedDateComponent)
        dateComponents.month -= 1;
    if(dateComponents.year != NSUndefinedDateComponent)
        dateComponents.year -= 1;
       
    NSDate *theDate = [curCal dateByAddingComponents:dateComponents toDate:startDate options:0];
    if(_doLog) {
        NSLog(@"[AbstractTimeWindow dateForStartDate:%@] Result: %@",
              [[TimeWindow debugDateFormatter] stringFromDate:startDate],
              [[TimeWindow debugDateFormatter] stringFromDate:theDate]);
    }
    return theDate;
    
}

- (NSDate *)startDateForDate:(NSDate *)forDate {
    return [AbstractTimeWindow startDateForDate:forDate calendar:_curCal aboveUnit:_aboveUnit];
}

- (NSDate *)beginDateForStartDate:(NSDate *)startDate {
    return [AbstractTimeWindow dateForStartDate:startDate calendar:_curCal components:_beginComponents];
}

- (NSDate *)endDateForStartDate:(NSDate *)startDate {
    return  [AbstractTimeWindow dateForStartDate:startDate calendar:_curCal components:_endComponents];
}

#pragma mark Deriving Time Windows from Abstract Time Windows

- (TimeWindow *)concreteTimeWindowForDate:(NSDate *)forDate {
    NSDate *startDate = [self startDateForDate:forDate];
    if(!startDate)
        return nil;
    NSDate *beginDate = [self beginDateForStartDate:startDate];
    NSDate *endDate = [self endDateForStartDate:startDate];
    NSComparisonResult compResult = [beginDate compare:endDate];
    if(compResult != NSOrderedAscending) {
        NSDateComponents *addComponent = [AbstractTimeWindow addComponentForCalendarUnit:_aboveUnit amount:1];
        endDate = [_curCal dateByAddingComponents:addComponent toDate:endDate options:0];
    }
    TimeWindow *timeWindow = [[TimeWindow alloc] initWithBeginDate:beginDate endDate:endDate];
    return timeWindow;
}

- (TimeWindow *)firstValidTimeWindowFromDate:(NSDate *)fromDate allowStarted:(bool)allowStarted {
    TimeWindow *concreteTimeWindow = [self concreteTimeWindowForDate:fromDate];

    NSDate *compareDate;
    
    static const int maxNofAttempts = 14;
    int nofAttempts;
    for (nofAttempts = 0; nofAttempts < maxNofAttempts; nofAttempts++) {
        if(allowStarted)
            compareDate = [concreteTimeWindow endDate];
        else
            compareDate = [concreteTimeWindow beginDate];
        
        NSComparisonResult compResult = [compareDate compare:fromDate];
        if(compResult == NSOrderedDescending || compResult == NSOrderedSame)
            break;
        NSDateComponents *addComponent = [AbstractTimeWindow addComponentForCalendarUnit:_aboveUnit amount:1];
            concreteTimeWindow.beginDate = [_curCal dateByAddingComponents:addComponent toDate:concreteTimeWindow.beginDate options:0];
            concreteTimeWindow.endDate = [_curCal dateByAddingComponents:addComponent toDate:concreteTimeWindow.endDate options:0];
    }
    if(nofAttempts >= maxNofAttempts)
        NSLog(@"WARNING: %s Couln't find a good valid window in %d attempts", __PRETTY_FUNCTION__, maxNofAttempts);
    
    return concreteTimeWindow;
}

#pragma mark Testing a Abstract Time Window

- (bool)isDateInWindow:(NSDate *)testDate {
    TimeWindow *timeWindow = [self concreteTimeWindowForDate:testDate];
    return [timeWindow isDateInWindow:testDate];
}

#pragma mark Describing Abstract Time Windows

- (NSString *)descriptionWithLocale:(NSLocale *)locale {
    return [NSString stringWithFormat:@"AbstractTimeWindow(%@)", _descr];
}

- (NSString *)description {
    return [self descriptionWithLocale:nil];
}

#pragma mark Supporting class methods

+ (NSDateComponents *)addComponentForCalendarUnit:(NSCalendarUnit)calendarUnit amount:(NSInteger)amount {
        NSDateComponents *addComponent = [[NSDateComponents alloc] init];
        switch(calendarUnit) {
            case NSYearCalendarUnit:
                [addComponent setYear:amount];
                break;
            case NSMonthCalendarUnit:
                [addComponent setMonth:amount];
                break;
            case NSDayCalendarUnit:
                [addComponent setDay:amount];
                break;
            case NSHourCalendarUnit:
                [addComponent setHour:amount];
                break;
            case NSMinuteCalendarUnit:
                [addComponent setMinute:amount];
                break;
            case NSSecondCalendarUnit:
                [addComponent setSecond:amount];
                break;
            case NSWeekCalendarUnit:
                [addComponent setWeek:amount];
                break;
            case NSWeekdayCalendarUnit:
                [addComponent setWeek:amount];
                break;
            default:
                NSLog(@"Error: unimplemented unit type: %lu", (unsigned long)calendarUnit);
                break;
        }
    return addComponent;
}

+ (NSDateComponents *)componentsForMinute:(NSUInteger)minute {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMinute:minute];
    [dateComponents setSecond:0];
    return dateComponents;
}

+ (NSDateComponents *)componentsForHour:(NSInteger)hour minute:(NSInteger)minute {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setHour:hour];
    [dateComponents setMinute:minute];
    [dateComponents setSecond:0];
    return dateComponents;
}

+ (NSDateComponents *)componentsForWeekday:(NSUInteger)weekday {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setWeekday:weekday];
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    return dateComponents;
}

@end


