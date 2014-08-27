//
//  GOAdvancedBrewsTableVC.h
//  Goalie
//
//  Created by Stefan Kroon on 19-08-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GOGenericModelClasses.h"
#import <CouchCocoa/CouchUITableSource.h>

@interface GOAdvancedBrewsTableVC : UITableViewController {
    CouchLiveQuery *liveQuery;
    CouchQueryEnumerator *enumerator;
    NSArray *visibleBrews;
}

- (IBAction)deleteAll:(id)sender;

@end
