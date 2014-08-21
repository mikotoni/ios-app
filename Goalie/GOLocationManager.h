//
//  GOLocationManager.h
//  Goalie
//
//  Created by Stefan Kroon on 12-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GOLocationManager : NSObject <CLLocationManagerDelegate>

- (NSSet *)monitoredRegions;
- (void)programMonitorRegions;
- (void)simulateRegionEnter:(CLRegion *)region;
- (void)eraseAllMonitorRegions;
    
@end
