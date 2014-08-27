//
//  GOSensePlatform.m
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOSensePlatform.h"

// Model
#import "GOSleepState.h"

// Services
#import "GOMainApp.h"
#import "GOReachabilityManager.h"
#import "GOKeychain.h"

// Sense Cortex
#import<Cortex/CSSensePlatform.h>
#import <Cortex/CSSettings.h>
#import <Cortex/TimeActiveModule.h>
#import <Cortex/SleepTimeModule.h>

// Hardcode Settings
static NSTimeInterval initialLoginDelay = 5.0;
static NSTimeInterval repeatedLoginDelay = 5.0;
static NSUInteger nofLoginAttempts = 3;
static NSString *uploadIntervalSeconds = @"3600";
static NSUInteger activityPollIntervalSeconds = 60;

@interface GOSensePlatform()

@property (nonatomic, readwrite) NSArray *activeGoalsDictionaries;
@property (nonatomic, readwrite) GOSleepState *sleepState;
@property (atomic, readwrite) NSString *loggedInUsername;

@property (atomic, readwrite) NSUInteger nofLoginAttempts;
@property (atomic, readwrite) NSDate *lastFailedLogin;
@property (nonatomic, readwrite) bool isLoadingActiveGoals;

@end

@implementation GOSensePlatform {
    TimeActiveModule *_timeActiveSensor;
    SleepTimeModule *_sleepTimeSensor;
    bool _isConnected;
}

- (id)init {
    self = [super init];
    if(self) {
        [CSSensePlatform initialize];
        _timeActiveSensor = [[TimeActiveModule alloc] init];
        _sleepTimeSensor = [[SleepTimeModule alloc] init];
        [_sleepTimeSensor setOnlyUseAccelerometer:YES];

        _nofLoginAttempts = 0;
        _isConnected = NO;
        
        // Subscribe to sensor data
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewData:) name:kCSNewSensorDataNotification object:nil];
        [self startOnlineObserving];
    }
    return self;
}

- (bool)isConnected {
    @synchronized (self) {
        return _isConnected;
    }
    
}

- (void)setIsConnected:(bool)isCon {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self willChangeValueForKey:kGOIsConnected];
        @synchronized (self) {
            _isConnected = isCon;
        }
        [self didChangeValueForKey:kGOIsConnected];
    });
}

- (void)scheduleLoginAttemptAfterDelay:(float)delay {
    NSLog(@"%s Attempt to login after %f seconds", __PRETTY_FUNCTION__, delay);
    [self performSelector:@selector(scheduledLoginAttempt) withObject:nil afterDelay:delay];
}

- (void)scheduledLoginAttempt {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    
    // Check everything
    GOKeychain *keychain = [mainApp keychain];
    if(![keychain hasAutoLoginCredentials]) {
        NSLog(@"%s Don't have auto login credentials, so stay offline", __PRETTY_FUNCTION__);
        return;
    }
    
    GOReachabilityManager *reachabilityManager = [mainApp reachabilityManager];
    if(![reachabilityManager isOnline]) {
        NSLog(@"%s No longer online, so don't try to login", __PRETTY_FUNCTION__);
        return;
    }

    [self asyncLoginWithUsername:[keychain username] password:[keychain password]];
}

- (void)didComeOnline {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if(self.loggedInUsername) {
        self.isConnected = YES;
        NSLog(@"%s Already have a loggedInUsername", __PRETTY_FUNCTION__);
        return;
    }
    
    GOKeychain *keychain = [mainApp keychain];
    if(![keychain hasAutoLoginCredentials]) {
        self.isConnected = NO;
        NSLog(@"%s Don't have auto login credentials, so stay offline", __PRETTY_FUNCTION__);
        return;
    }

    [self scheduleLoginAttemptAfterDelay:initialLoginDelay];
}

- (void)asyncLoginFailed {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    if(self.nofLoginAttempts >= nofLoginAttempts)
        [mainApp presentLoginFailure:@"Het online inloggen mislukt steeds. Voer opnieuw uw gegevens in."];
    else
        [self scheduleLoginAttemptAfterDelay:repeatedLoginDelay];
}

- (void)asyncLoginSucceeded {
}

- (void)didWentOffline {
    self.lastFailedLogin = nil;
    self.nofLoginAttempts = 0;
    self.isConnected = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:kGOIsOnline]) {
        NSNumber *oldStatusNumber = [change valueForKey:NSKeyValueChangeOldKey];
        NSNumber *newStatusNumber = [change valueForKey:NSKeyValueChangeNewKey];
        NSLog(@"%s Online status changed from %@ to %@", __PRETTY_FUNCTION__, oldStatusNumber, newStatusNumber);
        bool oldStatus = [oldStatusNumber boolValue];
        bool newStatus = [newStatusNumber boolValue];
        if(oldStatus == NO && newStatus == YES)
            [self didComeOnline];
        else if(oldStatus == YES&& newStatus == NO)
            [self didWentOffline];
        
    }
}

