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
#import "Region.h"
#import "User.h"

@interface PharmaciesViewController ()
{
    BOOL planned;
    BOOL targetable;
    
    int delta;
}
@property (nonatomic, strong) NSMutableArray* pharmacies;

@property (nonatomic, strong) NSDate* selectedDate;
@property (nonatomic, strong) NSString* filterString;

@property (nonatomic) BOOL calendarOn;

@property (nonatomic, strong) NSIndexPath* selectedIndexPath;
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
        self.filterString = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.navigationController.navigationBar.translucent = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeFromFavourites:) name:@"RemoveFromFavourites" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadData) name:@"VisitsUpdated" object:nil];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd.MM.yyyy";
    self.dateLabel.text = [dateFormatter stringFromDate:self.selectedDate];
    
    [self setupCalendar];
    
    [self reloadData];
    [self selectFirstFromList];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.calendarWidget.frame = CGRectMake(0, self.view.frame.size.height - delta, panelWidth, calendarHeight);
    self.calendarHeader.frame = CGRectMake(0, self.view.frame.size.height - headerHeight - delta, panelWidth, headerHeight);
    self.table.frame = CGRectMake(0, filterHeight, panelWidth, self.view.frame.size.height - filterHeight - headerHeight - delta);
    self.calendarOn = NO;
    
    UIPanGestureRecognizer* panRecognizer1 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveCalendar:)];
    [self.calendarHeader addGestureRecognizer:panRecognizer1];
    UIPanGestureRecognizer* panRecognizer2 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveCalendar:)];
    [self.calendarWidget addGestureRecognizer:panRecognizer2];
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toggleCalendar)];
    [self.calendarHeader addGestureRecognizer:tapRecognizer];
}

#pragma mark pharmacies
- (void)reloadData
{
    [self loadPharmacies];
    [self sortPharmacies];
    [self.table reloadData];
}

- (void)reloadDataAndMap
{
    [self reloadData];
    self.pharmacyViewController.allPharmacies = [[self plannedPharmacies]mutableCopy];
    [self.pharmacyViewController reloadMap];
}

