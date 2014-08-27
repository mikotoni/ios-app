//
//  GOMasterViewController.m
//  Goalie
//
//  Created by Stefan Kroon on 16-04-13.
//  Copyright (c) 2013 Stefan Kroon. All rights reserved.
//

#import "GODashboardViewController.h"
#import "GOAppDelegate.h"

// Model
#import "GOGenericModelClasses.h"
#import "GOAgoraphobiaGoal.h"
#import "GORegularSleepGoal.h"

// UI
#import "GOActiveGoalTableVC.h"
#import "GONewGoalVC.h"
#import "GOGoalCell.h"
#import "GOGoalCollenctionCell.h"
#import "GONewGoalTasksViewController.h"
#import "GOAdjustTimeVC.h"

// Services
#import "GOMainApp.h"
#import "GOGoalieServices.h"
#import "GOSensePlatform.h"

// Frameworks
#import <QuartzCore/QuartzCore.h>

@interface GODashboardViewController()

@property GOGoalieServices *goalieServices;

@end

@implementation GODashboardViewController {
    GOGoalieServices *__goalieServices;
    UIActivityIndicatorView *_activityIndicator;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    //GOAppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
    //self.managedObjectContext = [[GOMainApp sharedMainApp] managedObjectContext];
    //[self.tableView setAllowsSelectionDuringEditing:YES];
}

/*
 - (void)refreshControlAction {
 [[[GOMainApp sharedMainApp] sensePlatform] refreshActiveGoalsDictionaries];
 [self.tableView reloadData];
 [_refreshControl endRefreshing];
 }
 
 - (void)setupRefreshControl {
 _refreshControl = [[UIRefreshControl alloc] init];
 [_refreshControl addTarget:self
 action:@selector(refreshControlAction)
 forControlEvents:UIControlEventValueChanged];
 [self setRefreshControl:_refreshControl];
 
 }
 */

- (void)dealloc {
    self.goalieServices = nil;
    if(self.tableView.delegate)
        [self.tableView setDelegate:nil];
    if(self.tableView.dataSource)
        [self.tableView setDataSource:nil];
    
    if(self.uiTableSource) {
        if(self.uiTableSource.query)
            [self cancelObservingActiveGoalsQuery];
        if(self.uiTableSource.tableView)
            self.uiTableSource.tableView = nil;
        self.uiTableSource = nil;
    }
    [self cancelObservingSensePlatformStatus];
    [self cancelObservingGoalieServices];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    //activeGoals = [[NSMutableDictionary alloc] init];
    //goals = [[NSMutableDictionary alloc] init];
    
    self.navigationController.toolbar.tintColor = self.navigationController.navigationBar.tintColor;
    UITableView *tableView = self.tableView;
    UILabel* lbNavTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,40,320,40)];
    lbNavTitle.textAlignment = NSTextAlignmentLeft;
    lbNavTitle.text = @"GOALIE";
    lbNavTitle.font = [UIFont fontWithName:@"ProximaNova-Bold" size:16];
    [lbNavTitle setTextColor:[UIColor whiteColor]];
    
    self.navigationItem.titleView = lbNavTitle;
    //tableView.backgroundColor = [UIColor clearColor];
    //tableView.opaque = NO;
    /*
     UIView *backgroundView = [[UIView alloc] init];
     backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"NSTexturedFullScreenBackgroundColor.png"]];
     tableView.backgroundView = backgroundView;
     */
    
    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    //[self setupRefreshControl];
    _deadlineFormatter = [[NSDateFormatter alloc] init];
    [_deadlineFormatter setDateStyle:NSDateFormatterMediumStyle];
    [_deadlineFormatter setTimeStyle:NSDateFormatterShortStyle];
    [_deadlineFormatter setDoesRelativeDateFormatting:YES];
    //[[[GOMainApp sharedMainApp] goalieServices] dumpAllDocuments];
    
    // Query the view
    self.uiTableSource = [[CouchUITableSource alloc] init];
    self.uiTableSource.tableView = tableView;
    [tableView setDataSource:self.uiTableSource];
    [tableView setDelegate:self];
    
    self.goalieServices = [[GOMainApp sharedMainApp] goalieServices];
    [self startObservingSensePlatformStatus];
    [self startObservingGoalieServices];
    
    
    GOSensePlatform *sensePlatform = [[GOMainApp sharedMainApp] sensePlatform];
    [self updateLogoImageIsOnline:[sensePlatform isConnected] animated:NO];
}

