//
//  CouchExtendedModel.m
//  Goalie
//
//  Created by Stefan Kroon on 26-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "CouchExtendedModel.h"

#import <CouchCocoa/CouchCocoa.h>

static NSString * const kCouchModelIsDeleted = @"isDeleted";

@implementation CouchExtendedModel {
    CouchDocument *observedDocument;
}

- (void)didDeleteDocument:(CouchDocument *)document {
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(object == observedDocument && [keyPath isEqualToString:kCouchModelIsDeleted]) {
        [self didDeleteDocument:observedDocument];
    }
}

- (void)didLoadFromDocument {
    CouchDocument *newDocument = self.document;
    if(newDocument != observedDocument) {
        if(observedDocument)
            [observedDocument removeObserver:self forKeyPath:kCouchModelIsDeleted];
        if(newDocument)
            [newDocument addObserver:self forKeyPath:kCouchModelIsDeleted options:0 context:nil];
        observedDocument = newDocument;
    }
}

- (void)setDatabase:(CouchDatabase *)database {
    [super setDatabase:database];
    CouchDocument *newDocument = self.document;
    if(newDocument != observedDocument) {
        if(observedDocument)
            [observedDocument removeObserver:self forKeyPath:kCouchModelIsDeleted];
        if(newDocument)
            [newDocument addObserver:self forKeyPath:kCouchModelIsDeleted options:0 context:nil];
        observedDocument = newDocument;
    }
}

- (void)dealloc {
    if(observedDocument) {
        [observedDocument removeObserver:self forKeyPath:kCouchModelIsDeleted];
        observedDocument = nil;
    }
}

@end
