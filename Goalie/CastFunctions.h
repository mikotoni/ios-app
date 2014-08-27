//
//  CastFunctions.h
//  Goalie
//
//  Created by Stefan Kroon on 29-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>

void MyWarn(NSString* format, ...) __attribute__((format(__NSString__, 1, 2)));;

#define Warn MyWarn

#define $castIf(CLASSNAME,OBJ)      ((CLASSNAME*)(MyCastIf([CLASSNAME class],(OBJ))))

id MyCastIf(Class,id);