- (GOGoalieServices *)goalieServices {
    return __goalieServices;
}

- (void)setGoalieServices:(GOGoalieServices *)goalieServices {
    NSLog(@"%s goalieServices:%@ __goalieServices:%@", __PRETTY_FUNCTION__, goalieServices, __goalieServices);
    if(goalieServices == __goalieServices)
        return;
    if(__goalieServices) {
        [self cancelObservingActiveGoalsQuery];
        self.uiTableSource.query = (id)[[CouchNullQuery alloc] init];
        //        self.query = (id)[[CouchNullQuery alloc] init];
    }
    __goalieServices = goalieServices;
    if(__goalieServices) {
        [self startObservingActiveGoalsQuery];
        self.uiTableSource.query = [goalieServices activeGoalsQuery];
        //        self.query = [goalieServices activeGoalsQuery];
        [self processPossibleLaunchNotifications];
        [__goalieServices updateNofUncompletedTasks];
    }
}

- (void)startObservingGoalieServices {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    [mainApp addObserver:self forKeyPath:kGOGoalieServices options:0 context:nil];
}

- (void)cancelObservingGoalieServices {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    [mainApp removeObserver:self forKeyPath:kGOGoalieServices];
}

- (void)startObservingActiveGoalsQuery {
    [self.goalieServices addObserver:self
                          forKeyPath:@"activeGoalsQuery"
                             options:NSKeyValueObservingOptionNew
                             context:nil];
}

- (void)cancelObservingActiveGoalsQuery {
    [self.goalieServices removeObserver:self forKeyPath:@"activeGoalsQuery"];
}

- (void)startObservingSensePlatformStatus {
    GOSensePlatform *sensePlatform = [[GOMainApp sharedMainApp] sensePlatform];
    [sensePlatform addObserver:self forKeyPath:kGOIsConnected options:0 context:nil];
    [sensePlatform addObserver:self forKeyPath:kGOIsLoadingActiveGoals options:0 context:nil];
}

- (void)cancelObservingSensePlatformStatus {
    GOSensePlatform *sensePlatform = [[GOMainApp sharedMainApp] sensePlatform];
    [sensePlatform removeObserver:self forKeyPath:kGOIsConnected];
    [sensePlatform removeObserver:self forKeyPath:kGOIsLoadingActiveGoals];
}