- (void)startOnlineObserving {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew;
    [[[GOMainApp sharedMainApp] reachabilityManager] addObserver:self forKeyPath:kGOIsOnline options:options context:nil];
}

- (void)cancelOnlineObserving {
    [[[GOMainApp sharedMainApp] reachabilityManager] removeObserver:self forKeyPath:kGOIsOnline];
}

- (void)dealloc {
    [self cancelOnlineObserving];
}

- (void)updateActiveGoalProgress:(NSNumber *)points sensorName:(NSString *)sensorName {
    [CSSensePlatform addDataPointForSensor:sensorName
                               displayName:nil
                               description:@"goal progress"
                               deviceType:nil
                               deviceUUID:nil
                               dataType:kCSDATA_TYPE_INTEGER
                               stringValue:[points stringValue] timestamp:[[GOMainApp sharedMainApp] nowDate]];
    [CSSensePlatform flushData];
}

- (void)setSettings {
    CSSettings* settings = [CSSettings sharedSettings];
    
    //Use this to enable/disable the whole sense platform
    [settings setSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingSenseEnabled value:kCSSettingYES];
    
    // Set upload interval (in seconds)
    [settings setSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingUploadInterval value:uploadIntervalSeconds];
    
    // Enabling sensors
    // Set location accuracy
    [settings setSensor:kCSSENSOR_LOCATION enabled:YES];
    [settings setSettingType:kCSSettingTypeLocation setting:kCSLocationSettingAccuracy value:@"10000"];
    
    // Set noise sensor
    [settings setSensor:kCSSENSOR_NOISE enabled:NO];
    // Set ambience sensors sample rate (in seconds)
    //[settings setSettingType:kCSSettingTypeAmbience setting:kCSAmbienceSettingInterval value:@"300"];
    
    // Enable the accelerometer
    [settings setSensor:kCSSENSOR_ACCELEROMETER enabled:YES];
    [settings setSensor:kCSSENSOR_ACCELERATION enabled:YES];
    
    [settings setSensor:kCSSENSOR_BATTERY enabled:YES];
    
    
    [self useDefaultSpatialSettingInterval];
    
    // Not necessay
    //[settings setSensor:kCSSENSOR_BATTERY enabled:YES];
    
    /*
    NSArray *availableSensors = [CSSensePlatform availableSensors];
    [availableSensors enumerateObjectsUsingBlock:^(CSSensor *sensor, NSUInteger idx, BOOL *stop) {
        NSLog(@"Sensor %@ isEnabled:%d", [sensor name], [sensor isEnabled]);
        [settings setSensor:sensor.name enabled:NO];
    }];
     */
    
}

- (BOOL)loginWithUsername:(NSString *)username password:(NSString *)password {
    NSLog(@"Logging in with %@:*****", username);
    BOOL success = [CSSensePlatform loginWithUser:username andPassword:password];
    if(success) {
        self.loggedInUsername = username;
        self.lastFailedLogin = nil;
        self.nofLoginAttempts = 0;
        self.isConnected = YES;
        [self setSettings];
        NSLog(@"%s Successful login with username %@", __PRETTY_FUNCTION__, username);
        return YES;
    }
    else {
        self.lastFailedLogin = [NSDate date];
        self.nofLoginAttempts++;
        self.loggedInUsername = nil;
        self.isConnected = NO;
        NSLog(@"%s Failed to login with username %@", __PRETTY_FUNCTION__, username);
        return NO;
    }
}

- (void)asyncLoginWithUsername:(NSString *)username password:(NSString *)password {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(globalQueue, ^{
        bool success = [self loginWithUsername:username password:password];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!success)
                [self asyncLoginFailed];
            else
                [self asyncLoginSucceeded];
        });
        
        [self refreshActiveGoalsDictionaries];
    });
}

- (void)resetTimeActiveSensor {
    [_timeActiveSensor reset];
}

- (void)logout {
    self.loggedInUsername = nil;
    self.isConnected = NO;
    CSSettings* settings = [CSSettings sharedSettings];
    //Use this to enable/disable the whole sense platform
    [settings setSettingType:kCSSettingTypeGeneral setting:kCSGeneralSettingSenseEnabled value:kCSSettingNO];
    [CSSensePlatform logout];
}

- (void)willTerminate {
    [CSSensePlatform willTerminate];
}

- (void)refreshActiveGoalsDictionaries {
    self.isLoadingActiveGoals = YES;
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        NSArray *dataPoints = [CSSensePlatform getDataForSensor:@"active_goals" onlyFromDevice:NO nrLastPoints:1];
        if([dataPoints count] >= 1) {
            NSDictionary *dataPoint = [dataPoints objectAtIndex:0];
            NSString *jsonString = [dataPoint valueForKey:@"value"];
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSArray *goalsArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            if(!goalsArray) {
                NSLog(@"Failed to decode json: %@", jsonString);
                //self.activeGoals = [NSArray array];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.activeGoalsDictionaries = goalsArray;
                    self.isLoadingActiveGoals = NO;
                });
            }
        }
    });
}

