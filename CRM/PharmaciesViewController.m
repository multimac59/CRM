//
//  ClientsViewController.m
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "PharmaciesViewController.h"
#import "PharmacyViewController.h"
#import "AppDelegate.h"
#import "Pharmacy.h"
#import "VisitsCell.h"
#import "Visit.h"
#import "Pharmacy+QuarterVisits.h"
#import "PromoVisit.h"
#import "CommerceVisit.h"
#import "PharmacyCircle.h"
#import "NSDate+Additions.h"
#import "User.h"
#import "VisitManager.h"

@interface PharmaciesViewController ()
{
    BOOL planned;
    BOOL targetable;
    
    int delta;
}
@property (nonatomic, strong) NSDate* selectedDate;
@property (nonatomic, strong) NSMutableArray* pharmacies;

@property (nonatomic, strong) NSString* filterString;

@property (nonatomic, strong) IBOutlet UITextField* filterField;

@property (nonatomic) BOOL calendarOn;

@property (nonatomic, strong) NSIndexPath* selectedIndexPath;

@property (nonatomic, weak) IBOutlet UILabel* targetLabel;

@end

@implementation PharmaciesViewController
static const int panelWidth = 320;
static const int calendarHeight = 226;
static const int headerHeight = 46;
static const int filterHeight = 110;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        planned = NO; //Выбранные
        targetable = NO; //Таргетные
        self.selectedDate = [NSDate currentDate]; //На текущую дату
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeFromFavourites:) name:@"RemoveFromFavourites" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadData:) name:@"VisitsUpdated" object:nil];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.calendarWidget = [[CKCalendarView alloc]init];
    self.calendarWidget.dayOfWeekTextColor = [UIColor whiteColor];
    self.calendarWidget.dateOfWeekFont = [UIFont systemFontOfSize:10];
    self.calendarWidget.dateFont = [UIFont systemFontOfSize:15];
    [self.view addSubview:self.calendarWidget];
    self.calendarWidget.delegate = self;
    [self.calendarWidget selectDate:[NSDate currentDate] makeVisible:YES];
    
    UIPanGestureRecognizer* panRecognizer1 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveCalendar:)];
    [self.calendarHeader addGestureRecognizer:panRecognizer1];
    UIPanGestureRecognizer* panRecognizer2 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveCalendar:)];
    [self.calendarWidget addGestureRecognizer:panRecognizer2];
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toggleCalendar)];
    [self.calendarHeader addGestureRecognizer:tapRecognizer];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd.MM.yyyy";
    self.dateLabel.text = [dateFormatter stringFromDate:self.selectedDate];
    
    self.filterString = @"";
    
    [self reloadData];
    [self selectFirstFromList];
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        delta = 20;
    }
    else
    {
        delta = 0;
    }
}

- (void)reloadData:(id)sender
{
    [self.table reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.calendarWidget.frame = CGRectMake(0, self.view.frame.size.height - delta, panelWidth, calendarHeight);
    self.calendarHeader.frame = CGRectMake(0, self.view.frame.size.height - headerHeight - delta, panelWidth, headerHeight);
    self.table.frame = CGRectMake(0, filterHeight, panelWidth, self.view.frame.size.height - filterHeight - headerHeight - delta);
    self.calendarOn = NO;
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
                //[Flurry logEvent:@"Календарь" withParameters:@{@"Действие" : @"Открыть", @"Метод" : @"Свайп", @"Экран" : @"Клиенты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
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
               // [Flurry logEvent:@"Календарь" withParameters:@{@"Действие" : @"Закрыть", @"Метод" : @"Свайп", @"Экран" : @"Клиенты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
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
    }
}

- (void)toggleCalendar
{
    NSLog(@"%f", self.view.frame.size.height);
    if (self.calendarOn)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.calendarWidget.frame = CGRectMake(0, self.view.frame.size.height - delta, panelWidth, calendarHeight);
            self.calendarHeader.frame = CGRectMake(0, self.view.frame.size.height - headerHeight - delta, panelWidth, headerHeight);
            self.table.frame = CGRectMake(0, filterHeight, panelWidth, self.view.frame.size.height - filterHeight - headerHeight - delta);
        } completion:^(BOOL finished) {
           // [Flurry logEvent:@"Календарь" withParameters:@{@"Действие" : @"Закрыть", @"Метод" : @"Тап", @"Экран" : @"Клиенты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
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
           // [Flurry logEvent:@"Календарь" withParameters:@{@"Действие" : @"Открыть", @"Метод" : @"Тап", @"Экран" : @"Клиенты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
            self.calendarOn = YES;
        }];
    }
}

