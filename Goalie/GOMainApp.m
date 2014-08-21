//
//  GOMainApp.m
//  Goalie
//
//  Created by Stefan Kroon on 15-05-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOMainApp.h"

// Model
#import "GOGenericModelClasses.h"
#import "GOSleepState.h"
#import "GOSwitchTask.h"
#import "GOSleepTask.h"

// UI
#import "GOAbstractTaskVC.h"
#import "GOMasterViewController.h"
#import "GOActiveGoalTableVC.h"
#import "GOLoginViewController.h"

// Services
#import "GOLocationManager.h"
#import "GOTestFlight.h"
#import "GOGoalieServices.h"
#import "TimeWindow.h"
#import "GOKeychain.h"
#import "GOCouchCocoa.h"
#import "GOReachabilityManager.h"
#import "GOSensePlatform.h"
#import "GOTestFlight.h"
#import "GOTranslation.h"

@implementation GOMainApp {
    NSDateFormatter *_genericDateFormatter;
    GOReachabilityManager *_reachabilityManager;
    GOKeychain *_keychain;
    bool _isTesting;
}


+ (GOMainApp *)sharedMainApp {
    static GOMainApp *sharedMainApp = nil;
    if(sharedMainApp == nil) {
        sharedMainApp = [[GOMainApp alloc] init];
    }
    return sharedMainApp;
}

- (void)restart {
    [self.locationService programMonitorRegions];
    [self.goalieServices restart];
}

- (NSDateFormatter *)genericDateFormatter {
    if(!_genericDateFormatter) {
        _genericDateFormatter = [[NSDateFormatter alloc] init];
        [_genericDateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [_genericDateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [_genericDateFormatter setDoesRelativeDateFormatting:YES];
    }
    return _genericDateFormatter;
}

- (GOReachabilityManager *)reachabilityManager {
    if(!_reachabilityManager) {
        // Start Reachability
        _reachabilityManager = [[GOReachabilityManager alloc] init];
    }
    return _reachabilityManager;
}

- (GOKeychain *)keychain {
    if(!_keychain) {
        // Initialize the keychain
        _keychain = [[GOKeychain alloc] init];
    }
    return _keychain;
}

- (void)startGoalieServices {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    GOKeychain *keychain = self.keychain;
    if(!self.goalieServices && [keychain hasAutoLoginCredentials]) {
        TFLog(@"%s", __PRETTY_FUNCTION__);
        // Initialize the database
        GOGoalieServices *goServ = [[GOGoalieServices alloc] initUseLocalCouchDatabase:YES];
        NSString *username = keychain.username;
        NSString *password = keychain.password;
        [goServ loginWithUsername:username password:password handler:^(bool success, NSString *message) {
            TFLog(@"%s login with username %@ %@", __PRETTY_FUNCTION__, username, (success ? @"succeeded" : @"failed"));
            if(success) {
                //[self startUncompletedTasksObserving];
                [self willChangeValueForKey:kGOGoalieServices];
                _goalieServices = goServ;
                [self didChangeValueForKey:kGOGoalieServices];
                if(self.isTesting) {
                    [_goalieServices startDeadmanControl];
                }
            }
        }];
    }
}

- (bool)isTesting {
    return _isTesting;
}

- (void)setIsTesting:(bool)isTesting {
    if(_isTesting == isTesting)
        return;
    [self willChangeValueForKey:@"isTesting"];
    _isTesting = isTesting;
    [self didChangeValueForKey:@"isTesting"];
    if(_goalieServices) {
        if(isTesting)
            [_goalieServices startDeadmanControl];
        else
            [_goalieServices stopDeadmanControl];
    }
}

- (void)stopGoalieServices {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    GOGoalieServices *goServ = _goalieServices;
    if(goServ) {
        TFLog(@"%s", __PRETTY_FUNCTION__);
        [self willChangeValueForKey:kGOGoalieServices];
        _goalieServices = nil;
        [self didChangeValueForKey:kGOGoalieServices];
        [goServ stopDeadmanControl];
        [goServ logout];
    }
}

- (void)initialize:(void (^)(bool success))handler {
    // Save launch time
    _launchTime = [NSDate date];
    
    // Start the keychain
    [self keychain];
    
    // Configure TestFlight
    self.loadingText = @"Loading TestFligt";
    _testFlight = [[GOTestFlight alloc] init];
    
    _translation = [[GOTranslation alloc] init];
    
    // Configure Location Service
    _locationService = [[GOLocationManager alloc] init];
    
    // Initialize Sense Platfrom
    self.loadingText = @"Loading Sense Platform";
    _sensePlatform = [[GOSensePlatform alloc] init];
    self.loadingText = @"Finished loading Sense Platform";
    
    // Start observing
    [self startSensePlatformObserving];
    
    // GoalieServices start
    if([self.keychain hasAutoLoginCredentials]) {
        [self performSelector:@selector(startGoalieServices) withObject:nil afterDelay:0.5];
    }
    [self startKeychainObserving];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(handler)
            handler(YES);
    });
    
    
    
    // Configure Paige Connection - OLD
    //sharedMainApp.paigeConnection = [[PaigeConnection alloc] initWithUrl:@"http://server.ankr.nl/goalie"];
    //sharedMainApp.goalieServices = [[GOGoalieServices alloc] initWithPaigeConnection:sharedMainApp.paigeConnection];
    
    // Configure PHP Server - OLD
    //[self setServerURL:[NSURL URLWithString:@"http://server.ankr.nl/goalie/"]];
    
    // Configure Core Data - OLD
    //[self setModelURL:[[NSBundle mainBundle] URLForResource:@"Goalie" withExtension:@"momd"]];
    //[self setSqliteFilename:@"Goalie2.sqlite"];
    
}

