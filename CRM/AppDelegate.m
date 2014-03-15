//
//  AppDelegate.m
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "AppDelegate.h"
#import "VisitsViewController.h"
#import "VisitViewController.h"
#import "SidePanelController.h"
#import "PharmaciesViewController.h"
#import "PharmacyViewController.h"
#import "MGSplitViewController.h"
#import "LoginViewController.h"

#import "Drug.h"
#import "Dose.h"
#import "Pharmacy.h"
#import "Visit.h"
#import "Sale.h"
#import "Region.h"
#import "CommerceVisit.h"
#import "PromoVisit.h"
#import "PharmacyCircle.h"

#import "YandexMapKit.h"
#import "MGSplitDividerView.h"
#import "CommerceVisit.h"
#import <AFNetworking/AFNetworking.h>
#import "NSDate+Additions.h"
#import "Flurry.h"
#import "NSString+MD5Extension.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize childManagedObjectContext = _childManagedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static AppDelegate* sharedDelegate = nil;

+ (id)sharedDelegate
{
    
    if (sharedDelegate == nil) {
        sharedDelegate = [[super allocWithZone:NULL] init];
    }
    return sharedDelegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [YMKConfiguration sharedInstance].apiKey = @"hXrz~xe2oFLYuH257NMSBUhahF0sisGJ3uybwfYT5qXIn69olKJ03CdzMTtptAj24~mLAQJcYS6nW3UCuK-sNxBAaS17YlGPZaz0jrOEPr8=";
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"navBarBg"] forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"navBarBg2"] forBarMetrics:UIBarMetricsDefault];
    }
    
    if (FULL_LOAD)
    {
        [self deleteAllObjects:@"Region"];
        [self deleteAllObjects:@"Visit"];
        [self deleteAllObjects:@"Pharmacy"];
        [self deleteAllObjects:@"Drug"];
        [self deleteAllObjects:@"Sale"];
       // [self deleteAllObjects:@"User"];
    }
    sharedDelegate = self;
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    _visitsSplitController = [[MGCustomSplitViewController alloc]init];
    //_visitsSplitController.dividerStyle = MGSplitViewDividerStylePaneSplitter;
    //_visitsSplitController.dividerView.hidden = YES;
    
    PharmacyViewController* pharmacyViewController = [PharmacyViewController new];
    self.pharmaciesViewController = [PharmaciesViewController new];
    self.pharmaciesViewController.pharmacyViewController = pharmacyViewController;
    
    VisitViewController* visitViewController = [VisitViewController new];
    self.visitsViewController = [VisitsViewController new];
    self.visitsViewController.visitViewController = visitViewController;
    
    self.visitsSplitController.viewControllers = @[[[UINavigationController alloc]initWithRootViewController:self.visitsViewController],[[UINavigationController alloc]initWithRootViewController:visitViewController]];
    _clientsSplitController = [[MGCustomSplitViewController alloc]init];
    self.clientsSplitController.viewControllers = @[[[UINavigationController alloc]initWithRootViewController:self.pharmaciesViewController],[[UINavigationController alloc]initWithRootViewController:pharmacyViewController]];

    _container = [MFSideMenuCustomContainer
                  containerWithCenterViewController:self.clientsSplitController
                                                    leftMenuViewController:nil
                                                    rightMenuViewController:nil];
    
    self.sidePanelController = [SidePanelController new];
    self.sidePanelController.delegate = self;
    self.sidePanelController.view.frame = CGRectMake(0, 0, 290, 768);
    self.overlay = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1024, 768)];
    self.overlay.backgroundColor = [UIColor blackColor];
    self.overlay.alpha = 0.8;
    [self.container.view addSubview:self.overlay];
    [self.container.view addSubview:self.sidePanelController.view];
    //self.sidePanelController.view.frame = CGRectMake(-275, 0, 290, 768);
    //self.overlay.alpha = 0;
    
    
    UIPanGestureRecognizer* gestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(movePanel:)];
    [self.sidePanelController.view addGestureRecognizer:gestureRecognizer];
    
    self.container.shadow.enabled = YES;
    self.container.menuSlideAnimationEnabled = NO;
    self.window.rootViewController = self.container;
    //self.window.rootViewController = [MapViewController new];
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],UITextAttributeTextColor,
                                               [UIColor blackColor], UITextAttributeTextShadowColor,
                                               [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(closeOldVisits) userInfo:Nil repeats:YES];
    
    [Flurry startSession:@"VF6G7F9XQ8J8QM7249DS"];
    
    //TODO: must do it in loadFromServer in production version
    //[self parseUserLocal];
    [self showLoginScreenWithAnimation:NO];
    
    [[NSNotificationCenter defaultCenter]addObserverForName:NSManagedObjectContextDidSaveNotification object:self.childManagedObjectContext queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:note];
        self.sidePanelController.nameLabel.text = self.currentUser.name;
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"dd.MM.yyyy HH:mm";
        self.sidePanelController.syncLabel.text = [dateFormatter stringFromDate:[NSDate date]];
        [self reloadData];
    }];
    self.syncInProgress = NO;
    return YES;
}

