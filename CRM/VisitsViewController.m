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
#import "VisitViewController.h"
#import "ChoiseTableController.h"
#import "Pharmacy.h"
#import "VisitsCell.h"
#import "NSDate+Additions.h"


@interface VisitsViewController ()
{
    int delta;
}
@property (nonatomic, strong) NSMutableArray* visits;
@property (nonatomic, strong) UIPopoverController* popover;
@property (nonatomic, strong) NSDate* filterDate;
@property (nonatomic, strong) CKCalendarView* calendarWidget;
@property (nonatomic) BOOL calendarOn;
@end

@implementation VisitsViewController
static const int panelWidth = 320;
static const int calendarHeight = 226;
static const int headerHeight = 46;
static const int filterHeight = 0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.filterDate = [NSDate currentDate];
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
    
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Clear Filter" style:UIBarButtonSystemItemAdd target:self action:@selector(clearFilter)];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonSystemItemAdd target:self action:@selector(showPopover)];
    self.navigationItem.title = @"Визиты";


    //[self performSelector:@selector(selectObjectAtIndex:) withObject:0 afterDelay:1];
    [self selectObjectAtIndex:0];
    [self.table selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    self.calendarWidget = [[CKCalendarView alloc]init];
    self.calendarWidget.dayOfWeekTextColor = [UIColor whiteColor];
    self.calendarWidget.dateOfWeekFont = [UIFont systemFontOfSize:10];
    self.calendarWidget.dateFont = [UIFont systemFontOfSize:15];
    [self.view addSubview:self.calendarWidget];
    self.calendarWidget.delegate = self;
    [self.calendarWidget selectDate:[NSDate currentDate] makeVisible:YES];
    
    UIPanGestureRecognizer* gestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveCalendar:)];
    [self.calendarHeader addGestureRecognizer:gestureRecognizer];
    UIPanGestureRecognizer* gestureRecognizer2 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveCalendar:)];
    [self.calendarWidget addGestureRecognizer:gestureRecognizer2];
    UITapGestureRecognizer* gestureRecognizer3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toggleCalendar)];
    [self.calendarHeader addGestureRecognizer:gestureRecognizer3];
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        delta = 20;
    }
    else
    {
        delta = 0;
    }
}

- (void)viewWillAppear:(BOOL)animated
{

    self.calendarWidget.frame = CGRectMake(0, self.view.frame.size.height - delta, panelWidth, calendarHeight);
    self.calendarHeader.frame = CGRectMake(0, self.view.frame.size.height - headerHeight - delta, panelWidth, headerHeight);
    self.table.frame = CGRectMake(0, filterHeight, panelWidth, self.view.frame.size.height - filterHeight - headerHeight - delta);
    
    self.calendarOn = NO;
    
    self.filterDate = [NSDate currentDate];
    
    [self.calendarWidget selectDate:self.filterDate makeVisible:NO];
    [self loadAll];
    [self filterVisits];
    [self.table reloadData];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd.MM.yyyy";
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"Ru-ru"];
    self.dateLabel.text = [dateFormatter stringFromDate:self.filterDate];
    
    [self selectFirstFromList];
}

- (void)moveCalendar:(UIPanGestureRecognizer*)recognizer
{
    CGPoint point = [recognizer locationInView:self.view];
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint velocity = [recognizer velocityInView:self.view];
        if (velocity.y < 0)
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.calendarWidget.frame = CGRectMake(0, self.view.frame.size.height - calendarHeight - delta, panelWidth, calendarHeight);
                self.calendarHeader.frame = CGRectMake(0, self.view.frame.size.height - calendarHeight - headerHeight - delta, panelWidth, headerHeight);
                self.table.frame = CGRectMake(0, filterHeight, panelWidth, self.view.frame.size.height - calendarHeight - headerHeight - filterHeight - delta);
            } completion:^(BOOL finished) {
                //[Flurry logEvent:@"Календарь" withParameters:@{@"Действие" : @"Открыть", @"Метод" : @"Свайп", @"Экран" : @"Визиты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
                self.calendarOn = YES;
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.calendarWidget.frame = CGRectMake(0, self.view.frame.size.height - delta, panelWidth, calendarHeight);
                self.calendarHeader.frame = CGRectMake(0, self.view.frame.size.height - headerHeight - delta, panelWidth, headerHeight);
                self.table.frame = CGRectMake(0, filterHeight, panelWidth, self.view.frame.size.height - filterHeight - headerHeight - delta);
            } completion:^(BOOL finished) {
                //[Flurry logEvent:@"Календарь" withParameters:@{@"Действие" : @"Закрыть", @"Метод" : @"Свайп", @"Экран" : @"Визиты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
                self.calendarOn = NO;
            }];
        }
    }
    else
    {
        int offset = self.view.frame.size.height - point.y;
        if (offset < 0 || offset > calendarHeight)
        return;
        self.calendarWidget.frame = CGRectMake(0, self.view.frame.size.height - offset - delta, panelWidth, calendarHeight);
        self.calendarHeader.frame = CGRectMake(0, self.view.frame.size.height - offset - headerHeight - delta, panelWidth, headerHeight);
        self.table.frame = CGRectMake(0, filterHeight, panelWidth, self.view.frame.size.height - offset - headerHeight - filterHeight - delta);
        
        //self.sidePanelController.view.frame = CGRectMake(point.x - 290, 0, 290, 768);
    }
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
}

