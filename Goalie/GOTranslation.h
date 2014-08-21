//
//  GOTranslation.h
//  Goalie
//
//  Created by Stefan Kroon on 05-09-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOTranslation : NSObject <NSXMLParserDelegate>

- (NSString *)translate:(NSString *)module string:(NSString *)key;

@end
