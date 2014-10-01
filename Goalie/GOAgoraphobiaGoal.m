//
//  GOAgoraphobiaGoal.m
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOAgoraphobiaGoal.h"

// Model
#import "GOGenericModelClasses.h"
#import "GOSwitchTask.h"
#import "GOVisitTask.h"
#import "GOShootPhotoTask.h"
#import "GOSliderTask.h"

// Services
#import "GOMainApp.h"
#import "GOGoalieServices.h"
#import "GOTestFlight.h"
#import "GOTranslation.h"

// Misc
#import "CastFunctions.h"

@implementation GOAgoraphobiaGoal

@dynamic exercise_lat, exercise_lon, location_label;

- (UIColor*)colorProgress{
    return UIColorFromRGB(0x2abaff);
}
- (int)loadingHeight{
    return 104;
}
- (NSString *)progressSensorName {
    return @"agoraphobia_progress";
}

/*
- (void)setExecise_lon:(NSNumber *)exercise_lon {
    self.exercise_lon = exercise_lon;
}

- (void)setExercise_lat:(NSNumber *)exercise_lat {
    self.exercise_lat = exercise_lat;
}
 */

- (void)startExercise:(GOTaskBrew *)switchBrew {
    GOActiveSwitchTask *activeSwitchTask = $castIf(GOActiveSwitchTask, [switchBrew activeTask]);
    [activeSwitchTask updateWithBrew:switchBrew setState:YES];
}

- (void)stopExercise:(GOTaskBrew *)switchBrew {
    GOActiveSwitchTask *activeSwitchTask = $castIf(GOActiveSwitchTask, [switchBrew activeTask]);
    NSUInteger oldEarnedPoints = [[switchBrew earnedPoints] integerValue];
    NSUInteger addPoints = 0;
    if(oldEarnedPoints < 100) {
        addPoints = 50;
        if(oldEarnedPoints > 50)
            addPoints = 100 - oldEarnedPoints;
        NSUInteger newEarnedPoints = oldEarnedPoints + addPoints;
        [switchBrew setEarnedPoints:[NSNumber numberWithInteger:newEarnedPoints]];
     }
    [activeSwitchTask updateWithBrew:switchBrew setState:NO];
    [switchBrew save];
    NSString *msg = @"Je hebt de oefening helemaal afgerond. Goed gedaan.";
    if(addPoints > 0)
        msg = [msg stringByAppendingFormat:@" Je verdient hiermee %d punten.", addPoints];
    [[[GOMainApp sharedMainApp] goalieServices] deliverLocalNotificationForBrew:switchBrew title:@"Gefeliciteerd" body:msg];
}

- (void)startAnxietyNotifications:(GOTaskBrew *)sliderBrew {
    GOSliderTask *sliderTask = $castIf(GOSliderTask, [sliderBrew task]);
    if(!sliderTask)
        NSLog(@"WARNING: %s Not a slider task", __PRETTY_FUNCTION__);
    else {
        [sliderTask setTriggerInterval:60.0*5];
        [sliderBrew dirtTriggers];
    }
}

- (void)stopAnxietyNotifications:(GOTaskBrew *)sliderBrew {
    GOSliderTask *sliderTask = $castIf(GOSliderTask, [sliderBrew task]);
    if(!sliderTask)
        NSLog(@"WARNING: %s Not a slider task", __PRETTY_FUNCTION__);
    else {
        [sliderTask setTriggerInterval:0.0];
        [sliderBrew dirtTriggers];
    }
}

- (void)notifyGoodBusyLocation:(GOTaskBrew *)brew {
//    [TestFlight passCheckpoint:@"[GOAgoraphobiaGoal notifyGoodBusy]"];
    [[[GOMainApp sharedMainApp] goalieServices] deliverLocalNotificationForBrew:brew title:@"Gearriveerd" body:@"Heel goed. U bent aangekomen op de afgesproken locatie."];
}