- (void)selectFirstFromList
{
    if (self.pharmacies.count <= 0)
        return;
    Pharmacy* pharmacy = self.pharmacies[0];
    self.pharmacyViewController.allPharmacies = self.pharmacies;
    self.pharmacyViewController.planDate = self.selectedDate;
    [self.pharmacyViewController showPharmacy:pharmacy];
    [self.table selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pharmacies.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VisitsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"VisitsCell"];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"VisitsCell" owner:self options:nil]objectAtIndex:0];
    }
    
    if (indexPath.row == self.selectedIndexPath.row)
        cell.triangleImage.hidden = NO;
    else
        cell.triangleImage.hidden = YES;
    
    Pharmacy* pharmacy = self.pharmacies[indexPath.row];
    Visit* visit = [self visitInPharmacy:pharmacy forDate:self.selectedDate];
    [cell setupCellWithPharmacy:pharmacy andVisit:visit];
    if (pharmacy.status == NormalStatus)
    {
        //cell.pspView.hidden = YES;
        cell.pspView.frame = CGRectMake(15, 42, 30, 16);
    }
    else
    {
        cell.pspView.frame = CGRectMake(44, 42, 30, 16);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    Pharmacy* pharmacy = self.pharmacies[indexPath.row];
    UINavigationController* hostController = [AppDelegate sharedDelegate].clientsSplitController.viewControllers[1];
    PharmacyViewController* pharmacyViewController = (PharmacyViewController*)hostController.topViewController;
    [pharmacyViewController showPharmacy:pharmacy];
}

- (void)reloadData
{
    [self loadPharmacies];
    [self sortPharmacies];
    [self.table reloadData];
}

- (void)loadPharmacies
{
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Pharmacy" inManagedObjectContext:context]];
    
    NSMutableArray* filterPredicates = [NSMutableArray new];
    
    NSPredicate* userPredicate = [NSPredicate predicateWithFormat:@"region IN %@", [AppDelegate sharedDelegate].currentUser.regions];
    //[filterPredicates addObject:userPredicate];
    
    if (planned)
    {
        NSDate* startDate;
        [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&startDate interval:NULL forDate:self.selectedDate];
        //Add one day
        NSDateComponents *oneDay = [NSDateComponents new];
        oneDay.day = 1;
        NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:oneDay
                                                                        toDate:startDate
                                                                       options:0];
        NSPredicate* plannedPredicate = [NSPredicate predicateWithFormat:@"SUBQUERY(visits, $e, $e.date>=%@ && $e.date<%@ && $e.user.userId==%@).@count > 0", startDate, endDate, [AppDelegate sharedDelegate].currentUser.userId];
        [filterPredicates addObject:plannedPredicate];
    }
    if (targetable)
    {
        NSPredicate* targetablePredicate = [NSPredicate predicateWithFormat:@"ANY users==%@", [AppDelegate sharedDelegate].currentUser];
        [filterPredicates addObject:targetablePredicate];
    }
    
    NSArray* words = [self.filterString componentsSeparatedByString:@" "];
    for (NSString* word in words)
    {
        if (word.length > 0)
        {
            NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat:@"name contains[cd] $WORD OR city contains[cd] $WORD OR street contains[cd] $WORD OR house contains[cd] $WORD OR region.name contains[cd] $WORD"];
            NSPredicate *predicate = [predicateTemplate predicateWithSubstitutionVariables:@{@"WORD" : word}];
            [filterPredicates addObject:predicate];
        }
    }
    
    NSCompoundPredicate* predicate = [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates:filterPredicates];
    request.predicate = predicate;
    
    NSError *error = nil;
    self.pharmacies = [[context executeFetchRequest:request error:&error]mutableCopy];
}

- (void)sortPharmacies
{
    NSSortDescriptor* statusDescriptor = [[NSSortDescriptor alloc]initWithKey:@"status" ascending:NO];
    NSSortDescriptor* visitsDescriptor = [[NSSortDescriptor alloc]initWithKey:@"visitsInCurrentQuarter.@count" ascending:YES];
    [self.pharmacies sortUsingDescriptors:@[statusDescriptor, visitsDescriptor]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.filterField)
    {
        NSString* finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        self.filterString = finalString;
        //[Flurry logEvent:@"Фильтр" withParameters:@{@"Тип" : @"Поиск по строке", @"Состояние" : @"Да", @"Строка поиска" : finalString , @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
    }
    [self reloadData];
    return YES;
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date;
{
    self.selectedDate = date;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd.MM.yyyy";
    self.dateLabel.text = [dateFormatter stringFromDate:date];
    
    [self reloadData];
    
    //[Flurry logEvent:@"Выбор даты" withParameters:@{@"Выбранная дата" : date, @"Экран" : @"Клиенты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
    
    [self toggleCalendar];
}

- (IBAction)leftSegmentPressed:(id)sender
{
    if (planned)
    {
        [self.leftSegment setBackgroundImage:[UIImage imageNamed:@"leftPinkPressed"] forState:UIControlStateNormal];
        [self.rightSegment setBackgroundImage:[UIImage imageNamed:@"rightPink"] forState:UIControlStateNormal];
        [self.leftSegment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rightSegment setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        planned = NO;
        
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self reloadData];
        [self selectFirstFromList];
        
        //[Flurry logEvent:@"Фильтр" withParameters:@{@"Тип" : @"Выбранные", @"Состояние" : @"Нет", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
    }
}

- (IBAction)rightSegmentPressed:(id)sender
{
    if (!planned)
    {
        [self.leftSegment setBackgroundImage:[UIImage imageNamed:@"leftPink"] forState:UIControlStateNormal];
        [self.rightSegment setBackgroundImage:[UIImage imageNamed:@"rightPinkPressed"] forState:UIControlStateNormal];
        [self.leftSegment setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        [self.rightSegment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        planned = YES;
        
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self reloadData];
        [self selectFirstFromList];
        
        //[Flurry logEvent:@"Фильтр" withParameters:@{@"Тип" : @"Выбранные", @"Состояние" : @"Да", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
    }
}

- (void)removeFromFavourites:(NSNotification*)notification
{
    NSDate* startDate;
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&startDate interval:NULL forDate:self.selectedDate];
    //Add one day
    NSDateComponents *oneDay = [NSDateComponents new];
    oneDay.day = 1;
    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:oneDay
                                                                    toDate:startDate
                                                                   options:0];
    
    NSDictionary* dic = notification.userInfo;
    Pharmacy* pharmacy = [dic objectForKey:@"Pharmacy"];
    
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    for (Visit* visit in pharmacy.visits)
    {
        
        if ([visit.date compare:startDate] != NSOrderedAscending && [visit.date compare:endDate] == NSOrderedAscending && visit.user.userId == [AppDelegate sharedDelegate].currentUser.userId)
        {
            [context deleteObject:visit];
        }
    }
    self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self reloadData];
    [self selectFirstFromList];
}


