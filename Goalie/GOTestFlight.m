//
//  GOTestFlight.m
//  Goalie
//
//  Created by Stefan Kroon on 03-07-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GOTestFlight.h"
#import "TestFlight.h"
#import "TestFlight+ManualSessions.h"

#import "objc/runtime.h"
#import <mach/mach.h>

@implementation GOTestFlight

- (id)init {
    self = [super init];
    if(self) {
        [TestFlight setOptions: @{
            TFOptionManualSessions : @YES,
            //TFOptionSessionKeepAliveTimeout : @0
         }];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        //[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#pragma clang diagnostic pop
        [TestFlight takeOff:@"1b13b559-3a69-4ab9-9027-1c31a2fc7324"];
        UIApplication *sharedApplication = [UIApplication sharedApplication];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processApplicationNotification:) name:nil object:sharedApplication];
    }
    return self;
}

- (void)processApplicationNotification:(NSNotification *)notification {
    NSString *name = [notification name];
    if(name && [name length] >= 1 && [name characterAtIndex:0] == '_')
        return;
    
    NSLog(@"%@", name);
    if([name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        [TestFlight manuallyStartSession];
        TFLog(@"%@: Start foreground session", name);
    }
    else if([name isEqualToString:UIApplicationWillResignActiveNotification]) {
        TFLog(@"%@: End foreground session", name);
        [TestFlight manuallyEndSession];
    }
    else if([name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [TestFlight manuallyStartSession];
        TFLog(@"%@: Start background session", name);
    }
    else if([name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        TFLog(@"%@: End background session", name);
        [TestFlight manuallyEndSession];
    }
    else if([name isEqualToString:UIApplicationWillTerminateNotification]) {
        TFLog(@"%@: End session", name);
        [TestFlight manuallyEndSession];
    }
    if([name isEqualToString:UIApplicationDidReceiveMemoryWarningNotification]) {
        [TestFlight passCheckpoint:@"UIApplicationDidReceiveMemoryWarningNotification"];
        TFLog(@"%@: Memory warning", name);
    }
}


+ (void)outputObjectDescription:(NSObject *)obj {
    Class cls = [obj class];
    NSLog(@"Class name: %s", class_getName(cls));
    unsigned nofMethods;
    Method *methods = class_copyMethodList(cls, &nofMethods);
    for(int i = 0; i < nofMethods; i++) {
        NSLog(@"method: %@", NSStringFromSelector(method_getName(methods[i])));
    }
    free(methods);

    unsigned nofProperties;
    objc_property_t *properties = class_copyPropertyList(cls, &nofProperties);
    for(int i = 0; i < nofProperties; i++) {
        NSLog(@"property: %s", property_getName(properties[i]));
    }
    free(properties);
    
    unsigned nofIvars;
    Ivar *ivars = class_copyIvarList(cls, &nofIvars);
    for(int i = 0; i < nofIvars; i++) {
        ptrdiff_t diff = ivar_getOffset(ivars[i]);
        const char *ivarType = ivar_getTypeEncoding(ivars[i]);
        NSLog(@"ivar: %s type:%s offset:%d", ivar_getName(ivars[i]), ivarType, diff);
        if(ivarType[0] == '@') {
            id refObj = object_getIvar(obj, ivars[i]);
            NSLog(@"ivar object:%p %@", refObj, refObj);
        }
    }
}

- (int)residentMemoryInKb {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    
    if(kerr == KERN_SUCCESS)
        return info.resident_size/1024;
    else
        return -1;
}

- (double)totalCpuTime {
    task_t task;
    kern_return_t error;
    mach_msg_type_number_t count;
    thread_array_t thread_table;
    thread_basic_info_t thi;
    thread_basic_info_data_t thi_data;
    unsigned table_size;
    unsigned table_array_size;
    struct task_basic_info ti;
    double total_time;
    
    // get total time of the current process
    task = mach_task_self();
    count = TASK_BASIC_INFO_COUNT;
    error = task_info(task, TASK_BASIC_INFO, (task_info_t)&ti, &count);
    if (error != KERN_SUCCESS) {
        return -1;
    }
    { /* calculate CPU times, adapted from top/libtop.c */
        unsigned i;
        
        //
        // the following times are for threads which have already terminated and gone away.
        //
        total_time = ti.user_time.seconds + ti.user_time.microseconds * 1e-6;
        total_time += ti.system_time.seconds + ti.system_time.microseconds * 1e-6;
        
        error = task_threads(task, &thread_table, &table_size);
        
        //
        // failed to retrieve thread list: we can't proceed any further.
        //
        if (error != KERN_SUCCESS) {
            error = mach_port_deallocate(mach_task_self(), task);
            assert(error == KERN_SUCCESS);
            return -1;
        }
        
        thi = &thi_data;
        table_array_size = table_size * sizeof(thread_array_t);
        
        //
        // for each active thread, add up thread time
        //
        for (i = 0; i < table_size; ++i) {
            count = THREAD_BASIC_INFO_COUNT;
            error = thread_info(thread_table[i], THREAD_BASIC_INFO, (thread_info_t)thi, &count);
            
            //
            // if the thread_info call fails, clean up and fail hard.
            // partial results are probably useless.
            //
            if (error != KERN_SUCCESS) {
                for (; i < table_size; ++i) {
                    error = mach_port_deallocate(mach_task_self(), thread_table[i]);
                    assert(error == KERN_SUCCESS);
                }
                
                error = vm_deallocate(mach_task_self(), (vm_offset_t)thread_table, table_array_size);
                assert(error == KERN_SUCCESS);
                
                error = mach_port_deallocate(mach_task_self(), task);
                assert(error == KERN_SUCCESS);
                
                return -1;
            }
            
            //
            // otherwise, accumulate & continue.
            //
            if ((thi->flags & TH_FLAGS_IDLE) == 0) {
                total_time += thi->user_time.seconds + thi->user_time.microseconds * 1e-6;
                total_time += thi->system_time.seconds + thi->system_time.microseconds * 1e-6;
            }
            
            error = mach_port_deallocate(mach_task_self(), thread_table[i]);
            assert(error == KERN_SUCCESS);
        }
        
        //
        // deallocate the thread table.
        //
        error = vm_deallocate(mach_task_self(), (vm_offset_t)thread_table, table_array_size);
        assert(error == KERN_SUCCESS);
    }
    if (task != mach_task_self()) {
        error = mach_port_deallocate(mach_task_self(), task);
        assert(error == KERN_SUCCESS);
    }
    return total_time;
}


/*
NSString* report_memory(void) {
    if( kerr == KERN_SUCCESS ) {
        return [NSString stringWithFormat:@"Memory in use: %u kb",
                ];
    } else {
        return [NSString stringWithFormat:@"Error with task_info(): %s", mach_error_string(kerr)];
    }
}
 */

@end