- (void)notifyGoodBusyAnxiety:(GOTaskBrew *)brew {
//    [TestFlight passCheckpoint:@"[GOAgoraphobiaGoal notifyGoodBusyAnxiety]"];
    [[[GOMainApp sharedMainApp] goalieServices] deliverLocalNotificationForBrew:brew title:@"Spanning ingevuld" body:@"Ga verder op weg naar de afgesproken locatie."];
}

- (void)notifyQuestionStartExercise:(GOTaskBrew *)brew {
//    [TestFlight passCheckpoint:@"[GOAgoraphobiaGoal notifyQuestionStartExercise]"];
    [[[GOMainApp sharedMainApp] goalieServices] deliverLocalNotificationForBrew:brew title:@"Oefening starten?" body:@"U bent aangekomen op de locatie voor een oefening. U kunt nu de oefening starten."];
}

- (void)notifyGoBack:(GOTaskBrew *)brew {
//    [TestFlight passCheckpoint:@"[GOAgoraphobiaGoal notifyGoBack]"];
    [[[GOMainApp sharedMainApp] goalieServices] deliverLocalNotificationForBrew:brew title:@"Locatie verlaten" body:@"U heeft de locatie verlaten. Ga terug om verder te gaan met de oefening."];
}

- (void)maybeTooBusyForExercise {
//    [TestFlight passCheckpoint:@"[GOAgoraphobiaGoal maybeTooBusyForExercise]"];
}

- (void)shouldNotHappen {
//    [TestFlight passCheckpoint:@"[GOAgoraphobiaGoal shouldNotHappen]"];
}

- (void)waitForAnxietyLog {
//    [TestFlight passCheckpoint:@"[GOAgoraphobiaGoal waitForAnxietyLog]"];
}

- (void)notifyInvalidLocation:(GOTaskBrew *)brew {
//    [TestFlight passCheckpoint:@"[GOAgoraphobiaGoal notifyInvalidLocation]"];
    [[[GOMainApp sharedMainApp] goalieServices] deliverLocalNotificationForBrew:brew title:@"Locatie onjuist" body:@"Voor deze oefening moet u een foto maken op de afgesproken locatie."];
}

- (void)waitForPhoto {
//    [TestFlight passCheckpoint:@"[GOAgoraphobiaGoal waitForPhoto]"];
}

- (void)waitForReachingLocation {
//    [TestFlight passCheckpoint:@"[GOAgoraphobiaGoal waitForReachingLocation]"];
}


