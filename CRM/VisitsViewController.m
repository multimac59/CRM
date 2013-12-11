//
//  VisitsViewController.m
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "VisitsViewController.h"
#import "AppDelegate.h"
#import "Visit.h"
#import "Conference.h"
#import "VisitViewController.h"
#import "ChoiseTableController.h"
#import "Pharmacy.h"

@interface VisitsViewController ()
@property (nonatomic, strong) NSMutableArray* visits;
@property (nonatomic, strong) NSMutableArray* conferences;
@property (nonatomic, strong) NSMutableArray* visitsAndConferences;
@property (nonatomic, strong) UIPopoverController* popover;
@property (nonatomic, strong) NSDate* filterDate;
@end

@implementation VisitsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)date:(NSDate*)date1 equalToDate:(NSDate*)date2
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger comps = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
    
    NSDateComponents *date1Components = [calendar components:comps
                                                    fromDate: date1];
    NSDateComponents *date2Components = [calendar components:comps
                                                    fromDate: date2];
    
    date1 = [calendar dateFromComponents:date1Components];
    date2 = [calendar dateFromComponents:date2Components];
    
    NSComparisonResult result = [date1 compare:date2];
    if (result == NSOrderedSame)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    ChoiseTableController* choiseTableController = [ChoiseTableController new];
    choiseTableController.delegate = self;
    self.popover = [[UIPopoverController alloc]initWithContentViewController:choiseTableController];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Clear Filter" style:UIBarButtonSystemItemAdd target:self action:@selector(clearFilter)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonSystemItemAdd target:self action:@selector(showPopover)];
    self.navigationItem.title = @"Визиты";
    [self loadAll];
    [self filterVisits];
}

- (void)clearFilter
{
    self.filterDate = nil;
    [self filterVisits];
    [self.table reloadData];
}

- (void)loadAll
{
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Visit" inManagedObjectContext:context]];
    NSError *error = nil;
    _visits = [[context executeFetchRequest:request error:&error]mutableCopy];
    
    [request setEntity:[NSEntityDescription entityForName:@"Conference" inManagedObjectContext:context]];
    _conferences = [[context executeFetchRequest:request error:&error]mutableCopy];
}

- (void)filterVisits
{
    _visitsAndConferences = [NSMutableArray new];
    // Use predicate instead
    [self.visits enumerateObjectsUsingBlock:^(Visit* visit, NSUInteger idx, BOOL *stop) {
        if (visit.user.userId.integerValue == [AppDelegate sharedDelegate].currentUser.userId.integerValue)
        {
            if (self.filterDate == nil || [self date:self.filterDate equalToDate:visit.date])
                [self.visitsAndConferences addObject:visit];
        }
    }];
    
    //Not optimal, too many requests to database
    
    [self.conferences enumerateObjectsUsingBlock:^(Conference* conference, NSUInteger idx, BOOL *stop) {
        if (conference.user.userId.integerValue == [AppDelegate sharedDelegate].currentUser.userId.integerValue)
        {
            if (self.filterDate == nil || [self date:self.filterDate equalToDate:conference.date])
                [self.visitsAndConferences addObject:conference];
        }
    }];
    [self.visits sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate* date1 = [obj1 date];
        NSDate* date2 = [obj2 date];
        if (date1 > date2)
            return NSOrderedAscending;
        else if (date1 < date2)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.visitsAndConferences.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSObject* object = self.visitsAndConferences[indexPath.row];
    if ([object isKindOfClass:[Visit class]])
    {
        Visit* visit = (Visit*)object;
        cell.textLabel.text = visit.pharmacy.name;
    }
    else
    {
        Conference* conference = (Conference*)object;
        cell.textLabel.text = conference.name;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController* hostController = [AppDelegate sharedDelegate].visitsSplitController.viewControllers[1];
    [hostController popToRootViewControllerAnimated:NO];
    VisitViewController* visitViewController = (VisitViewController*)hostController.topViewController;
    NSLog(@"Clicked, row = %ld", (long)indexPath.row);
    NSObject* object = self.visitsAndConferences[indexPath.row];
    if ([object isKindOfClass:[Visit class]])
    {
        Visit* visit = (Visit*)object;
        [visitViewController showVisit:visit];

    }
    else
    {
        Conference* conference = (Conference*)object;
        [visitViewController showConference:conference];
        
    }
}

- (void)showPopover
{
    [[self popover]presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)addVisit
{
    NewVisitViewController* visitViewController = [NewVisitViewController new];
    visitViewController.isConference = NO;
    visitViewController.delegate = self;
    UINavigationController* hostingController = [[UINavigationController alloc]initWithRootViewController:visitViewController];
    hostingController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:hostingController animated:YES completion:nil];
}

- (void)addConference
{
    NewVisitViewController* visitViewController = [NewVisitViewController new];
    visitViewController.isConference = YES;
    visitViewController.delegate = self;
    UINavigationController* hostingController = [[UINavigationController alloc]initWithRootViewController:visitViewController];
    hostingController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:hostingController animated:YES completion:nil];
}

- (void)choiseTableController:(ChoiseTableController *)choiseTableController didFinishWithResult:(NSInteger)result
{
    [self.popover dismissPopoverAnimated:YES];
    if (result == 1)
    {
        [self addVisit];
    }
    else
    {
        [self addConference];
    }
}

- (void)newVisitViewController:(NewVisitViewController *)newVisitViewController didAddConference:(Conference *)conference
{
    [self.conferences addObject:conference];
    [self filterVisits];
    [self.table reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)newVisitViewController:(NewVisitViewController *)newVisitViewController didAddVisit:(Visit *)visit
{
    [self.visits addObject:visit];
    [self filterVisits];
    [self.table reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeFilterDate:(id)sender
{
    self.filterDate = self.datePicker.date;
    [self filterVisits];
    [self.table reloadData];
}
@end
