//
//  OpenQuestionTask.h
//  Goalie
//
//  Created by Stefan Kroon on 03-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOTask.h"

@interface GOOpenQuestionTask : GOTask

#ifdef USE_COREDATA
+ (GOOpenQuestionTask *)openQuestionTaskInManagedObjectContext:(NSManagedObjectContext *)context;
#endif

@property (nonatomic, retain) NSString * question;
//@property (nonatomic, retain) NSString * answer;

@end
