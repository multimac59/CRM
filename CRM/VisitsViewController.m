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
@property (nonatomic, strong) NSDate* filterDate;
@property (nonatomic) BOOL calendarOn;
@property (nonatomic, strong) NSIndexPath* selectedIndexPath;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd.MM.yyyy";
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"Ru-ru"];
    self.dateLabel.text = [dateFormatter stringFromDate:self.filterDate];

    [self setupCalendar];
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.calendarWidget.frame = CGRectMake(0, self.view.frame.size.height - delta, panelWidth, calendarHeight);
    self.calendarHeader.frame = CGRectMake(0, self.view.frame.size.height - headerHeight - delta, panelWidth, headerHeight);
    self.table.frame = CGRectMake(0, filterHeight, panelWidth, self.view.frame.size.height - filterHeight - headerHeight - delta);
    self.calendarOn = NO;
}

- (void)reloadData
{
    [self loadVisits];
    [self sortVisits];
    [self.table reloadData];
    [self selectFirstFromList];
}

- (void)loadVisits
{
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Visit" inManagedObjectContext:context]];
    NSError *error = nil;
    
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
        request.predicate = compoundPredicate;
    }
    else
    {
        request.predicate = filterByUserPredicate;
    }
    
    _visits = [[context executeFetchRequest:request error:&error]mutableCopy];
}

- (void)sortVisits
{
    
    NSSortDescriptor* statusDescriptor = [[NSSortDescriptor alloc]initWithKey:@"pharmacy.status" ascending:NO];
    NSSortDescriptor* visitsDescriptor = [[NSSortDescriptor alloc]initWithKey:@"pharmacy.visitsInCurrentQuarter.@count" ascending:YES];
    [self.visits sortUsingDescriptors:@[statusDescriptor, visitsDescriptor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark table methods

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
    
    if (indexPath.row == self.selectedIndexPath.row)
    {
        cell.triangle.hidden = NO;
        cell.contentView.backgroundColor = [UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:1];
    }
    else
    {
        cell.contentView.backgroundColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
        cell.triangle.hidden = YES;
    }
    
    Visit* visit = self.visits[indexPath.row];
    [cell setupCellWithPharmacy:visit.pharmacy andVisit:visit];
    [cell disableButtons];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectVisitAtIndexPath:indexPath];
}

- (void)selectVisitAtIndexPath:(NSIndexPath*)indexPath
{
    self.selectedIndexPath = indexPath;
    Visit* visit = self.visits[indexPath.row];
    
    //Setup map
    NSMutableArray* allPharmacies = [NSMutableArray new];
    for (Visit* visit in self.visits)
    {
        [allPharmacies addObject:visit.pharmacy];
    }
    self.visitViewController.allPharmacies = allPharmacies;
    self.visitViewController.selectedPharmacy = visit.pharmacy;
    self.visitViewController.planDate = self.filterDate;

    //Show visit
    [self.visitViewController showVisit:visit];
    
    [self.table reloadData];
}

- (void)selectFirstFromList
{
    if (self.visits.count > 0)
        [self selectVisitAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

#pragma mark calendar
- (void)setupCalendar
{
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
                [Flurry logEvent:@"Календарь" withParameters:@{@"Действие" : @"Открыть", @"Метод" : @"Свайп", @"Экран" : @"Визиты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
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
                [Flurry logEvent:@"Календарь" withParameters:@{@"Действие" : @"Закрыть", @"Метод" : @"Свайп", @"Экран" : @"Визиты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
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

- (void)toggleCalendar
{
    if (self.calendarOn)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.calendarWidget.frame = CGRectMake(0, self.view.frame.size.height - delta, panelWidth, calendarHeight);
            self.calendarHeader.frame = CGRectMake(0, self.view.frame.size.height - headerHeight - delta, panelWidth, headerHeight);
            self.table.frame = CGRectMake(0, filterHeight, panelWidth, self.view.frame.size.height - filterHeight - headerHeight - delta);
        } completion:^(BOOL finished) {
            [Flurry logEvent:@"Календарь" withParameters:@{@"Действие" : @"Закрыть", @"Метод" : @"Тап", @"Экран" : @"Визиты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
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
            [Flurry logEvent:@"Календарь" withParameters:@{@"Действие" : @"Открыть", @"Метод" : @"Тап", @"Экран" : @"Визиты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
            self.calendarOn = YES;
        }];
    }
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date
{
    [self toggleCalendar];
    
    self.filterDate = date;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd.MM.yyyy";
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"Ru-ru"];
    self.dateLabel.text = [dateFormatter stringFromDate:self.filterDate];
    
    [self reloadData];
    
     [Flurry logEvent:@"Выбор даты" withParameters:@{@"Выбранная дата" : date, @"Экран" : @"Визиты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
}
@end