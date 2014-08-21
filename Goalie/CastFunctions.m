//
//  CastFunctions.m
//  Goalie
//
//  Created by Stefan Kroon on 29-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "CastFunctions.h"

#define kWarningPrefix @"WARNING:: "

BOOL gMyWarnRaisesException = NO;

void MyWarn( NSString *msg, ... )
{
    va_list args;
    va_start(args,msg);
    NSLogv([kWarningPrefix stringByAppendingString: msg], args);
    va_end(args);
    
    if (gMyWarnRaisesException) {
        va_start(args,msg);
        [NSException raise: @"RESTWarning"
                    format: msg
                 arguments: args];
    }
}

id MyCastIf( Class requiredClass, id object )
{
    if( object && ! [object isKindOfClass: requiredClass] ) {
        //Warn(@"$castIf: Expected %@, got %@ %@", requiredClass, [object class], object);
        object = nil;
    }
    return object;
}