- (IBAction)targetSwitched:(id)sender
{
    targetable = !targetable;
    
    if (targetable)
    {
        [self.targetButton setBackgroundImage:[UIImage imageNamed:@"targetBgPressed"] forState:UIControlStateNormal];
        //[Flurry logEvent:@"Фильтр" withParameters:@{@"Тип" : @"Таргентые", @"Состояние" : @"Да", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];

    }
    else
    {
        [self.targetButton setBackgroundImage:[UIImage imageNamed:@"targetBg"] forState:UIControlStateNormal];
        //[Flurry logEvent:@"Фильтр" withParameters:@{@"Тип" : @"Таргентые", @"Состояние" : @"Нет", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];

    }
    self.targetLabel.hidden = !targetable;
    [self reloadData];
}


#pragma mark helper methods

- (NSIndexPath*)indexPathForSender:(id)sender
{
    CGPoint center= ((UIButton*)sender).center;
    CGPoint rootViewPoint = [((UIButton*)sender).superview convertPoint:center toView:self.table];
    NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:rootViewPoint];
    return indexPath;
}

- (Visit*)visitInPharmacy:(Pharmacy*)pharmacy forDate:(NSDate*)date
{
    for (Visit* visit in pharmacy.visits)
    {
        //get date without time component. We don't need it in fact, because we already have it without time from calendar control
        NSDate* startDate;
        [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&startDate interval:NULL forDate:date];
        //Add one day
        NSDateComponents *oneDay = [NSDateComponents new];
        oneDay.day = 1;
        NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:oneDay
                                                                        toDate:startDate
                                                                       options:0];
        if ([visit.date compare:startDate] != NSOrderedAscending && [visit.date compare:endDate] == NSOrderedAscending && visit.user.userId == [AppDelegate sharedDelegate].currentUser.userId)
        {
            return visit;
        }
    }
    return nil;
}

- (Visit*)createVisitInPharamacy:(Pharmacy*)pharmacy forDate:(NSDate*)date
{
    Visit* visit = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Visit"
                    inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
    visit.pharmacy = pharmacy;
    visit.date = date;
    visit.user = [AppDelegate sharedDelegate].currentUser;
    visit.visitId = [[NSUUID UUID]UUIDString];
    visit.closed = @NO;
    [pharmacy addVisitsObject:visit];
    return visit;
}

#pragma mark plan buttons
- (IBAction)commerceVisitClicked:(id)sender
{
    NSIndexPath* indexPath = [self indexPathForSender:sender];
    Pharmacy* pharmacy = self.pharmacies[indexPath.row];
    [[VisitManager sharedManager]toggleCommerceVisitInPharmacy:pharmacy forDate:self.selectedDate];
    
    if (planned)
        [self reloadData];
    else
        [self.table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.pharmacyViewController reloadMap];
}

- (IBAction)promoVisitClicked:(id)sender
{
    NSIndexPath* indexPath = [self indexPathForSender:sender];
    Pharmacy* pharmacy = self.pharmacies[indexPath.row];
    [[VisitManager sharedManager]togglePromoVisitInPharmacy:pharmacy forDate:self.selectedDate];
    
    if (planned)
        [self reloadData];
    else
        [self.table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.pharmacyViewController reloadMap];
}

- (IBAction)pharmacyCircleClicked:(id)sender
{
    NSIndexPath* indexPath = [self indexPathForSender:sender];
    Pharmacy* pharmacy = self.pharmacies[indexPath.row];
    [[VisitManager sharedManager]togglePharmacyCircleInPharmacy:pharmacy forDate:self.selectedDate];
    
    if (planned)
        [self reloadData];
    else
        [self.table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.pharmacyViewController reloadMap];
}
@end