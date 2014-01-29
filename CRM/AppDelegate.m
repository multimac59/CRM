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
#import "CustomSplitController.h"
#import "MGSplitViewController.h"
#import "LoginViewController.h"

#import "Brand.h"
#import "Drug.h"
#import "Pharmacy.h"
#import "Visit.h"
#import "Conference.h"
#import "Sale.h"
#import "Participant.h"

#import "YandexMapKit.h"
#import "MapViewController.h"
#import "MGSplitDividerView.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static AppDelegate* sharedDelegate = nil;

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
    
    
    
    [self deleteAllObjects:@"Conference"];
    [self deleteAllObjects:@"Visit"];
    [self deleteAllObjects:@"Pharmacy"];
    [self deleteAllObjects:@"Drug"];
    [self deleteAllObjects:@"Sale"];
    [self deleteAllObjects:@"Participant"];
    [self deleteAllObjects:@"Brand"];
    [self deleteAllObjects:@"User"];
    sharedDelegate = self;
    
    [self parseBrands];
    [self parseDrugs];
    [self parseUsers];
    [self parsePharmacies];
    [self parseVisits];
    [self parseConferences];
    
    self.currentUser = [self findUserById:1];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    _visitsSplitController = [[MGSplitViewController alloc]init];
    //_visitsSplitController.dividerStyle = MGSplitViewDividerStylePaneSplitter;
    //_visitsSplitController.dividerView.hidden = YES;
    self.visitsSplitController.viewControllers = @[[[UINavigationController alloc]initWithRootViewController:[VisitsViewController new]],[[UINavigationController alloc]initWithRootViewController:[VisitViewController new]]];
    _clientsSplitController = [[MGSplitViewController alloc]init];
    self.clientsSplitController.viewControllers = @[[[UINavigationController alloc]initWithRootViewController:[PharmaciesViewController new]],[[UINavigationController alloc]initWithRootViewController:[PharmacyViewController new]]];

    _container = [MFSideMenuContainerViewController
                  containerWithCenterViewController:self.visitsSplitController
                                                    leftMenuViewController:nil
                                                    rightMenuViewController:nil];
    
    self.sidePanelController = [SidePanelController new];
    self.sidePanelController.delegate = self;
    self.sidePanelController.view.frame = CGRectMake(0, 0, 270, 768);
    self.overlay = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1024, 768)];
    self.overlay.backgroundColor = [UIColor blackColor];
    self.overlay.alpha = 0.8;
    [self.container.view addSubview:self.overlay];
    [self.container.view addSubview:self.sidePanelController.view];
    
    
    UIPanGestureRecognizer* gestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(movePanel:)];
    [self.sidePanelController.view addGestureRecognizer:gestureRecognizer];
    
    self.container.shadow.enabled = YES;
    self.container.menuSlideAnimationEnabled = NO;
    self.window.rootViewController = self.container;
    //self.window.rootViewController = [MapViewController new];
    [self.window makeKeyAndVisible];
    [self.container presentViewController:[LoginViewController new] animated:NO completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],UITextAttributeTextColor,
                                               [UIColor blackColor], UITextAttributeTextShadowColor,
                                               [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
    return YES;
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
            break;
    }
    //Seems that container removes panel after change in centerviewcontroller, so we reuse it here
    [self.container.view addSubview:self.overlay];
    [self.container.view addSubview:self.sidePanelController.view];
    [UIView animateWithDuration:0.3 animations:^{
        self.sidePanelController.view.frame = CGRectMake(-275, 0, 290, 768);
        self.overlay.alpha = 0;
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

- (NSMutableArray*)parseBrands
{
    NSString* brandsFile = [[NSBundle mainBundle]pathForResource:@"Brands" ofType:@"json"];
    NSData* brandsData = [NSData dataWithContentsOfFile:brandsFile];
    NSArray* brandsJSON = [NSJSONSerialization JSONObjectWithData:brandsData options:kNilOptions error:nil];
    NSMutableArray* brands = [NSMutableArray new];
    [brandsJSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         Brand* brand = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"Brand"
                                   inManagedObjectContext:self.managedObjectContext];
         brand.brandId = (NSNumber*)[obj objectForKey:@"id"];
         brand.name = [obj objectForKey:@"name"];
         [brands addObject:brand];
     }];
    NSError *error;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return brands;
}