#pragma mark interface
- (void)showLoginScreenWithAnimation:(BOOL)animated
{
    self.loginViewController = [LoginViewController new];
    [self.container presentViewController:self.loginViewController animated:animated completion:nil];
}

- (void)sidePanelController:(SidePanelController *)controller didSelectItem:(NSInteger)item
{
    switch (item)
    {
        case 0:
            self.container.centerViewController = self.visitsSplitController;
            //FAST FIX
            self.container.centerViewController = self.visitsSplitController;
            break;
        case 1:
            self.container.centerViewController = self.clientsSplitController;
            //FAST FIX
            self.container.centerViewController = self.clientsSplitController;
            break;
        default:
            [self syncDataWithServer];
            self.container.centerViewController = self.clientsSplitController;
            //FAST FIX
            self.container.centerViewController = self.clientsSplitController;
            break;
    }
    //Seems that container removes panel after change in centerviewcontroller, so we reuse it here
    [self.container.view addSubview:self.overlay];
    [self.container.view addSubview:self.sidePanelController.view];
    [UIView animateWithDuration:0.3 animations:^{
        self.sidePanelController.view.frame = CGRectMake(-275, 0, 290, 768);
        self.overlay.alpha = 0;
    }completion:^(BOOL finished) {
        [self reloadData];
    }];
}

- (void)movePanel:(UIPanGestureRecognizer*)recognizer
{
    CGPoint point = [recognizer locationInView:self.container.view];
    NSLog(@"State = %d", recognizer.state);
    NSLog(@"%f", point.x);
    
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint velocity = [recognizer velocityInView:self.container.view];
        NSLog(@"Velocity = %f", velocity.x);
        if (velocity.x < 0)
        {
        [UIView animateWithDuration:0.3 animations:^{
            self.sidePanelController.view.frame = CGRectMake(-275, 0, 290, 768);
            self.overlay.alpha = 0;
        }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.sidePanelController.view.frame = CGRectMake(0, 0, 290, 768);
                self.overlay.alpha = 0.8;
            }];
        }
    }
    else
    {
        if (point.x > 290 ||  point.x < 15)
            return;

        self.sidePanelController.view.frame = CGRectMake(point.x - 290, 0, 290, 768);
        self.overlay.alpha = 0.8 / (290.0 / point.x);
    }
}

#pragma mark finder methods
- (Region*)findRegionById:(NSInteger)regionId
{
    NSManagedObjectContext* context = self.childManagedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Region" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"regionId=%@", [NSNumber numberWithFloat:regionId]];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count > 0)
        return results[0];
    else
        return nil;
}

- (Drug*)findDrugById:(NSInteger)drugId
{
    NSManagedObjectContext* context = self.childManagedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Drug" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"drugId=%@", [NSNumber numberWithFloat:drugId]];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count > 0)
        return results[0];
    else
        return nil;
}

- (Dose*)findDoseById:(NSInteger)drugId
{
    NSManagedObjectContext* context = self.childManagedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Dose" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"doseId=%@", [NSNumber numberWithFloat:drugId]];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count > 0)
        return results[0];
    else
        return nil;
}

- (Pharmacy*)findPharmacyById:(NSInteger)pharmacyId
{
    NSManagedObjectContext* context = self.childManagedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Pharmacy" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"pharmacyId=%@", [NSNumber numberWithFloat:pharmacyId]];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count > 0)
        return results[0];
    else
        return nil;
}

- (NSArray*)pharmaciesForUser:(User*)user
{
    NSManagedObjectContext* context = self.childManagedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Pharmacy" inManagedObjectContext:context]];
     NSPredicate* predicate = [NSPredicate predicateWithFormat:@"region IN %@", user.regions];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    return results;
}

- (Sale*)findSaleInVisit:(Visit*)visit byDoseId:(NSInteger)doseId
{
    NSManagedObjectContext* context = self.childManagedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Sale" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"commerceVisit.visit=%@ && dose.doseId=%@", visit, [NSNumber numberWithFloat:doseId]];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count > 0)
    return results[0];
    else
    return nil;
}