- (void)refreshSleepState {
    //first make sure all data is uploaded, as getData will request uploaded data
    [CSSensePlatform flushDataAndBlock];

    NSArray *dataPoints = [CSSensePlatform getDataForSensor:[_sleepTimeSensor name] onlyFromDevice:NO nrLastPoints:1];
    NSUInteger nofDataPoints = [dataPoints count];
    if(nofDataPoints < 1) {
        NSLog(@"WARNING: %s Failed to retrieve sleep_time from Common Sense (nofDataPoints: %d)", __PRETTY_FUNCTION__, nofDataPoints);
        return ;
    }
    
    NSDictionary *dataPoint = [dataPoints objectAtIndex:0];
    NSString *jsonString = [dataPoint valueForKey:@"value"];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *sleepTimeDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    //sleepTimeDict = @{ @"start_date": @1386882000, @"end_date": @1386916200, @"sleepTime": @8 };
    if(![sleepTimeDict isKindOfClass:[NSDictionary class]]) {
        NSLog(@"WARNING, %s Failed to get NSDictionary from sleep_time sensor %@", __PRETTY_FUNCTION__, [error localizedDescription]);
        return ;
    }
    
    self.sleepState = [[GOSleepState alloc] initWithDictionary:sleepTimeDict];
}


//@Stefan, here an example to get the data
- (void) onNewData:(NSNotification*)notification {
    NSString* sensor = notification.object;
    if ([sensor isEqualToString:@"time active"]) {
        
        NSString* json = [notification.userInfo valueForKey:@"value"];
        NSTimeInterval totalSeconds = [json doubleValue];
        /*
        int hours = totalSeconds / 3600;
        int minutes = ((int)(totalSeconds / 60)) % 60;
        int seconds = ((int)totalSeconds) % 60;
        NSLog(@"Active for %.2i:%.2i:%.2i", hours, minutes, seconds);
         */
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                [self willChangeValueForKey:@"timeActive"];
                _timeActive = totalSeconds;
                [self didChangeValueForKey:@"timeActive"];
            }
        });
    } else if ([sensor isEqualToString:[_sleepTimeSensor name]]) {
        // Will receive updates every 5 minutes between 22h and 12h according to Ted
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *json = [notification.userInfo valueForKey:@"value"];
            NSLog(@"Sleep time %@", json);
            self.sleepState = [[GOSleepState alloc] initWithDictionary:json];
        });
    }
}

- (void)addVersionInfoDataPoint:(NSString *)version build:(NSString *)build {
    NSDate *nowDate = [[GOMainApp sharedMainApp] nowDate];
    [CSSensePlatform addDataPointForSensor:@"version"
                               displayName:nil
                               description:@"Goalie iOS"
                                dataType:kCSDATA_TYPE_JSON
                                jsonValue:@{ @"version":@"1.0.5.1", @"build":@"1066" }
                                timestamp:nowDate];
}

- (void)addEmotionDataPointWithPleasure:(NSNumber *)pleasure arousal:(NSNumber *)arousal dominance:(NSNumber *)dominance {
    NSDate *nowDate = [[GOMainApp sharedMainApp] nowDate];
    
    [CSSensePlatform addDataPointForSensor:@"emotion"
                               displayName:nil
                               description:@"emotion"
                                  dataType:kCSDATA_TYPE_JSON
                                 jsonValue:@{@"pleasure":pleasure, @"arousal":arousal, @"dominance":dominance}
                                 timestamp:nowDate];
    [CSSensePlatform flushData];
}

- (void)setSpatialSettingInterval:(NSUInteger)interval {
    NSString *str = [NSString stringWithFormat:@"%d", interval];
    [[CSSettings sharedSettings] setSettingType:kCSSettingTypeSpatial setting:kCSSpatialSettingInterval value:str];
    [[CSSettings sharedSettings] setSettingType:kCSSettingTypeSpatial setting:kCSSpatialSettingFrequency value:@"50"];
    [[CSSettings sharedSettings] setSettingType:kCSSettingTypeSpatial setting:kCSSpatialSettingNrSamples value:@"150"];
}

- (void)useDefaultSpatialSettingInterval {
    [self setSpatialSettingInterval:activityPollIntervalSeconds];
}

- (void)stopTemporaryHighFrequencyMotionDetection:(NSTimer *)timer {
    [self useDefaultSpatialSettingInterval];
    [CSSensePlatform flushData];
}

- (void)startTemporaryHighFrequencyMotionDetection {
    [self setSpatialSettingInterval:1];
    NSTimer *timer = [NSTimer timerWithTimeInterval:60.0 target:self selector:@selector(stopTemporaryHighFrequencyMotionDetection:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}


@end
