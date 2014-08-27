//
//  Goal.m
//  Goalie
//
//  Created by Stefan Kroon on 19-04-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOGoal.h"
#import "GOGenericModelClasses.h"
#import "GOMainApp.h"
#import "GOGoalieServices.h"
#import "TimeWindow.h"

@implementation GOGoal

@dynamic uuid;
@dynamic explanation;
@dynamic headline;
@dynamic goalType;
@dynamic abstractTimeWindowString;

//@dynamic tasks;

//@synthesize completionRate;
//@synthesize lastActivityDate;

#ifdef USE_COREDATA
+ (GOGoal *)goalInManagedObjectContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:@"Goal" inManagedObjectContext:context];
}
#endif

- (void)awakeFromInsert {
    self.uuid = [[NSUUID UUID] UUIDString];
}

- (void)didLoadFromDocument {
    [self awakeFromFetch];
}

- (NSSet *)tasks {
    if(!_tasks) {
        GOGoalieServices *goalieServices = [[GOMainApp sharedMainApp] goalieServices];
        NSString *documentId = [[self document] documentID];
        CouchQuery *query = [goalieServices queryForTasksByGoalWithKeys:@[documentId]];
        
        
        CouchQueryEnumerator *enumerator = [query rows];
        CouchQueryRow *row;
        NSMutableArray *tasks = [[NSMutableArray alloc] initWithCapacity:[enumerator count]];
        while((row = [enumerator nextRow]) != nil) {
            CouchDocument *document = [row document];
            GOTask *task = [[CouchModelFactory sharedInstance] modelForDocument:document];
            [tasks addObject:task];
        }
        _tasks = [[NSSet alloc] initWithArray:tasks];
    }
    return _tasks;
}

- (void)awakeFromFetch {
    //[self calculateCompletionRate];
    //[self calculateLastActivityDate];
}

- (AbstractTimeWindow *)abstractTimeWindow {
    NSString *abstractTimeWindowString = [self abstractTimeWindowString];
    if([abstractTimeWindowString isEqualToString:@"week"])
        return [[AbstractTimeWindow alloc] initWithWeekdayBegin:0 weekdayEnd:7];
    else if([abstractTimeWindowString isEqualToString:@"day"])
        return [[AbstractTimeWindow alloc] initWithBeginHour:0 minute:0 endHour:24 endMinute:0];
    else {
        // Default to week
        return [[AbstractTimeWindow alloc] initWithWeekdayBegin:0 weekdayEnd:7];
    }
}

/*
- (float)completionRate {
    if(!_validCompletionRate) {
        [self calculateCompletionRate];
    }
    return _completionRate;
}

- (void)calculateCompletionRate {
    _completionRate = 1.0;
    NSString *docId = [[self document] documentID];
    CouchQuery *query = [[[GOMainApp sharedMainApp] couchCocoa] queryViewNamed:@"CompletionRateByGoal" keys:@[docId]];
    //[query setGroupLevel:1];
    [query setGroup:YES];
    if(query) {
        CouchQueryEnumerator *enumerator = [query rows];
        if(enumerator) {
            CouchQueryRow *row = [enumerator nextRow];
            if(row) {
                NSDictionary *dict = [row value];
                if(dict) {
                    int nofDocs = [[dict valueForKey:@"nofDocs"] integerValue];
                    int nofCompleted = [[dict valueForKey:@"nofCompleted"] integerValue];
                    if(nofDocs > 0) {
                        _completionRate = (float)nofCompleted / (float)nofDocs;
                        _validCompletionRate = YES;
                    }
                }
            }
        }
    }
    return;
}

- (NSDate *)lastActivityDate {
    if(!_validLastActivityDate) {
        [self calculateLastActivityDate];
    }
    return _lastActivityDate;
}

- (void)calculateLastActivityDate {
    _lastActivityDate = nil;
    NSString *docId = [[self document] documentID];
    id query = [[[GOMainApp sharedMainApp] couchCocoa] queryViewNamed:@"MostRecentActivityByGoal" keys:@[docId]];
    //[query setGroupLevel:1];
    [query setGroup:YES];
    if(query) {
        CouchQueryEnumerator *enumerator = [query rows];
        if(enumerator) {
            CouchQueryRow *row = [enumerator nextRow];
            if(row) {
                NSString *isoDate = [row value];
                if(isoDate && ![isoDate isKindOfClass:[NSNull class]]) {
                    _lastActivityDate = [RESTBody dateWithJSONObject:isoDate];
                    _validLastActivityDate = YES;
                }
            }
        }
    }
}
*/
     

@end
