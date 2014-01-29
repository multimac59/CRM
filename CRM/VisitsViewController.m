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
#import "VisitsCell.h"


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

//Compare without time
//Maybe it's better to create extension NSDate -(NSComparisionResult)compare method and use it in sort descriptor?
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
    self.navigationController.navigationBar.translucent = NO;
    ChoiseTableController* choiseTableController = [ChoiseTableController new];
    choiseTableController.delegate = self;
    self.popover = [[UIPopoverController alloc]initWithContentViewController:choiseTableController];
    
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Clear Filter" style:UIBarButtonSystemItemAdd target:self action:@selector(clearFilter)];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonSystemItemAdd target:self action:@selector(showPopover)];
    UIButton* addButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
    [addButton setBackgroundImage:[UIImage imageNamed:@"addButtonPressed"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageNamed:@"addButton"] forState:UIControlStateHighlighted];
    [addButton addTarget:self action:@selector(showPopover) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:addButton];
    self.navigationItem.title = @"Визиты";
    [self loadAll];
    [self filterVisits];

    //[self performSelector:@selector(selectObjectAtIndex:) withObject:0 afterDelay:1];
    [self selectObjectAtIndex:0];
    [self.table selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    CKCalendarView* calendar = [[CKCalendarView alloc]init];
    calendar.dayOfWeekTextColor = [UIColor whiteColor];
    calendar.dateOfWeekFont = [UIFont systemFontOfSize:10];
    calendar.dateFont = [UIFont systemFontOfSize:15];
    CGRect frame = calendar.frame;
    frame.origin = CGPointMake(0, 412);
    calendar.frame = frame;
    [self.view addSubview:calendar];
    calendar.delegate = self;
    
    self.popoverView = [[NSBundle mainBundle]loadNibNamed:@"PopoverController" owner:self options:nil][0];
    //popover.frame = CGRectMake(220, 50, 168, 147);
    self.popoverView.frame = CGRectMake(0, 0, 1024, 768);
    AppDelegate* delegate = [AppDelegate sharedDelegate];
    [delegate.container.view addSubview:self.popoverView];
    self.popoverView.alpha = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    
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
    [_visitsAndConferences addObjectsFromArray:self.visits];
    [_visitsAndConferences addObjectsFromArray:self.conferences];
    NSPredicate* filterByUserPredicate = [NSPredicate predicateWithFormat:@"user.userId=%@", [AppDelegate sharedDelegate].currentUser.userId];
    if (self.filterDate)
    {
        //get date without time component. We don't need it in fact, because we already have it without time from calendar control
        NSDate* startDate;
        [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&startDate interval:NULL forDate:self.filterDate];
        //Add one day
        NSDateComponents *oneDay = [NSDateComponents new];
        oneDay.day = 1;
        NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:oneDay
                                                                        toDate:startDate
                                                                       options:0];
        NSPredicate* datePredicate = [NSPredicate predicateWithFormat:@"(date>=%@) AND (date<=%@)", startDate, endDate];
        NSPredicate* compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[filterByUserPredicate, datePredicate]];
        [_visitsAndConferences filterUsingPredicate:compoundPredicate];
    }
    else
    {
        [_visitsAndConferences filterUsingPredicate:filterByUserPredicate];
    }
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [_visitsAndConferences sortUsingDescriptors:@[sortDescriptor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.popoverTable)
        return 3;
    else
        return self.visitsAndConferences.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.popoverTable)
    {
        UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"popoverCell"];
        cell.textLabel.textColor = [UIColor colorWithRed:109/255.0 green:89/255.0 blue:137/255.0 alpha:1.0];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = @"Визит";
                break;
            case 1:
                cell.textLabel.text = @"Конференция";
                break;
            case 2:
                cell.textLabel.text = @"Фармкружок";
                break;
            default:
                break;
        }
        return cell;
    }
    else
    {
        VisitsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"visitsCell"];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"VisitsCell" owner:self options:Nil]objectAtIndex:0];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        NSObject* object = self.visitsAndConferences[indexPath.row];
        if ([object isKindOfClass:[Visit class]])
        {
            Visit* visit = (Visit*)object;
            cell.pharmacyLabel.text = visit.pharmacy.name;
            NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
            [timeFormatter setDateFormat:@"HH:mm"];
            cell.timeLabel.text = [timeFormatter stringFromDate:visit.date];
        }
        else
        {
            Conference* conference = (Conference*)object;
            cell.pharmacyLabel.text = conference.name;
            NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
            [timeFormatter setDateFormat:@"HH:mm"];
            cell.timeLabel.text = [timeFormatter stringFromDate:conference.date];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.popoverTable)
    {
        self.popoverView.alpha = 0;
        switch (indexPath.row)
        {
            case 0:
                [self addVisit];
                break;
            case 1:
                [self addConference];
                break;
            case 2:
                [self addConference];
                break;
            default:
                break;
        }
    }
    else
        [self selectObjectAtIndex:indexPath.row];
}

- (void)selectObjectAtIndex:(NSInteger)index
{
    UINavigationController* hostController = [AppDelegate sharedDelegate].visitsSplitController.viewControllers[1];
    [hostController popToRootViewControllerAnimated:NO];
    VisitViewController* visitViewController = (VisitViewController*)hostController.topViewController;
    NSLog(@"Clicked, row = %ld", (long)index);
    NSObject* object = self.visitsAndConferences[index];
    if ([object isKindOfClass:[Visit class]])
    {
        Visit* visit = (Visit*)object;
        visitViewController.visit = visit;
        visitViewController.isConference = NO;
        
    }
    else
    {
        Conference* conference = (Conference*)object;
        visitViewController.conference = conference;
        visitViewController.isConference = YES;
    }
    [visitViewController reloadContent];
}


- (void)showPopover
{
    AppDelegate* delegate = [AppDelegate sharedDelegate];
    [delegate.container.view bringSubviewToFront:self.popoverView];
    [UIView animateWithDuration:0.3 animations:^{
        self.popoverView.alpha = 1;
    }];
    //[[self popover]presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)addVisit
{
    NewVisitViewController* visitViewController = [NewVisitViewController new];
    visitViewController.isConference = NO;
    visitViewController.delegate = self;
    ModalNavigationController* hostingController = [[ModalNavigationController alloc]initWithRootViewController:visitViewController];
    hostingController.modalPresentationStyle = UIModalPresentationFormSheet;
    hostingController.modalWidth = 590;
    hostingController.modalHeight =750;
    [self presentViewController:hostingController animated:YES completion:nil];
}

- (void)addConference
{
    NewVisitViewController* visitViewController = [NewVisitViewController new];
    visitViewController.isConference = YES;
    visitViewController.delegate = self;
    ModalNavigationController* hostingController = [[ModalNavigationController alloc]initWithRootViewController:visitViewController];
    hostingController.modalPresentationStyle = UIModalPresentationFormSheet;
    hostingController.modalWidth = 590;
    hostingController.modalHeight =750;
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
    [[AppDelegate sharedDelegate]saveContext];
    [self filterVisits];
    [self.table reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)newVisitViewController:(NewVisitViewController *)newVisitViewController didAddVisit:(Visit *)visit
{
    [self.visits addObject:visit];
    [[AppDelegate sharedDelegate]saveContext];
    [self filterVisits];
    [self.table reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date
{
    self.filterDate = date;
    [self filterVisits];
    [self.table reloadData];
}

- (IBAction)hidePopover:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        self.popoverView.alpha = 0;
    }];
}
@end