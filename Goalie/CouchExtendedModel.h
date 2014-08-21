//
//  CouchExtendedModel.h
//  Goalie
//
//  Created by Stefan Kroon on 26-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <CouchCocoa/CouchCocoa.h>

@interface CouchExtendedModel : CouchModel

- (void)didDeleteDocument:(CouchDocument *)document;
    
@end