- (NSMutableArray*)parseDrugs
{
    NSString* drugsFile = [[NSBundle mainBundle]pathForResource:@"Drugs" ofType:@"json"];
    NSData* drugsData = [NSData dataWithContentsOfFile:drugsFile];
    NSArray* drugsJSON = [NSJSONSerialization JSONObjectWithData:drugsData options:kNilOptions error:nil];
    NSMutableArray* drugs = [NSMutableArray new];
    [drugsJSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         Drug* drug = [NSEntityDescription
                         insertNewObjectForEntityForName:@"Drug"
                         inManagedObjectContext:self.managedObjectContext];
         drug.drugId = (NSNumber*)[obj objectForKey:@"id"];
         drug.name = [obj objectForKey:@"name"];
         [drugs addObject:drug];
     }];
    NSError *error;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return drugs;
}

- (NSMutableArray*)parsePharmacies
{
    NSString* pharmaciesFile = [[NSBundle mainBundle]pathForResource:@"Pharmacies" ofType:@"json"];
    NSData* pharmaciesData = [NSData dataWithContentsOfFile:pharmaciesFile];
    NSArray* pharmaciesJSON = [NSJSONSerialization JSONObjectWithData:pharmaciesData options:kNilOptions error:nil];
    NSMutableArray* pharmacies = [NSMutableArray new];
    [pharmaciesJSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         Pharmacy* pharmacy = [NSEntityDescription
                       insertNewObjectForEntityForName:@"Pharmacy"
                       inManagedObjectContext:self.managedObjectContext];
         pharmacy.pharmacyId = (NSNumber*)[obj objectForKey:@"id"];
         pharmacy.name = [obj objectForKey:@"name"];
         pharmacy.network = [obj objectForKey:@"network"];
         pharmacy.city = [obj objectForKey:@"city"];
         pharmacy.street = [obj objectForKey:@"street"];
         pharmacy.house = [obj objectForKey:@"house"];
         pharmacy.phone = [obj objectForKey:@"phone"];
         pharmacy.doctorName = [obj objectForKey:@"doctorName"];
         pharmacy.visits = [NSSet new];
         [pharmacies addObject:pharmacy];
     }];
    NSError *error;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return pharmacies;
}

- (NSMutableArray*)parseVisits
{
    NSString* visitsFile = [[NSBundle mainBundle]pathForResource:@"Visits" ofType:@"json"];
    NSData* visitsData = [NSData dataWithContentsOfFile:visitsFile];
    NSArray* visitsJSON = [NSJSONSerialization JSONObjectWithData:visitsData options:kNilOptions error:nil];
    NSMutableArray* visits = [NSMutableArray new];
    [visitsJSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         Visit* visit = [NSEntityDescription
                               insertNewObjectForEntityForName:@"Visit"
                               inManagedObjectContext:self.managedObjectContext];
         NSString* visitDateString = [obj objectForKey:@"date"];
         NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
         dateFormatter.dateFormat = @"dd.MM.yyyy HH:mm";
         visit.date = [dateFormatter dateFromString:visitDateString];
         visit.visitId = (NSNumber*)[obj objectForKey:@"id"];
         //TODO: fix it
         NSInteger userId = ((NSNumber*)[obj objectForKey:@"userId"]).integerValue;
         visit.user = [self findUserById:userId];
         visit.sales = [NSSet new];
         NSMutableArray* sales = [obj objectForKey:@"sales"];
         [sales enumerateObjectsUsingBlock:^(id saleObj, NSUInteger idx, BOOL *stop) {
             Sale* sale = [NSEntityDescription
                             insertNewObjectForEntityForName:@"Sale"
                             inManagedObjectContext:self.managedObjectContext];
             sale.saleId = (NSNumber*)[saleObj objectForKey:@"id"];
             //TODO: fix it
             NSInteger drugId = ((NSNumber*)[saleObj objectForKey:@"drug"]).integerValue;
             Drug* drug = [self findDrugById:drugId];
             sale.user = visit.user;
             sale.drug = drug;
             sale.order = (NSNumber*)[saleObj objectForKey:@"order"];
             sale.sold = (NSNumber*)[saleObj objectForKey:@"sold"];
             sale.remainder = (NSNumber*)[saleObj objectForKey:@"remainder"];
             sale.visit = visit;
             [visit addSalesObject:sale];
         }];
         
         //TODO: fix it
         NSInteger pharmacyId = ((NSNumber*)[obj objectForKey:@"pharmacy"]).integerValue;
         Pharmacy* pharmacy = [self findPharmacyById:pharmacyId];
         visit.pharmacy = pharmacy;
         [pharmacy addVisitsObject:visit];
         [visits addObject:visit];
     }];
    NSError *error;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return visits;
}