- (Visit*)findVisitById:(NSString*)visitId
{
    NSManagedObjectContext* context = self.childManagedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Visit" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"visitId=%@", visitId];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count > 0)
    return results[0];
    else
    return nil;
}

- (Visit*)findVisitByServerId:(NSInteger)serverId
{
    NSManagedObjectContext* context = self.childManagedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Visit" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"serverId=%@", [NSNumber numberWithInteger:serverId]];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count > 0)
    return results[0];
    else
    return nil;
}

- (User*)findUserById:(NSInteger)userId inMainContext:(BOOL)inMainContext
{
    NSManagedObjectContext* context;
    if (inMainContext)
        context = self.managedObjectContext;
    else
        context = self.childManagedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId=%@", [NSNumber numberWithFloat:userId]];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count > 0)
        return results[0];
    else
        return nil;
}

- (User*)findUserByLogin:(NSString*)login andPassword:(NSString*)password
{
    NSManagedObjectContext* context = self.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"login=%@ AND password=%@", login, password];
    //NSPredicate* predicate = [NSPredicate predicateWithFormat:@"login=%@", login];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count > 0)
        return results[0];
    else
        return nil;
}

#pragma mark Core Data
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        [_managedObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType]];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MainDatabase" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MainDatabase.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)saveChildContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.childManagedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void) deleteAllObjects: (NSString *) entityDescription
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items)
    {
    	[self.managedObjectContext deleteObject:managedObject];
    }
    if (![self.managedObjectContext save:&error])
    {
    	NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
}



#pragma mark main sync methods

- (void)closeOldVisits
{
    //NSLog(@"Checking new day....");
    NSManagedObjectContext* context = self.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Visit" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"date<%@ AND closed==NO", [NSDate currentDate]];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *visits = [context executeFetchRequest:request error:&error];
    for (Visit* visit in visits)
    {
        visit.closed = @YES;
        if (![visit isValid])
            [self.managedObjectContext deleteObject:visit];
    }
    [self saveContext];
}

- (void)setCurrentUser:(User *)currentUser
{
    self.sidePanelController.nameLabel.text = currentUser.name;
    self.sidePanelController.mailLabel.text = currentUser.login;
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"dd.MM.yyyy   HH:mm";
    _currentUser = currentUser;
}

- (void)reloadData
{
    [self.pharmaciesViewController reloadData];
    //[self.pharmaciesViewController selectFirstFromList];
    [self.visitsViewController reloadData];
}

- (void)loadDataFromServer
{
    //Do we need to recreate child context every time to synchronize with changes on main context?
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _childManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_childManagedObjectContext setPersistentStoreCoordinator:coordinator];
        [_childManagedObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType]];
    }
    
    self.sidePanelController.nameLabel.text = self.currentUser.name;
    
    LoginViewController* login = self.loginViewController;
    //[login hideLoader];
    [login dismissViewControllerAnimated:YES completion:nil];
    //[self hideLoader];
    
    self.currentUserId = self.currentUser.userId.integerValue;
    
    if (LOCAL)
    {
        [self.childManagedObjectContext performBlock:^{
            [self parseUserLocal];
            [self parseRegionLocal];
            [self parseUserRegionLocal];
            [self parsePreparatLocal];
            [self parsePreparatDoseLocal];
            [self parsePharmLocal];
            [self parseVisitLocal];
            [self parseVisitSaleLocal];
            [self recalculateVisitsCount];}];
    }
    else
    {
        
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        NSString* regionDate = self.currentUser.regionDate;
        NSString* userRegionDate = self.currentUser.userRegionDate;
        NSString* pharmDate = self.currentUser.pharmDate;
        NSString* preparatDate = self.currentUser.preparatDate;
        NSString* preparatDoseDate = self.currentUser.preparatDoseDate;
        NSString* userDate = self.currentUser.userDate;
        NSString* visitDate = self.currentUser.visitDate;
        
        if (FULL_LOAD || regionDate == nil)
        {
            visitDate = regionDate = userRegionDate = pharmDate = preparatDate = preparatDoseDate = userDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:0]];
        }
        
        NSString* urlString = [[NSString stringWithFormat:@"http://crm.mydigital.guru/server/sync?clientId=%@&date[Region]=%@&date[UserRegion]=%@&date[Pharm]=%@&date[Preparat]=%@&date[PreparatDose]=%@&date[User]=%@&date[Visit]=%@", self.currentUser.userId, regionDate, userRegionDate, pharmDate, preparatDate, preparatDoseDate, userDate, visitDate]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:urlString parameters:Nil success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSLog(@"Load successful. Start parsing...");
             
             [self.childManagedObjectContext performBlock:^{
                 
                 id usersDict = [responseObject objectForKey:@"User"];
                 if ([usersDict isKindOfClass:[NSDictionary class]])
                 {
                     [self parseUser:usersDict];
                 }
                 id regionDict = [responseObject objectForKey:@"Region"];
                 if ([regionDict isKindOfClass:[NSDictionary class]])
                 {
                     [self parseRegion:regionDict];
                 }
                 id userRegionDict = [responseObject objectForKey:@"UserRegion"];
                 if ([userRegionDict isKindOfClass:[NSDictionary class]])
                 {
                     [self parseUserRegion:userRegionDict];
                 }
                 id pharmDict = [responseObject objectForKey:@"Pharm"];
                 if ([pharmDict isKindOfClass:[NSDictionary class]])
                 {
                     [self parsePharm:pharmDict];
                 }
                 id preparatDict = [responseObject objectForKey:@"Preparat"];
                 if ([preparatDict isKindOfClass:[NSDictionary class]])
                 {
                     [self parsePreparat:preparatDict];
                 }
                 id doseDict = [responseObject objectForKey:@"PreparatDose"];
                 if ([doseDict isKindOfClass:[NSDictionary class]])
                 {
                     [self parsePreparatDose:doseDict];
                 }
                 id visitDict = [responseObject objectForKey:@"Visit"];
                 if ([visitDict isKindOfClass:[NSDictionary class]])
                 {
                     [self parseVisit:visitDict];
                 }
                 id visitSaleDict = [responseObject objectForKey:@"VisitSale"];
                 if ([visitSaleDict isKindOfClass:[NSDictionary class]])
                 {
                     [self parseVisitSale:visitSaleDict];
                 }
                 [self recalculateVisitsCount];
             }];
         }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Failure");
             [self reloadData];
             
         }];
    }
}



