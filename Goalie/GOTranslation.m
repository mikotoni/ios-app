//
//  GOTranslation.m
//  Goalie
//
//  Created by Stefan Kroon on 05-09-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOTranslation.h"

@implementation GOTranslation {
    NSString *languageCode;
    NSMutableDictionary *modules;
    NSMutableDictionary *parsingDict;
    NSString *parsingName;
    NSString *parsingText;
}

- (id)init {
    self = [super init];
    if(self) {
        modules = [[NSMutableDictionary alloc] init];
        NSArray *availableLanguages = @[@"nl", @"en"];
        NSArray *preferredLanguages = [NSLocale preferredLanguages];
        [preferredLanguages enumerateObjectsUsingBlock:^(NSString *prefLang, NSUInteger idx, BOOL *stop) {
            if([availableLanguages containsObject:prefLang]) {
                languageCode = prefLang;
                *stop = YES;
            }
        }];
        if(!languageCode)
            languageCode = @"nl";
    }
    return self;
}


- (NSString *)translate:(NSString *)module string:(NSString *)key {
    parsingDict = [modules valueForKey:module];
    if(!parsingDict) {
        parsingDict = [[NSMutableDictionary alloc] init];
        NSString *directory = [NSString stringWithFormat:@"values-%@", languageCode];
        NSString *filename = [NSString stringWithFormat:@"strings_%@", module];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"xml" inDirectory:directory];
        if(filePath) {
            NSURL *url = [NSURL fileURLWithPath:filePath];
            NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
            [parser setDelegate:self];
            [parser parse];
        }
        [modules setObject:parsingDict forKey:module];
    }
    
    return [parsingDict valueForKey:key];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if([elementName isEqualToString:@"string"] ) {
        parsingName = [attributeDict valueForKey:@"name"];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if(parsingName) {
        parsingText = [parsingText stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        parsingText = [parsingText stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
        [parsingDict setValue:parsingText forKey:parsingName];
        parsingName = nil;
        parsingText = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if(parsingName) {
        if(!parsingText)
            parsingText = string;
        else
            parsingText = [parsingText stringByAppendingString:string];
    }
}

@end