- (NSArray*)plannedPharmacies
{
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Pharmacy" inManagedObjectContext:context]];
    
    NSMutableArray* filterPredicates = [NSMutableArray new];
    
    if ([AppDelegate sharedDelegate].currentUser.regions.count > 0)
    {
        NSPredicate* userPredicate = [NSPredicate predicateWithFormat:@"region IN %@", [AppDelegate sharedDelegate].currentUser.regions];
        [filterPredicates addObject:userPredicate];
    }
    

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

    if (targetable)
    {
        NSPredicate* targetablePredicate = [NSPredicate predicateWithFormat:@"ANY users.userId==%@", [AppDelegate sharedDelegate].currentUser.userId] ;
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
    return [context executeFetchRequest:request error:&error];
}

- (void)loadPharmacies
{
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Pharmacy" inManagedObjectContext:context]];
    
    NSMutableArray* filterPredicates = [NSMutableArray new];
    
    if ([AppDelegate sharedDelegate].currentUser.regions.count > 0)
    {
        NSPredicate* userPredicate = [NSPredicate predicateWithFormat:@"region IN %@", [AppDelegate sharedDelegate].currentUser.regions];
        [filterPredicates addObject:userPredicate];
    }
    
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
        NSPredicate* targetablePredicate = [NSPredicate predicateWithFormat:@"ANY users.userId==%@", [AppDelegate sharedDelegate].currentUser.userId] ;
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
    NSSortDescriptor* nameDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
    NSSortDescriptor* streetDescriptor = [[NSSortDescriptor alloc]initWithKey:@"street" ascending:YES];
    [self.pharmacies sortUsingDescriptors:@[statusDescriptor, visitsDescriptor, nameDescriptor, streetDescriptor]];
}

#pragma mark table

- (void)selectFirstFromList
{
    if (self.pharmacies.count > 0)
        [self selectPharmacyAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    else
    {
        self.pharmacyViewController.allPharmacies = [NSMutableArray array];
        self.pharmacyViewController.planDate = self.selectedDate;
        self.pharmacyViewController.selectedPharmacy = nil;
        [self.pharmacyViewController reloadMap];
    }
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
    {
        cell.triangle.hidden = NO;
        cell.contentView.backgroundColor = [UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:1];
    }
    else
    {
        cell.contentView.backgroundColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
        cell.triangle.hidden = YES;
    }
    
    Pharmacy* pharmacy = self.pharmacies[indexPath.row];
    Visit* visit = [[VisitManager sharedManager] visitInPharmacy:pharmacy forDate:self.selectedDate];
    [cell setupCellWithPharmacy:pharmacy andVisit:visit];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectPharmacyAtIndexPath:indexPath];
}

- (void)selectPharmacyAtIndexPath:(NSIndexPath*)indexPath
{
    self.selectedIndexPath = indexPath;
    
    Pharmacy* pharmacy = self.pharmacies[indexPath.row];
    
    self.pharmacyViewController.allPharmacies = [[self plannedPharmacies]mutableCopy];
    self.pharmacyViewController.planDate = self.selectedDate;
    self.pharmacyViewController.selectedPharmacy = pharmacy;
    
    [self.pharmacyViewController showPharmacy:pharmacy];
    
    [self.table reloadData];
}


/*
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
            [[AppDelegate sharedDelegate]saveContext];
        }
    }
    [self reloadData];
    [self selectFirstFromList];
}*/


#pragma mark filters
- (IBAction)leftSegmentPressed:(id)sender
{
    if (planned)
    {
        [self.leftSegment setBackgroundImage:[UIImage imageNamed:@"leftPinkPressed"] forState:UIControlStateNormal];
        [self.rightSegment setBackgroundImage:[UIImage imageNamed:@"rightPink"] forState:UIControlStateNormal];
        [self.leftSegment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rightSegment setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        planned = NO;
        
        [self reloadData];
        [self selectFirstFromList];
        
        [Flurry logEvent:@"Фильтр" withParameters:@{@"Тип" : @"Выбранные", @"Состояние" : @"Нет", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
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
        
        [self reloadData];
        [self selectFirstFromList];
        
        [Flurry logEvent:@"Фильтр" withParameters:@{@"Тип" : @"Выбранные", @"Состояние" : @"Да", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
    }
}

- (IBAction)targetSwitched:(id)sender
{
    targetable = !targetable;
    
    if (targetable)
    {
        [self.targetButton setBackgroundImage:[UIImage imageNamed:@"targetBgPressed"] forState:UIControlStateNormal];
        [Flurry logEvent:@"Фильтр" withParameters:@{@"Тип" : @"Таргентые", @"Состояние" : @"Да", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
    }
    else
    {
        [self.targetButton setBackgroundImage:[UIImage imageNamed:@"targetBg"] forState:UIControlStateNormal];
        [Flurry logEvent:@"Фильтр" withParameters:@{@"Тип" : @"Таргентые", @"Состояние" : @"Нет", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
    }
    self.targetLabel.hidden = !targetable;
    
    [self reloadData];
    [self selectFirstFromList];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.filterField)
    {
        NSString* finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        self.filterString = finalString;
        [Flurry logEvent:@"Фильтр" withParameters:@{@"Тип" : @"Поиск по строке", @"Состояние" : @"Да", @"Строка поиска" : finalString , @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
    }
    [self reloadData];
    return YES;
}


#pragma mark helper methods
- (NSIndexPath*)indexPathForSender:(id)sender
{
    CGPoint center= ((UIButton*)sender).center;
    CGPoint rootViewPoint = [((UIButton*)sender).superview convertPoint:center toView:self.table];
    NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:rootViewPoint];
    return indexPath;
}

- (NSIndexPath*)indexPathForPharmacy:(Pharmacy*)pharmacy
{
    int index = [self.pharmacies indexOfObject:pharmacy];
    if (index != NSNotFound)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        return indexPath;
    }
    else
    {
        return nil;
    }
}

#pragma mark plan buttons
- (IBAction)commerceVisitClicked:(id)sender
{
    NSIndexPath* indexPath = [self indexPathForSender:sender];
    Pharmacy* pharmacy = self.pharmacies[indexPath.row];
    [[VisitManager sharedManager]toggleCommerceVisitInPharmacy:pharmacy forDate:self.selectedDate];
    if ([self indexPathForPharmacy:pharmacy])
    {
        [self selectPharmacyAtIndexPath:indexPath];
    }
    else
    {
        [self selectFirstFromList];
    }
}

- (IBAction)promoVisitClicked:(id)sender
{
    NSIndexPath* indexPath = [self indexPathForSender:sender];
    Pharmacy* pharmacy = self.pharmacies[indexPath.row];
    [[VisitManager sharedManager]togglePromoVisitInPharmacy:pharmacy forDate:self.selectedDate];
    if ([self indexPathForPharmacy:pharmacy])
    {
        [self selectPharmacyAtIndexPath:indexPath];
    }
    else
    {
        [self selectFirstFromList];
    }
}

- (IBAction)pharmacyCircleClicked:(id)sender
{
    NSIndexPath* indexPath = [self indexPathForSender:sender];
    Pharmacy* pharmacy = self.pharmacies[indexPath.row];
    [[VisitManager sharedManager]togglePharmacyCircleInPharmacy:pharmacy forDate:self.selectedDate];
    if ([self indexPathForPharmacy:pharmacy])
    {
        [self selectPharmacyAtIndexPath:indexPath];
    }
    else
    {
        [self selectFirstFromList];
    }
}


#pragma mark Calender
- (void)setupCalendar
{
    self.calendarWidget = [[CKCalendarView alloc]init];
    self.calendarWidget.dayOfWeekTextColor = [UIColor whiteColor];
    self.calendarWidget.dateOfWeekFont = [UIFont systemFontOfSize:10];
    self.calendarWidget.dateFont = [UIFont systemFontOfSize:15];
    [self.view addSubview:self.calendarWidget];
    self.calendarWidget.delegate = self;
    [self.calendarWidget selectDate:[NSDate currentDate] makeVisible:YES];
    
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
                [Flurry logEvent:@"Календарь" withParameters:@{@"Действие" : @"Открыть", @"Метод" : @"Свайп", @"Экран" : @"Клиенты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
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
                [Flurry logEvent:@"Календарь" withParameters:@{@"Действие" : @"Закрыть", @"Метод" : @"Свайп", @"Экран" : @"Клиенты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
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
            [Flurry logEvent:@"Календарь" withParameters:@{@"Действие" : @"Закрыть", @"Метод" : @"Тап", @"Экран" : @"Клиенты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
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
            [Flurry logEvent:@"Календарь" withParameters:@{@"Действие" : @"Открыть", @"Метод" : @"Тап", @"Экран" : @"Клиенты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
            self.calendarOn = YES;
        }];
    }
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date;
{
    [self toggleCalendar];
    
    self.selectedDate = date;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd.MM.yyyy";
    self.dateLabel.text = [dateFormatter stringFromDate:date];
    
    [self reloadData];
    [self selectFirstFromList];
    
    [Flurry logEvent:@"Выбор даты" withParameters:@{@"Выбранная дата" : date, @"Экран" : @"Клиенты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
}
@end