- (void)syncDataWithServer
{
    NSLog(@"Sending to server...");
    NSManagedObjectContext* context = self.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Visit" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"closed==YES && sent==NO"];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *visits = [context executeFetchRequest:request error:&error];
    
    [visits enumerateObjectsUsingBlock:^(Visit* visit, NSUInteger idx, BOOL *stop) {
        NSDictionary* arrDic = [visit encodeToJSON];
        
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:arrDic options:NSJSONWritingPrettyPrinted error:nil];
        NSString* json = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", json);
        
        NSDictionary* fullJSON = @{@"data" : json};
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer new];
        manager.responseSerializer = [AFJSONResponseSerializer new];
        NSMutableSet* responseTypes = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
        [responseTypes addObject:@"text/html"];
        manager.responseSerializer.acceptableContentTypes = responseTypes;
        
        NSString* urlString = [NSString stringWithFormat:@"http://crm.mydigital.guru/server/regVisit?clientId=%@", self.currentUser.userId];
        [manager POST:urlString parameters:fullJSON success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
            NSDictionary* okDict = responseObject[@"ok"];
            if (okDict)
            {
                NSLog(@"Visit was sent");
                visit.sent = @YES;
            }
            if (idx == visits.count - 1)
            {
                [self loadDataFromServer];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (idx == visits.count - 1)
            {
                [self loadDataFromServer];
            }
            NSLog(@"%@", operation.responseString);
            NSLog(@"Error while sending visit: %@", error);
        }];
    }];
}



#pragma mark json parser methods
- (void)parseUser:(NSDictionary*)dict
{
    NSArray* addArray = [dict objectForKey:@"add"];
    for (NSDictionary* obj in addArray)
    {
        NSNumber* userId = (NSNumber*)[obj objectForKey:@"user_id"];
        User* user = [self findUserById:userId.integerValue inMainContext:NO];
        if (!user)
        {
            user = [NSEntityDescription
                    insertNewObjectForEntityForName:@"User"
                    inManagedObjectContext:self.childManagedObjectContext];
            user.userId = userId;
        }
        user.name = [obj objectForKey:@"name"];
        if ([obj objectForKey:@"email"]!=[NSNull null])
        {
            user.login = [obj objectForKey:@"email"];
        }
        if ([obj objectForKey:@"passwd"]!=[NSNull null])
        {
            NSString* passRaw = [obj objectForKey:@"passwd"];
            user.password = [passRaw md5];
        }
    }
    NSArray* removeArray = [dict objectForKey:@"remove"];
    for (NSNumber* regionId in removeArray)
    {
        User* user = [self findUserById:regionId.integerValue inMainContext:NO];
        [self.childManagedObjectContext deleteObject:user];
    }
    User* currentUser = [self findUserById:self.currentUserId inMainContext:NO];
    currentUser.userDate = [dict objectForKey:@"date"];
    [self saveChildContext];
}


