//
//  GOAbstractTaskVC.h
//  Goalie
//
//  Created by Stefan Kroon on 23-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GOTaskVCProtocol.h"

@class GOTask, GOActiveTask;

@interface GOAbstractTaskVC : UIViewController {
    GOTaskBrew *_brew;
}

@property BOOL editMode;
@property GOTaskBrew *brew;
@property GOActiveTask *activeTask;

- (IBAction)donePressed:(id)sender;
- (void)addNewTask:(GOTask *)newTask;
- (void)navigateBack;
- (void)saveNewTask;
- (void)completeTask;
//- (NSManagedObjectContext *)managedObjectContext;
    
@end
