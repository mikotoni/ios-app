//
//  OpenQuestionTask.m
//  Goalie
//
//  Created by Stefan Kroon on 03-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOOpenQuestionTask.h"


@implementation GOOpenQuestionTask

#ifdef USE_COREDATA
+ (GOOpenQuestionTask *)openQuestionTaskInManagedObjectContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:@"OpenQuestionTask" inManagedObjectContext:context];
}
#endif

@dynamic question;
//@dynamic answer;

@end