- (void)parseRegion:(NSDictionary*)dict
{
    NSArray* addArray = [dict objectForKey:@"add"];
    for (NSDictionary* obj in addArray)
    {
        NSNumber* regionId = (NSNumber*)[obj objectForKey:@"region_id"];
        Region* region = [self findRegionById:regionId.integerValue];
        if (!region)
        {
            region = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Region"
                      inManagedObjectContext:self.childManagedObjectContext];
            region.regionId = regionId;
        }
        region.name = [obj objectForKey:@"name"];
    }
    NSArray* removeArray = [dict objectForKey:@"remove"];
    for (NSNumber* regionId in removeArray)
    {
        Region* region = [self findRegionById:regionId.integerValue];
        [self.childManagedObjectContext deleteObject:region];
    }
    User* currentUser = [self findUserById:self.currentUserId inMainContext:NO];
    currentUser.regionDate = [dict objectForKey:@"date"];
    [self saveChildContext];
}

- (void)parseUserRegion:(NSDictionary*)dict
{
    NSArray* addArray = [dict objectForKey:@"add"];
    for (NSDictionary* obj in addArray)
    {
        NSInteger userId = [[[obj objectForKey:@"user_id"]stringValue]integerValue];
        User* user = [self findUserById:userId inMainContext:NO];
        if (user)
        {
            NSInteger regionId = [[(NSNumber*)[obj objectForKey:@"region_id"]stringValue]integerValue];
            Region* region = [self findRegionById:regionId];
            
            if (region)
            {
                [user addRegionsObject:region];
            }
        }
    }
    NSArray* removeArray = [dict objectForKey:@"remove"];
    for (NSDictionary* obj in removeArray)
    {
        NSInteger userId = [[[obj objectForKey:@"user_id"]stringValue]integerValue];
        User* user = [self findUserById:userId inMainContext:NO];
        if (user)
        {
            NSInteger regionId = [[(NSNumber*)[obj objectForKey:@"region_id"]stringValue]integerValue];
            Region* region = [self findRegionById:regionId];
            
            if (region)
            {
                [user removeRegionsObject:region];
            }
        }
    }
    User* currentUser = [self findUserById:self.currentUserId inMainContext:NO];
    currentUser.userRegionDate = [dict objectForKey:@"date"];
    [self saveChildContext];
}

- (void)parsePharm:(NSDictionary*)dict
{
    int count = 0;
    NSArray* addArray = [dict objectForKey:@"add"];
    for (NSDictionary* obj in addArray)
    {
        NSString* pharmacyId = [obj objectForKey:@"pharm_id"];
        
        Pharmacy* pharmacy = [self findPharmacyById:pharmacyId.integerValue];
        if (!pharmacy)
        {
            pharmacy = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Pharmacy"
                        inManagedObjectContext:self.childManagedObjectContext];
            pharmacy.pharmacyId = @(pharmacyId.integerValue);
        }
        pharmacy.name = [obj objectForKey:@"name"];
        pharmacy.network = @([[obj objectForKey:@"net"]boolValue]);
        pharmacy.city = [obj objectForKey:@"city"];
        pharmacy.street = [obj objectForKey:@"street"];
        pharmacy.house = [obj objectForKey:@"house"];
        pharmacy.phone = [obj objectForKey:@"tel"];
        pharmacy.psp = @([[obj objectForKey:@"psp"]boolValue]);
        pharmacy.sales = [obj objectForKey:@"sales"];
        pharmacy.doctorName = [obj objectForKey:@"contact"];
        
        if ([obj objectForKey:@"latitude"] != [NSNull null])
        {
            pharmacy.latitude = [obj objectForKey:@"latitude"];
            //NSLog(@"Latitude = %@", pharmacy.latitude);
        }
        else
            pharmacy.latitude = @0;
        if ([obj objectForKey:@"longitude"] != [NSNull null])
        {
            pharmacy.longitude = [obj objectForKey:@"longitude"];
            //NSLog(@"Longitude = %@", pharmacy.longitude);
        }
        else
            pharmacy.longitude = @0;
        
        if (pharmacy.latitude.integerValue == 1)
        {
            NSLog(@"Address not found for pharmacy: %@ %@ %@", pharmacy.city, pharmacy.street, pharmacy.house);
        }
        
        //        double maxLat = 56.0;
        //        double minLat = 55.0;
        //        double minLon = 37.0;
        //        double maxLon = 38.0;
        //        double latitude = ((double)arc4random() / ARC4RANDOM_MAX) * (maxLat - minLat) + minLat;
        //        double longitude = ((double)arc4random() / ARC4RANDOM_MAX) * (maxLon - minLon) + minLon;
        //        pharmacy.latitude = @(latitude);
        //        pharmacy.longitude = @(longitude);
        
        NSInteger regionId = [[obj objectForKey:@"region_id"]integerValue];
        Region* region = [self findRegionById:regionId];
        pharmacy.region = region;
        
        if ([obj objectForKey:@"target_user_id"]!=[NSNull null])
        {
            NSInteger targetUserId = [[obj objectForKey:@"target_user_id"]integerValue];
            User* user = [self findUserById:targetUserId inMainContext:NO];
            [user addTargetablePharmaciesObject:pharmacy];
        }
        
        NSString* statusString = [obj objectForKey:@"category"];
        if ([statusString isEqualToString:@"common"])
        {
            pharmacy.status = NormalStatus;
        }
        else if ([statusString isEqualToString:@"bronze"])
        {
            pharmacy.status = BronzeStatus;
        }
        else if ([statusString isEqualToString:@"silver"])
        {
            pharmacy.status = SilverStatus;
        }
        else
        {
            pharmacy.status = GoldStatus;
        }
        count++;
        if (count == 50 || count % 300 == 0)
        {
            //Show first results immediately
            [self.childManagedObjectContext save:nil];
        }
    }
    NSArray* removeArray = [dict objectForKey:@"remove"];
    for (NSNumber* pharmId in removeArray)
    {
        Pharmacy* pharmacy = [self findPharmacyById:pharmId.integerValue];
        [self.childManagedObjectContext deleteObject:pharmacy];
    }
    User* currentUser = [self findUserById:self.currentUserId inMainContext:NO];
    currentUser.pharmDate = [dict objectForKey:@"date"];
    [self saveChildContext];
    //[self saveContext];
}

