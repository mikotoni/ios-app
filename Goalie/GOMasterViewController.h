//
//  GOMasterViewController.h
//  Goalie
//
//  Created by Stefan Kroon on 16-04-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <CoreData/CoreData.h>
#import <CouchCocoa/CouchUITableSource.h>

//@interface GOMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate> {

//@interface GOMasterViewController : UITableViewController <CouchUITableDelegate>
@interface GOMasterViewController : UIViewController <CouchUITableDelegate,UICollectionViewDataSource,UICollectionViewDelegate> {
    UIRefreshControl *_refreshControl;
    NSDateFormatter *_deadlineFormatter;
    //NSMutableDictionary *activeGoals;
    //NSMutableDictionary *goals;
    
    UIImageView *logoImageView;
    IBOutlet UIBarButtonItem *barButton;
}

//@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
//@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong ,nonatomic) CouchUITableSource *uiTableSource;
@property (weak ,nonatomic) IBOutlet UITableView *tableView;
@property (strong ,nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) CouchLiveQuery *query;

- (IBAction)syncGoals:(id)sender;

@end
