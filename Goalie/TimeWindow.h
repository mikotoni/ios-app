//
//  TimeWindow.h
//  DateTest
//
//  Created by Stefan Kroon on 05-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeWindow : NSObject {
    NSLocale *_curLocale;
    bool _doLog;
}

@property (nonatomic, retain) NSDate *beginDate;
@property (nonatomic, retain) NSDate *endDate;

+ (NSDateFormatter *)debugDateFormatter;
- (id)initWithBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate;
- (bool)isDateInWindow:(NSDate *)testDate;
- (NSString *)descriptionWithLocale:(NSLocale *)locale;
- (NSDate *)getRandomDateInWindow;
- (NSString *)relativeDescriptionFromDate:(NSDate *)forDate;
    
@end

@interface AbstractTimeWindow : TimeWindow {
    NSCalendar *_curCal;
    NSString *_descr;
}

@property (nonatomic, strong) NSDateComponents *beginComponents;
@property (nonatomic, strong) NSDateComponents *endComponents;
@property (nonatomic) NSUInteger aboveUnit;
//@property (nonatomic) NSUInteger majorUnit;

- (id)initWithBeginComponents:(NSDateComponents *)beginComponents
                endComponents:(NSDateComponents *)endComponents
                    aboveUnit:(NSCalendarUnit)aboveUnit ;
- (id)initWithBeginHour:(NSUInteger)beginHour minute:(NSUInteger)beginMinute endHour:(NSInteger)endHour endMinute:(NSInteger)endMinute;
- (id)initWithWeekdayBegin:(NSUInteger)beginWeekday weekdayEnd:(NSUInteger)endWeekday;
- (id)initWithBeginMinute:(NSUInteger)beginMinute endMinute:(NSUInteger)endMinute;
+ (AbstractTimeWindow *)windowWithBeginHour:(NSUInteger)beginHour minute:(NSUInteger)beginMinute endHour:(NSUInteger)endHour minute:(NSUInteger)endMinte ;
- (TimeWindow *)concreteTimeWindowForDate:(NSDate *)forDate;
- (TimeWindow *)firstValidTimeWindowFromDate:(NSDate *)fromDate allowStarted:(bool)allowStarted;
- (NSString *)descriptionWithLocale:(NSLocale *)locale;
- (NSString *)description;

+ (NSDateComponents *)addComponentForCalendarUnit:(NSCalendarUnit)calendarUnit amount:(NSInteger)amount;
+ (NSDateComponents *)componentsForWeekday:(NSUInteger)weekday;
+ (NSDateComponents *)componentsForHour:(NSInteger)hour minute:(NSInteger)minute;
+ (NSDateComponents *)componentsForMinute:(NSUInteger)minute;
+ (NSDate *)startDateForDate:(NSDate *)forDate calendar:(NSCalendar *)curCal aboveUnit:(NSCalendarUnit)aboveUnit;
+ (NSDate *)dateForStartDate:(NSDate *)startDate calendar:(NSCalendar *)curCal components:(NSDateComponents *)dateComponents;
+ (NSDateComponents *)abstractFromHourMinuteString:(NSString *)string;
    
@end