- (void)parsePreparat:(NSDictionary*)dict
{
    NSMutableArray* drugs = [NSMutableArray new];
    NSArray* addArray = [dict objectForKey:@"add"];
    for (NSDictionary* obj in addArray)
    {
        NSNumber* drugId = (NSNumber*)[obj objectForKey:@"preparat_id"];
        Drug* drug = [self findDrugById:drugId.integerValue];
        if (!drug)
        {
            drug = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Drug"
                    inManagedObjectContext:self.childManagedObjectContext];
            drug.drugId = drugId;
        }
        drug.name = [obj objectForKey:@"code"];
        [drugs addObject:drug];
    }
    NSArray* removeArray = [dict objectForKey:@"remove"];
    for (NSNumber* drugId in removeArray)
    {
        Drug* drug = [self findDrugById:drugId.integerValue];
        [self.childManagedObjectContext deleteObject:drug];
    }
    User* currentUser = [self findUserById:self.currentUserId inMainContext:NO];
    currentUser.preparatDate = [dict objectForKey:@"date"];
    [self saveChildContext];
}

- (void)parsePreparatDose:(NSDictionary*)dict
{
    NSArray* addArray = [dict objectForKey:@"add"];
    for (NSDictionary* obj in addArray)
    {
        NSNumber* doseId = (NSNumber*)[obj objectForKey:@"preparat_dose_id"];
        Dose* dose = [self findDoseById:doseId.integerValue];
        if (!dose)
        {
            dose = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Dose"
                    inManagedObjectContext:self.childManagedObjectContext];
            dose.doseId = doseId;
        }
        dose.name = [obj objectForKey:@"code"];
        
        NSNumber* drugId = (NSNumber*)[obj objectForKey:@"preparat_id"];
        Drug* drug = [self findDrugById:drugId.integerValue];
        if (drug)
        {
            [drug addDosesObject:dose];
        }
    }
    NSArray* removeArray = [dict objectForKey:@"remove"];
    for (NSNumber* doseId in removeArray)
    {
        Dose* dose = [self findDoseById:doseId.integerValue];
        [self.childManagedObjectContext deleteObject:dose];
    }
    User* currentUser = [self findUserById:self.currentUserId inMainContext:NO];
    currentUser.preparatDoseDate = [dict objectForKey:@"date"];
    [self saveChildContext];
}