- (NSMutableArray*)parseConferences
{
    NSString* conferencesFile = [[NSBundle mainBundle]pathForResource:@"Conferences" ofType:@"json"];
    NSData* conferencesData = [NSData dataWithContentsOfFile:conferencesFile];
    NSArray* conferencesJSON = [NSJSONSerialization JSONObjectWithData:conferencesData options:kNilOptions error:nil];
    NSMutableArray* conferences = [NSMutableArray new];
    [conferencesJSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         Conference* conference = [NSEntityDescription
                         insertNewObjectForEntityForName:@"Conference"
                         inManagedObjectContext:self.managedObjectContext];
         NSString* visitDateString = [obj objectForKey:@"date"];
         NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
         dateFormatter.dateFormat = @"dd.MM.yyyy HH:mm";
         conference.date = [dateFormatter dateFromString:visitDateString];
         conference.conferenceId = (NSNumber*)[obj objectForKey:@"id"];
         //TODO: fix it
         NSInteger userId = ((NSNumber*)[obj objectForKey:@"userId"]).integerValue;
         conference.user = [self findUserById:userId];
         conference.name = [obj objectForKey:@"name"];
         conference.participants = [NSSet new];
         NSArray* participants = [obj objectForKey:@"participants"];
         [participants enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
             Participant* participant = [NSEntityDescription
                                       insertNewObjectForEntityForName:@"Participant"
                                       inManagedObjectContext:self.managedObjectContext];
             participant.name = name;
             [conference addParticipantsObject:participant];
         }];
         conference.brands = [NSSet new];
         NSMutableArray* brandIds = [obj objectForKey:@"brands"];
         [brandIds enumerateObjectsUsingBlock:^(NSNumber* brandObj, NSUInteger idx, BOOL *stop) {
             //TODO: fix it
             NSInteger brandId = brandObj.integerValue;
             Brand* brand = [self findBrandById:brandId];
             [conference addBrandsObject:brand];
         }];
         //TODO: fix it
         NSInteger pharmacyId = ((NSNumber*)[obj objectForKey:@"pharmacy"]).integerValue;
         Pharmacy* pharmacy = [self findPharmacyById:pharmacyId];
         conference.pharmacy = pharmacy;
         [conferences addObject:conference];
     }];
    NSError *error;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return conferences;
}

- (NSMutableArray*)parseUsers
{
    NSString* usersFile = [[NSBundle mainBundle]pathForResource:@"Users" ofType:@"json"];
    NSData* usersData = [NSData dataWithContentsOfFile:usersFile];
    NSMutableArray* usersJSON = [NSJSONSerialization JSONObjectWithData:usersData options:kNilOptions error:nil];
    NSMutableArray* users = [NSMutableArray new];
    [usersJSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        User* user = [NSEntityDescription
                                  insertNewObjectForEntityForName:@"User"
                                  inManagedObjectContext:self.managedObjectContext];
        user.userId = (NSNumber*)[obj objectForKey:@"id"];
        user.name = [obj objectForKey:@"name"];
        user.drugs = [NSSet new];
        NSMutableArray* drugIds = [obj objectForKey:@"drugs"];
        [drugIds enumerateObjectsUsingBlock:^(NSNumber* drugObj, NSUInteger idx, BOOL *stop) {
            //TODO: fix it
            NSInteger drugId = drugObj.integerValue;
            Drug* drug = [self findDrugById:drugId];
            [user addDrugsObject:drug];
        }];
        [users addObject:user];
    }];
    NSError *error;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return users;
}

- (Drug*)findDrugById:(NSInteger)drugId
{
    NSManagedObjectContext* context = self.managedObjectContext;
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

- (Brand*)findBrandById:(NSInteger)brandId
{
    NSManagedObjectContext* context = self.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Brand" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"brandId=%@", [NSNumber numberWithFloat:brandId]];
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
    NSManagedObjectContext* context = self.managedObjectContext;
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

- (User*)findUserById:(NSInteger)userId
{
    NSManagedObjectContext* context = self.managedObjectContext;
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (id)sharedDelegate
{
    
    if (sharedDelegate == nil) {
        sharedDelegate = [[super allocWithZone:NULL] init];
    }
    return sharedDelegate;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
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
        NSLog(@"Try to delete %@",entityDescription);
    }
    if (![self.managedObjectContext save:&error])
    {
    	NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
}
@end