- (void)updateLogoImageIsOnline:(bool)isOnline animated:(bool)animated {
    if(!logoImageView) {
        // Setting the logo in the navigation bar
        UIImage *image = [UIImage imageNamed:@"goal-keeper-basic-33.png"];
        logoImageView = [[UIImageView alloc] initWithImage:image];
        logoImageView.autoresizingMask = UIViewAutoresizingNone;
        logoImageView.contentMode = UIViewContentModeCenter;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect rect = CGRectMake(0.0, 0.0, 33.0, 33.0);
        button.frame = rect;
        [button addSubview:logoImageView];
        logoImageView.center = button.center;
        logoImageView.layer.opaque = NO;
        logoImageView.opaque = NO;
        
        //        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        //        [[self navigationItem] setLeftBarButtonItem:barButtonItem];
    }
    
    float angle = 0.0;
    if(!isOnline)
        angle = 45.0;
    NSLog(@"angle: %f", angle);
    CGAffineTransform rotate = CGAffineTransformMakeRotation(angle / 180.0 * M_PI);
    
    if(animated) {
        [UIView animateWithDuration:1.0 animations:^{
            [logoImageView setTransform:rotate];
        }];
    }
    else {
        [logoImageView.layer setAffineTransform:rotate];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


- (UIBarButtonItem *)editButtonItem {
    return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([[GOMainApp sharedMainApp] isTesting])
        return UITableViewCellEditingStyleDelete;
    else
        return UITableViewCellEditingStyleNone;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CouchDocument *document =  [self.uiTableSource documentAtIndexPath:indexPath];
    GOActiveGoal *activeGoal = [[CouchModelFactory sharedInstance] modelForDocument:document];
    GOGoal *goal = [activeGoal goal];
    if(goal) {
        //if(![activeGoal isKindOfClass:[GOAgoraphobiaGoal class]] && ![activeGoal isKindOfClass:[GORegularSleepGoal class]])
        return indexPath;
    }
    return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"%s keyPath:%@", __PRETTY_FUNCTION__, keyPath);
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    if([object isKindOfClass:[GOGoalieServices class]]) { // && [keyPath isEqualToString:@"activeGoalsQuery"]) {
        CouchLiveQuery *newQuery = [change objectForKey:NSKeyValueChangeNewKey];
        self.uiTableSource.query = newQuery;
        //        self.query = newQuery;
        //        [self.collectionView reloadData];
    }
    else if([object isKindOfClass:[GOSensePlatform class]]) { // && [keyPath isEqualToString:kGOIsConnected]) {
        GOSensePlatform *sensePlatform = [mainApp sensePlatform];
        if([keyPath isEqualToString:kGOIsConnected]) {
            [self updateLogoImageIsOnline:[sensePlatform isConnected] animated:YES];
        }
        else if([keyPath isEqualToString:kGOIsLoadingActiveGoals]) {
            [self setSyncButtonOn:[sensePlatform isLoadingActiveGoals]];
        }
    }
    else if([object isKindOfClass:[GOMainApp class]]) {
        self.goalieServices = [mainApp goalieServices];
    }
    [self.collectionView reloadData];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
}

- (void)processPossibleLaunchNotifications {
    GOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if(delegate.launchNotification) {
        [self.goalieServices processLocalNotification:delegate.launchNotification whileInForeground:NO];
        delegate.launchNotification = nil;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if([self.tableView isEditing]) {
        [self setEditing:NO];
    }
    if(self.goalieServices) {
        [self processPossibleLaunchNotifications];
        [self.goalieServices updateNofUncompletedTasks];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 - (void)insertNewObject:(id)sender
 {
 NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
 NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
 NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
 
 // If appropriate, configure the new managed object.
 // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
 [newManagedObject setValue:[GOMainApp nowDate] forKey:@"timeStamp"];
 
 // Save the context.
 NSError *error = nil;
 if (![context save:&error]) {
 // Replace this implementation with code to handle the error appropriately.
 // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
 NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
 abort();
 }
 }
 */

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([identifier isEqualToString:@"SelectActiveGoalSegue"] && [[GOMainApp sharedMainApp] isTesting]) {
        [self performSegueWithIdentifier:@"selectGoal" sender:sender];
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    
    NSString *segueIdentifier = [segue identifier];
    /*if ([segueIdentifier isEqualToString:@"showDetail"]) {
     NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
     NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
     [[segue destinationViewController] setDetailItem:object];
     }
     else */
    if([segueIdentifier isEqualToString:@"NewGoalSegue"]) {
        /*
         //GOGoal *newGoal = [GOGoal goalInManagedObjectContext:self.managedObjectContext];
         CouchDatabase *database = [couchCocoa serverDatabase];
         GOGoal *newGoal = [[GOGoal alloc] initWithNewDocumentInDatabase:database];
         
         [newGoal setHeadline:@"Nieuw doel"];
         [newGoal setExplanation:@"Er is (nog) geen toelichting."];
         [newGoal setDeadline:[GOMainApp nowDate]];
         [mainApp setEditingGoal:newGoal];
         GONewGoalVC *newGoalVC = [segue destinationViewController];
         [newGoalVC prepareForNewGoal];
         */
    }
    else if([segueIdentifier isEqualToString:@"selectGoal"]) {
        NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
        CouchDocument *document =  [self.uiTableSource documentAtIndexPath:indexPath];
        //GOGoal *goal = [self.fetchedResultsController objectAtIndexPath:indexPath];
        GOActiveGoal *goal = [[CouchModelFactory sharedInstance] modelForDocument:document];
        [mainApp setEditingGoal:goal];
        GONewGoalTasksViewController *newGoalTasksVC = [segue destinationViewController];
        [newGoalTasksVC prepareForGoal];
    }
    else if([segueIdentifier isEqualToString:@"editGoal"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        CouchDocument *document =  [self.uiTableSource documentAtIndexPath:indexPath];
        //GOGoal *goal = [self.fetchedResultsController objectAtIndexPath:indexPath];
        GOActiveGoal *goal = [[CouchModelFactory sharedInstance] modelForDocument:document];
        [mainApp setEditingGoal:goal];
        GONewGoalTasksViewController *editGoalVC = [segue destinationViewController];
        [editGoalVC prepareForEditGoal];
    }
    else if([segueIdentifier isEqualToString:@"SelectActiveGoalSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        CouchDocument *document = [self.uiTableSource documentAtIndexPath:indexPath];
        GOActiveGoal *activeGoal = [[CouchModelFactory sharedInstance] modelForDocument:document];
        GOActiveGoalTableVC *tvc = [segue destinationViewController];
        [tvc setActiveGoal:activeGoal];
    }
    else if([segueIdentifier isEqualToString:@"SelectCollectionCellGoalSegue"]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        GOGoalCollenctionCell *cell = (GOGoalCollenctionCell*)sender;
        GOActiveGoalTableVC *tvc = [segue destinationViewController];
        [tvc setActiveGoal:cell.activeGoal];
    }
    else if([segueIdentifier isEqualToString:@"SettingsSegue"]) {
        //GOSettingsVC *settingsVC = [segue destinationViewController];
        //[settingsVC setTimeInterval:[[GOMainApp sharedMainApp] timeOffsetInterval]];
    }
    
    else NSLog(@"Unknown segue: %@", segueIdentifier);
}

- (void)setSyncButtonOn:(bool)state {
    UIButton *buttonView = [barButton valueForKey:@"view"];
    [buttonView setEnabled:!state];
}

- (IBAction)syncGoals:(id)sender {
    GOMainApp *mainApp = [GOMainApp sharedMainApp];
    [mainApp syncActiveGoals];
}

#pragma mark - CouchUITable delegate

- (UITableViewCell *)couchTableSource:(CouchUITableSource *)source cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GOGoalCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GoalCell" forIndexPath:indexPath];
    
    CouchDocument *document = [self.uiTableSource documentAtIndexPath:indexPath];
    GOActiveGoal *activeGoal = [[CouchModelFactory sharedInstance] modelForDocument:document];
    
    /*
     [activeGoals setObject:activeGoal forKey:[[activeGoal document] documentID]];
     GOGoal *goal = [activeGoal goal];
     if(goal)
     [goals setObject:goal forKey:[[goal document] documentID]];
     */
    
    [cell configureForActiveGoal:activeGoal];
    
    return cell;
}
#pragma mark - UICollectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    CouchQueryEnumerator *enumerator = [self.query rows];
    CouchQueryRow *row;
    while((row = [enumerator nextRow])) {
        GOActiveGoal *activeGoal = [[CouchModelFactory sharedInstance] modelForDocument:[row document]];
        NSDate *activeGoalEnd = [activeGoal endDate];
        
    }
    NSLog(@"count : %d",self.query.rows.count);
    return self.uiTableSource.query.rows.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GOGoalCollenctionCell *cell = (GOGoalCollenctionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"goalCell" forIndexPath:indexPath];
//    CouchDocument *document = [self.uiTableSource documentAtIndexPath:indexPath];
    GOActiveGoal *activeGoal = [[CouchModelFactory sharedInstance] modelForDocument:[[self.query.rows rowAtIndex:indexPath.row] document]];
    [cell configureForActiveGoal:activeGoal];
    return cell;
}
@end