- (void)parseVisit:(NSDictionary*)dict
{
    NSArray* addArray = [dict objectForKey:@"add"];
    
    for (NSDictionary* obj in addArray)
    {
        NSString* visitId = [obj objectForKey:@"code"];
        Visit* visit = [self findVisitById:visitId];
        if (!visit)
        {
            visit = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Visit"
                    inManagedObjectContext:self.childManagedObjectContext];
            visit.visitId = visitId;
        }
        visit.serverId = [obj objectForKey:@"visit_id"];
        
        NSString* visitDateString = [obj objectForKey:@"visit_ts"];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        visit.date = [dateFormatter dateFromString:visitDateString];

        NSNumber* userId = [obj objectForKey:@"user_id"];
        visit.user = [self findUserById:userId.integerValue inMainContext:NO];

        NSNumber* pharmacyId = [obj objectForKey:@"pharm_id"];
        visit.pharmacy = [self findPharmacyById:pharmacyId.integerValue];
        
        NSNumber* circleParticipants = [obj objectForKey:@"circle_participants"];
        if (circleParticipants.integerValue > 0)
        {
            visit.pharmacyCircle = [NSEntityDescription
                     insertNewObjectForEntityForName:@"PharmacyCircle"
                     inManagedObjectContext:self.childManagedObjectContext];
            visit.pharmacyCircle.participants = circleParticipants;
        }
        
        NSNumber* promoParticipants = [obj objectForKey:@"promo_participants"];
        if (promoParticipants.integerValue > 0)
        {
            visit.promoVisit = [NSEntityDescription
                                    insertNewObjectForEntityForName:@"PromoVisit"
                                    inManagedObjectContext:self.childManagedObjectContext];
            visit.promoVisit.participants = promoParticipants;
        }
        
        visit.closed = @YES;
        visit.sent = @YES;
    }
    User* currentUser = [self findUserById:self.currentUserId inMainContext:NO];
    currentUser.visitDate = [dict objectForKey:@"date"];
    [self saveChildContext];
}

- (void)parseVisitSale:(NSDictionary*)dict
{
    NSArray* addArray = [dict objectForKey:@"add"];
    for (NSDictionary* obj in addArray)
    {
        NSNumber* visitId = [obj objectForKey:@"visit_id"];
        
        Visit* visit = [self findVisitByServerId:visitId.integerValue];
        if (visit)
        {
            NSLog(@"User for visit = %@", visit.user.name);
            NSLog(@"Pharmacy for visit = %@", visit.pharmacy.name);
            if (!visit.commerceVisit)
            {
                visit.commerceVisit = [NSEntityDescription
                                       insertNewObjectForEntityForName:@"CommerceVisit"
                                       inManagedObjectContext:self.childManagedObjectContext];
            }
            NSNumber* doseId = [obj objectForKey:@"preparat_dose_id"];
            Sale* sale = [self findSaleInVisit:visit byDoseId:doseId.integerValue];
            if (!sale)
            {
            
                sale = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Sale"
                        inManagedObjectContext:self.childManagedObjectContext];
                sale.dose = [self findDoseById:doseId.integerValue];
            }
            if ([obj objectForKey:@"rest_have"] == [NSNull null])
            {
                sale.remainder = [obj objectForKey:@"rest_amount"];
            }
            else
            {
                sale.remainder = @-1;
            }
            if ([obj objectForKey:@"msg"] != [NSNull null])
                sale.comment = [obj objectForKey:@"msg"];
            [visit.commerceVisit addSalesObject:sale];
        }
    }
    //Deleting not implemented for this method
    [self saveChildContext];
}

#pragma mark local json load methods
- (void)parseRegionLocal
{
    NSString* usersFile = [[NSBundle mainBundle]pathForResource:@"Region" ofType:@"json"];
    NSData* usersData = [NSData dataWithContentsOfFile:usersFile];
    NSDictionary* usersJSON = [NSJSONSerialization JSONObjectWithData:usersData options:kNilOptions error:nil];
    NSDictionary* dic = [usersJSON objectForKey:@"Region"];
    [self parseRegion:dic];
}

- (void)parseUserLocal
{
    NSString* usersFile = [[NSBundle mainBundle]pathForResource:@"User" ofType:@"json"];
    NSData* usersData = [NSData dataWithContentsOfFile:usersFile];
    NSDictionary* usersJSON = [NSJSONSerialization JSONObjectWithData:usersData options:kNilOptions error:nil];
    NSDictionary* dic = [usersJSON objectForKey:@"User"];
    [self parseUser:dic];
}

- (void)parseUserRegionLocal
{
    NSString* usersFile = [[NSBundle mainBundle]pathForResource:@"UserRegion" ofType:@"json"];
    NSData* usersData = [NSData dataWithContentsOfFile:usersFile];
    NSDictionary* usersJSON = [NSJSONSerialization JSONObjectWithData:usersData options:kNilOptions error:nil];
    NSDictionary* dic = [usersJSON objectForKey:@"UserRegion"];
    [self parseUserRegion:dic];
}