/*
- (NSArray *)nextTriggerIntervalsForActiveGoal:(GOActiveGoal *)activeGoal {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    NSDate *now = [mainApp nowDate];
    NSMutableArray *timeIntervals = [[NSMutableArray alloc] initWithCapacity:5];
    NSDateComponents *addDay = [AbstractTimeWindow addComponentForCalendarUnit:NSDayCalendarUnit amount:1];
    NSDate *nextDate = [[GOMainApp currentCalendar] dateByAddingComponents:addDay toDate:now options:0];
    TimeWindow *comingDayWindow = [[TimeWindow alloc] initWithBeginDate:now endDate:nextDate];
    
    NSDate *curDate = now;
    for(int c = 0; c < 5; c++) {
        GOActiveTrigger *trigger = [activeGoal getNextActiveTriggerAfter:curDate];
        NSDate *pointInTime = [trigger pointInTime];
        if([comingDayWindow isDateInWindow:pointInTime]) {
            NSNumber *timeIntervalNumber = [NSNumber numberWithInteger:[pointInTime timeIntervalSince1970]];
            [timeIntervals addObject:timeIntervalNumber];
            curDate = pointInTime;
        }
        else {
            break;
        }
    }
    return timeIntervals;
}
 */

- (void)syncActiveGoals {
    [self.sensePlatform refreshActiveGoalsDictionaries];
}

- (void)setTimeOffsetInterval:(NSTimeInterval)timeOffsetInterval {
    _timeOffsetInterval = timeOffsetInterval;
    [self restart];
    
}

+ (NSCalendar *)currentCalendar {
    static NSCalendar *curCal = nil;
    if(!curCal) {
        curCal = [NSCalendar currentCalendar];
        [curCal setFirstWeekday:2];
    }
    return curCal;
}

+ (NSDateComponents *)subtractOneWeek {
    static NSDateComponents *dateComponents = nil;
    if(!dateComponents) {
        dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setWeek:-1];
    }
    return dateComponents;
}

+ (NSDate *)nextSunday {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    NSDate *referenceDate = [mainApp nowDate];
    NSCalendar *currentCal = [GOMainApp currentCalendar];
    NSDateComponents *todayComponents =
        [currentCal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSSecondCalendarUnit)
                      fromDate:referenceDate];
    [todayComponents setHour:23];
    [todayComponents setMinute:59];
    [todayComponents setSecond:59];
    NSInteger daysOffset = 8 - [todayComponents weekday];
    [todayComponents setWeekday:8];
    [todayComponents setDay:[todayComponents day] + daysOffset];
    
    NSDate *nextDate = [currentCal dateFromComponents:todayComponents];
    return nextDate;
}

