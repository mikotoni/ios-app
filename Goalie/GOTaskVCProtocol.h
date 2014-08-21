//
//  GOTaskVCProtocol.h
//  Goalie
//
//  Created by Stefan Kroon on 5/16/13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  GOTaskBrew, GOActiveTask;

@protocol GOTaskVCProtocol <NSObject>

//- (void)prepareForEditTask;
//- (void)prepareForExecuteTask;

@required
@property BOOL editMode;
@property GOTaskBrew *brew;
@property GOActiveTask *activeTask;

@end