- (void)filterVisits
{
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
        NSPredicate* datePredicate = [NSPredicate predicateWithFormat:@"(date>=%@) AND (date<%@)", startDate, endDate];
        NSPredicate* compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[filterByUserPredicate, datePredicate]];
        [self.visits filterUsingPredicate:compoundPredicate];
    }
    else
    {
        [self.visits filterUsingPredicate:filterByUserPredicate];
    }
    NSSortDescriptor* statusDescriptor = [[NSSortDescriptor alloc]initWithKey:@"pharmacy.status" ascending:NO];
    NSSortDescriptor* visitsDescriptor = [[NSSortDescriptor alloc]initWithKey:@"pharmacy.visitsInCurrentQuarter.@count" ascending:YES];
    [self.visits sortUsingDescriptors:@[statusDescriptor, visitsDescriptor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return self.visits.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        VisitsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"visitsCell"];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"VisitsCell" owner:self options:Nil]objectAtIndex:0];
        }
        Visit* visit = self.visits[indexPath.row];
        [cell setupCellWithPharmacy:visit.pharmacy andVisit:visit];
    if (visit.pharmacy.status == NormalStatus)
    {
        cell.pspView.frame = CGRectMake(15, 42, 30, 16);
    }
    else
    {
        cell.pspView.frame = CGRectMake(44, 42, 30, 16);
    }
    cell.commerceVisitButton.enabled = NO;
    cell.promoVisitButton.enabled = NO;
    cell.pharmacyCircleButton.enabled = NO;
        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectObjectAtIndex:indexPath.row];
}

- (void)selectObjectAtIndex:(NSInteger)index
{
    UINavigationController* hostController = [AppDelegate sharedDelegate].visitsSplitController.viewControllers[1];
    [hostController popToRootViewControllerAnimated:NO];
    VisitViewController* visitViewController = (VisitViewController*)hostController.topViewController;
    
    NSMutableArray* allPharmacies = [NSMutableArray new];
    for (Visit* visit in self.visits)
    {
        [allPharmacies addObject:visit.pharmacy];
    }
    visitViewController.allPharmacies = allPharmacies;
    visitViewController.planDate = self.filterDate;
    
    NSLog(@"Clicked, row = %ld", (long)index);
    NSObject* object = self.visits[index];

    Visit* visit = (Visit*)object;
    visitViewController.visit = visit;
    visitViewController.isConference = NO;

    [visitViewController reloadContent];
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date
{
    self.filterDate = date;
    //TODO: optimize it
    [self loadAll];
    [self filterVisits];
    [self.table reloadData];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd.MM.yyyy";
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"Ru-ru"];
    self.dateLabel.text = [dateFormatter stringFromDate:self.filterDate];
    
   // [Flurry logEvent:@"Выбор даты" withParameters:@{@"Выбранная дата" : date, @"Экран" : @"Визиты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
    [self toggleCalendar];
}

- (void)toggleCalendar
{
    if (self.calendarOn)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.calendarWidget.frame = CGRectMake(0, self.view.frame.size.height - delta, panelWidth, calendarHeight);
            self.calendarHeader.frame = CGRectMake(0, self.view.frame.size.height - headerHeight - delta, panelWidth, headerHeight);
            self.table.frame = CGRectMake(0, filterHeight, panelWidth, self.view.frame.size.height - filterHeight - headerHeight - delta);
        } completion:^(BOOL finished) {
           // [Flurry logEvent:@"Календарь" withParameters:@{@"Действие" : @"Закрыть", @"Метод" : @"Тап", @"Экран" : @"Визиты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
            self.calendarOn = NO;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.calendarWidget.frame = CGRectMake(0, self.view.frame.size.height - calendarHeight - delta, panelWidth, calendarHeight);
            self.calendarHeader.frame = CGRectMake(0, self.view.frame.size.height - calendarHeight - headerHeight - delta, panelWidth, headerHeight);
            self.table.frame = CGRectMake(0, filterHeight, panelWidth, self.view.frame.size.height - calendarHeight - headerHeight - filterHeight - delta);
        } completion:^(BOOL finished) {
           // [Flurry logEvent:@"Календарь" withParameters:@{@"Действие" : @"Открыть", @"Метод" : @"Тап", @"Экран" : @"Визиты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
            self.calendarOn = YES;
        }];
    }
}

- (void)selectFirstFromList
{
    if (self.visits.count > 0)
        [self selectObjectAtIndex:0];
}
@end