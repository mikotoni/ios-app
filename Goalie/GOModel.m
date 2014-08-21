//
//  GOModel.m
//  Goalie
//
//  Created by Stefan Kroon on 02-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOModel.h"
#import "GOModelClasses.h"
#import <CouchCocoa/CouchModelFactory.h>

@implementation GOModel

/*
 + (GOModel *)modelForDocument:(CouchDocument *)document {
    id modelObject = [super modelForDocument:document];
    if(modelObject)
        [modelObject awakeFromFetch];
    GOModel *modelObject = [document modelObject];
    if(modelObject)
        return modelObject;
    
    CouchModelFactory *factory = [CouchModelFactory sharedInstance];
    modelObject = [factory modelForDocument:document];
    if(!modelObject) {
        NSLog(@"Failed to transform document %@ to a modelObject.", [document documentID]);
        return nil;
    }
    [modelObject awakeFromFetch];
    document.modelObject = modelObject;
    return modelObject;
}
*/

+ (BOOL)registerCouchModelClasses {
    CouchModelFactory *factory = (id)[CouchModelFactory sharedInstance];
    [factory registerClass:[GOGoal class] forDocumentType:@"Goal"];
    [factory registerClass:[GOTask class] forDocumentType:@"Task"];
    [factory registerClass:[GOExerciseStateSensor class] forDocumentType:@"ExerciseStateSensor"];
    [factory registerClass:[GOSliderTask class] forDocumentType:@"SliderTask"];
    [factory registerClass:[GOShootPhotoTask class] forDocumentType:@"ShootPhotoTask"];
    [factory registerClass:[GOSwitchTask class] forDocumentType:@"SwitchTask"];
    [factory registerClass:[GOMealTask class] forDocumentType:@"MealTask"];
    [factory registerClass:[GODescriptiveTask class] forDocumentType:@"DescriptiveTask"];
    [factory registerClass:[GOMoodTask class] forDocumentType:@"MoodTask"];
    return YES;
}

// Method to override
- (void)awakeFromFetch {
    
}

@end
