//
//  GOTestFlight.h
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOTestFlight : NSObject

- (int)residentMemoryInKb;
- (double)totalCpuTime;
    
+ (void)outputObjectDescription:(NSObject *)obj;
    
@end