+ (AbstractTimeWindow *)abstractNoonWindow {
    static AbstractTimeWindow *abstractNoonWindow = nil;
    if(!abstractNoonWindow)
        abstractNoonWindow = [[AbstractTimeWindow alloc] initWithBeginHour:12 minute:0 endHour:13 endMinute:0];
    return abstractNoonWindow;
}

+ (TimeWindow *)activeGoalTimeWindow {
    NSDateComponents *oneWeekBackComponents = [GOMainApp subtractOneWeek];
    NSDate *nextSunday = [GOMainApp nextSunday];
    NSDate *lastSunday = [[GOMainApp currentCalendar] dateByAddingComponents:oneWeekBackComponents toDate:nextSunday options:0];
    TimeWindow *timeWindow = [[TimeWindow alloc] initWithBeginDate:lastSunday endDate:nextSunday];
    return timeWindow;
}

- (void)willTerminate {
    [self.sensePlatform willTerminate];
    //[self.coreData willTerminate];
}

- (NSDate *)nowDate {
    return [[NSDate date] dateByAddingTimeInterval:_timeOffsetInterval];
}


#pragma mark User Interface

- (UIViewController *)presentedViewController {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UIViewController *viewController = [[window rootViewController] presentedViewController];
    return viewController;
}

- (void)presentLoginFailure:(NSString *)message {
    UIViewController *presentedVC = [self presentedViewController];
    UIStoryboard *storyboard = [presentedVC storyboard];
    GOLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    [loginVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    loginVC.loginMessage = message;
    [presentedVC presentViewController:loginVC animated:YES completion:^{
        ;
    }];
}

- (void)presentBrewAfterEvent:(GOTaskBrew *)brew {
    NSLog(@"%s Found brew %@", __PRETTY_FUNCTION__, brew);
    UIViewController *presentedVC = [self presentedViewController];
    if(![presentedVC isKindOfClass:[UINavigationController class]]) {
        NSLog(@"%s No navigation controller found.", __PRETTY_FUNCTION__);
        return;
    }
    
    UINavigationController *navigationController = (id)presentedVC;
    GOTask *task = [brew task];
    if(!task) {
        NSLog(@"%s Failed to find the task for the brew:%@", __PRETTY_FUNCTION__, [[brew document] documentID]);
        return;
    }
    
    NSString *taskName = [[brew task] taskName];
    UIStoryboard *storyboard = [navigationController storyboard];
    GOAbstractTaskVC *taskVC = [storyboard instantiateViewControllerWithIdentifier:taskName];
    [taskVC setBrew:brew];
    if(!taskVC) {
        NSLog(@"%s Can't find view controller for task with name %@", __PRETTY_FUNCTION__, taskName);
        return;
    }
    
    GOMasterViewController *masterVC;
    UIViewController *rootVC = [[navigationController viewControllers] objectAtIndex:0];
    if([rootVC isKindOfClass:[GOMasterViewController class]])
        masterVC = (id)rootVC;
    else
        masterVC = [storyboard instantiateViewControllerWithIdentifier:@"GoalieMain"];
    GOActiveGoalTableVC *activeGoalTableVC =
    [storyboard instantiateViewControllerWithIdentifier:@"ActiveGoalTable"];
    [activeGoalTableVC setActiveGoal:[brew activeGoal]];
    NSArray *vcs;
    if(![task isKindOfClass:[GOSwitchTask class]] && ![task isKindOfClass:[GOSleepTask class]])
        vcs = @[masterVC, activeGoalTableVC, taskVC];
    else
        vcs = @[masterVC, activeGoalTableVC];
    [navigationController setViewControllers:vcs animated:YES];
}

- (void)errorAlertMessage:(NSString *)errorMessage {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, errorMessage);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Foutmelding" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

/*
- (void)senseLoginWithUsername:(NSString *)username password:(NSString *)password handler:(void(^)(bool success, NSString *msg))handler {
    BOOL loginSenseSuccess = [self.sensePlatform loginWithUsername:username password:password];
    if(loginSenseSuccess) {
        handler(YES, @"Successful login at Common Sense");
    }
    else {
        NSLog(@"[GOGoalieServices loginWithUsername:password:handler:] Failed to login at Common Sense");
        handler(NO, @"Failed to login at Common Sense");
    }
}
*/

- (void)logout {
    [self.locationService eraseAllMonitorRegions];
    [self.sensePlatform logout];
    [self.keychain deletePassword];
    [self stopGoalieServices];
}

#pragma mark Observing

- (void)startSensePlatformObserving {
    GOSensePlatform *sensePlatform = self.sensePlatform;
    [sensePlatform addObserver:self forKeyPath:kGOTimeActive options:0 context:nil];
    [sensePlatform addObserver:self forKeyPath:kGOSleepState options:0 context:nil];
    [sensePlatform addObserver:self forKeyPath:kGOActiveGoalsDictionaries options:0 context:nil];
}

- (void)cancelSensePlatformObserving {
    GOSensePlatform *sensePlatform = self.sensePlatform;
    [sensePlatform removeObserver:self forKeyPath:kGOTimeActive];
    [sensePlatform removeObserver:self forKeyPath:kGOSleepState];
    [sensePlatform removeObserver:self forKeyPath:kGOActiveGoalsDictionaries];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //NSLog(@"%s observed %@", __PRETTY_FUNCTION__, keyPath);
    GOSensePlatform *sensePlatform = self.sensePlatform;
    GOGoalieServices *goalieServices = self.goalieServices;
    GOKeychain *keychain = self.keychain;
    if(object == goalieServices) {
        //NSUInteger nofUncompleted = [goalieServices totalNofUncompletedTasks];
    }
    else if(object == sensePlatform) {
        if([keyPath isEqualToString:kGOTimeActive]) {
            NSTimeInterval timeActive = [sensePlatform timeActive];
            TFLog(@"-[GOMainApp] TimeActive:%f", timeActive);
            [goalieServices processTimeActiveInterval:timeActive];
        }
        else if([keyPath isEqualToString:kGOSleepState]) {
            GOSleepState *sleepState = [sensePlatform sleepState];
            TFLog(@"-[GOMainApp] SleepState start:%f end:%f hours:%d",
                  [[sleepState startDate] timeIntervalSince1970], [[sleepState endDate] timeIntervalSince1970], [sleepState hours]);
            [goalieServices processSleepState:sleepState];
        }
        else if([keyPath isEqualToString:kGOActiveGoalsDictionaries ]) {
            NSArray *activeGoalsDictionaries = [sensePlatform activeGoalsDictionaries];
            TFLog(@"-[GOMainApp] NofActiveGoals:%d", [activeGoalsDictionaries count]);
            [self.goalieServices processNewActiveGoalsDictionaries:[sensePlatform activeGoalsDictionaries]];
            
            [self restart];
        }
    }
    else if(object == keychain) {
        if(![keychain hasAutoLoginCredentials]) {
            if(self.goalieServices)
                [self stopGoalieServices];
        }
        else {
            if(!self.goalieServices) {
                [self startGoalieServices];
            }
            else {
                if([keyPath isEqualToString:@"username"]) {
                    [self stopGoalieServices];
                    [self performSelector:@selector(startGoalieServices) withObject:nil afterDelay:1.0];
                }
            }
        }
    }
}

- (void)startKeychainObserving {
    [self.keychain addObserver:self forKeyPath:kGOKeychainUsername options:0 context:nil];
    [self.keychain addObserver:self forKeyPath:kGOKeychainPassword options:0 context:nil];
}

- (void)cancelKeychainObserving {
    [self.keychain removeObserver:self forKeyPath:kGOKeychainUsername];
    [self.keychain removeObserver:self forKeyPath:kGOKeychainPassword];
}

- (void)startUncompletedTasksObserving {
    [self.goalieServices addObserver:self forKeyPath:@"activeGoalsQuery.rows" options:0 context:nil];
    
}

- (void)cancelUncompletedTasksObserving {
    [self.goalieServices removeObserver:self forKeyPath:@"activeGoalsQuery.rows"];
}

- (void)dealloc {
    [self cancelSensePlatformObserving];
    [self cancelKeychainObserving];
}



@end