- (void)didUpdateBrew:(GOTaskBrew *)updateBrew {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    NSDate *curDate = [mainApp nowDate];
    NSTimeInterval exerciseDuration = 60.0*60.0 * 3;
    
    GOTaskBrew * __block switchBrew = nil;
    GOTaskBrew * __block visitBrew = nil;
    GOTaskBrew * __block sliderBrew = nil;
    GOTaskBrew * __block photoBrew = nil;
    
    NSArray *brews = [[mainApp goalieServices] brewsByActiveGoal:self forDate:[mainApp nowDate]];
    [brews enumerateObjectsUsingBlock:^(GOTaskBrew *testBrew, NSUInteger idx, BOOL *stop) {
        GOTask *task = testBrew.task;
        if([task isKindOfClass:[GOSwitchTask class]])
            switchBrew = testBrew;
        else if([task isKindOfClass:[GOSliderTask class]])
            sliderBrew = testBrew;
        else if([task isKindOfClass:[GOVisitTask class]])
            visitBrew = testBrew;
        else if([task isKindOfClass:[GOShootPhotoTask class]])
            photoBrew = testBrew;
    }];
    
    if(!switchBrew || !visitBrew || !sliderBrew || !photoBrew) {
        NSLog(@"WARNING: %s Not all brews found.", __PRETTY_FUNCTION__);
        return;
    }
    
    bool switchState = [[switchBrew valueForKey:kGOSwitchState] boolValue];
    NSDate *lastPhotoDate = [photoBrew completionDate];
    NSTimeInterval photoTimeInterval = [curDate timeIntervalSinceDate:lastPhotoDate];
    bool hasPhoto = photoTimeInterval < exerciseDuration && photoTimeInterval > 0;
    NSDate *lastAnxietyDate = [sliderBrew completionDate];
    NSTimeInterval anxietyTimeInterval = [curDate timeIntervalSinceDate:lastAnxietyDate];
    bool hasAnxiety = anxietyTimeInterval < exerciseDuration && anxietyTimeInterval > 0;
    bool isOnLocation = [[visitBrew valueForKey:kGOVisitState] boolValue];
    
    NSLog(@"%s Agoraphobia state [exercise:%@ photo:%@ anxiety:%@ location:%@]", __PRETTY_FUNCTION__,
          switchState ? @"YES" : @"NO",
          hasPhoto ? @"YES" : @"NO",
          hasAnxiety ? @"YES" : @"NO",
          isOnLocation ? @"YES" : @"NO");
    
    if(updateBrew == switchBrew) {
        if(switchState == YES)
            [self startAnxietyNotifications:sliderBrew];
        else
            [self stopAnxietyNotifications:sliderBrew];
        [sliderBrew resetCompletionDate];
        [sliderBrew save];
        [photoBrew resetCompletionDate];
        [photoBrew save];
    }
    else if(updateBrew == visitBrew) {
        if(isOnLocation) {
            if(switchState == NO)
                [self notifyQuestionStartExercise:switchBrew];
            else
                [self notifyGoodBusyLocation:visitBrew];
        }
        else {
            if(switchState == NO)
                [self maybeTooBusyForExercise];
            else {
                if(hasAnxiety == YES && hasPhoto == YES)
                    [self shouldNotHappen];
                else
                    [self notifyGoBack:visitBrew];
            }
        }
    }
    else if(updateBrew == sliderBrew) {
        if(switchState == NO) {
            if(isOnLocation == YES) {
                [self startExercise:switchBrew];
                [self startAnxietyNotifications:sliderBrew];
            }
            else
                [self waitForReachingLocation];
        }
        else {
            if(isOnLocation == YES) {
                if(hasPhoto == YES) {
                    [self stopAnxietyNotifications:sliderBrew];
                    [self stopExercise:switchBrew];
                }
                else
                    [self waitForPhoto];
            }
            else
                [self notifyGoodBusyAnxiety:switchBrew];
        }
    }
    else if(updateBrew == photoBrew) {
        if(switchState == NO) {
            if(isOnLocation == YES) {
                [self startExercise:switchBrew];
                [self startAnxietyNotifications:sliderBrew];
            }
            else
                [self waitForReachingLocation];
        }
        else {
            if(isOnLocation == YES) {
                if(hasAnxiety == YES) {
                    [self stopAnxietyNotifications:sliderBrew];
                    [self stopExercise:switchBrew];
                }
                else
                    [self waitForAnxietyLog];
            }
            else
                [self notifyInvalidLocation:visitBrew];
        }
    }
    else {
        NSLog(@"WARNING: %s Unknown kind of brew update", __PRETTY_FUNCTION__);
    }
}

- (void)configureActiveTask:(GOActiveTask *)activeTask {
    GOActiveVisitTask *activeVisitTask = $castIf(GOActiveVisitTask, activeTask);
    if(activeVisitTask) {
        [activeVisitTask setLocationName:self.location_label];
        CLLocationDegrees latitudeDegrees = [self.exercise_lat doubleValue];
        CLLocationDegrees longitudeDegrees = [self.exercise_lon doubleValue];
        CLLocationCoordinate2D visitLocationCoordinate = CLLocationCoordinate2DMake(latitudeDegrees, longitudeDegrees);
        [activeVisitTask setVisitLocationCoordinate:visitLocationCoordinate];
    }
}

- (NSString *)description {
    return [[[GOMainApp sharedMainApp] translation] translate:@"goal_agoraphobia" string:@"goal_descr_agoraphobia"];
}

- (NSString *)explanation {
    return [[[GOMainApp sharedMainApp] translation] translate:@"goal_agoraphobia" string:@"goal_help_agoraphobia"];
}

- (NSString *)title {
    GOTranslation *translation = [[GOMainApp sharedMainApp] translation];
    return [translation translate:@"goal_agoraphobia" string:@"goal_title_agoraphobia"];
}


@end