- (void)parsePreparatLocal
{
    NSString* usersFile = [[NSBundle mainBundle]pathForResource:@"Preparat" ofType:@"json"];
    NSData* usersData = [NSData dataWithContentsOfFile:usersFile];
    NSDictionary* usersJSON = [NSJSONSerialization JSONObjectWithData:usersData options:kNilOptions error:nil];
    NSDictionary* dic = [usersJSON objectForKey:@"Preparat"];
    [self parsePreparat:dic];
}

- (void)parsePreparatDoseLocal
{
    NSString* usersFile = [[NSBundle mainBundle]pathForResource:@"PreparatDose" ofType:@"json"];
    NSData* usersData = [NSData dataWithContentsOfFile:usersFile];
    NSDictionary* usersJSON = [NSJSONSerialization JSONObjectWithData:usersData options:kNilOptions error:nil];
    NSDictionary* dic = [usersJSON objectForKey:@"PreparatDose"];
    [self parsePreparatDose:dic];
}

- (void)parsePharmLocal
{
    NSString* usersFile = [[NSBundle mainBundle]pathForResource:@"Pharm" ofType:@"json"];
    NSData* usersData = [NSData dataWithContentsOfFile:usersFile];
    NSDictionary* usersJSON = [NSJSONSerialization JSONObjectWithData:usersData options:kNilOptions error:nil];
    NSDictionary* dic = [usersJSON objectForKey:@"Pharm"];
    [self parsePharm:dic];
}

- (void)parseVisitLocal
{
    NSString* visitsFile = [[NSBundle mainBundle]pathForResource:@"Visit" ofType:@"json"];
    NSData* visitsData = [NSData dataWithContentsOfFile:visitsFile];
    NSDictionary* visitsJSON = [NSJSONSerialization JSONObjectWithData:visitsData options:kNilOptions error:nil];
    NSDictionary* dic = [visitsJSON objectForKey:@"Visit"];
    [self parseVisit:dic];
}

- (void)parseVisitSaleLocal
{
    NSString* salesFile = [[NSBundle mainBundle]pathForResource:@"VisitSale" ofType:@"json"];
    NSData* salesData = [NSData dataWithContentsOfFile:salesFile];
    NSDictionary* salesJSON = [NSJSONSerialization JSONObjectWithData:salesData options:kNilOptions error:nil];
    NSDictionary* dic = [salesJSON objectForKey:@"VisitSale"];
    [self parseVisitSale:dic];
}

- (void)recalculateVisitsCount
{
    NSDateComponents* todayComponents = [[NSCalendar currentCalendar]components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger currentMonth = todayComponents.month;
    NSInteger quarter = currentMonth / 3 + 1;
    NSDateComponents* startComponents = [[NSDateComponents alloc]init];
    NSDateComponents* endComponents = [[NSDateComponents alloc]init];
    startComponents.month = (quarter - 1) * 3 + 1;
    endComponents.month = (quarter - 1) * 3 + 4;
    startComponents.day = endComponents.day = 1;
    startComponents.hour = endComponents.hour = 0;
    startComponents.minute = endComponents.minute = 0;
    startComponents.second = endComponents.second = 0;
    startComponents.year = endComponents.year = todayComponents.year;
    //startComponents.year = endComponents.year - 10; //TODO: just for test, delete it later!
    NSDate* startDate = [[NSCalendar currentCalendar]dateFromComponents:startComponents];
    NSDate* endDate = [[NSCalendar currentCalendar]dateFromComponents:endComponents];
    
    if ([endDate compare:[NSDate currentDate]] == NSOrderedDescending)
    {
        endDate = [NSDate currentDate];
    }
    
    NSArray* pharmacies = [self pharmaciesForUser:self.currentUser];
    for (Pharmacy* pharmacy in pharmacies)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"date>=%@ && date < %@ && user=%@", startDate, endDate, self.currentUser];
        NSArray* visitsForQuarter = [pharmacy.visits.allObjects filteredArrayUsingPredicate:predicate];
        pharmacy.visitsInQuarter = @(visitsForQuarter.count);
    }
    
    //Is it correct that we share this variable between threads? Shoud we use main queue?
    self.syncInProgress = NO;
}

#pragma mark standard AppDelegate methods
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if (!self.syncInProgress)
    {
        self.syncInProgress = YES;
        [self syncDataWithServer];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
- (void)showLoader
{
    return;
    self.loader = [[NSBundle mainBundle]loadNibNamed:@"SyncLoader" owner:self options:nil][0];
    self.loader.frame = CGRectMake(0, 0, 1024, 768);
    [self.container.view addSubview:self.loader];
    [self.loader.activityIndicator startAnimating];
}
- (void)hideLoader
{
    return;
    [self.loader.activityIndicator stopAnimating];
    [self.loader removeFromSuperview];
}*/
@end