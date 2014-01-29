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
#import "PharmaciesCell.h"
#import "Visit.h"
#import "Conference.h"


@interface PharmaciesViewController ()
{
    BOOL onlySelected;
    UIButton* searchButton;
    UIButton* calendarButton;
    BOOL selectFirst;
}
@property (nonatomic, strong) NSDate* selectedDate;
@property (nonatomic, strong) NSMutableArray* pharmacies;
@property (nonatomic, strong) NSMutableArray* sortedPharmacies;
@property (nonatomic, strong) NSArray* filteredPharmacies;

@property (nonatomic, strong) NSString* nameFilterString;
@property (nonatomic, strong) NSString* cityFilterString;
@property (nonatomic, strong) NSString* streetFilterString;
@property (nonatomic, strong) NSString* houseFilterString;

@property (nonatomic, strong) IBOutlet UITextField* nameFilter;
@property (nonatomic, strong) IBOutlet UITextField* cityFilter;
@property (nonatomic, strong) IBOutlet UITextField* streetFilter;
@property (nonatomic, strong) IBOutlet UITextField* houseFilter;

@property (nonatomic) BOOL filterOn;
@property (nonatomic) BOOL calendarOn;

@property (nonatomic, strong) NSIndexPath* selectedIndexPath;

@end

@implementation PharmaciesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        onlySelected = NO;
        self.selectedDate = [NSDate date];
    }
    return self;
}

- (void)setFilterOn:(BOOL)filterOn
{
    _filterOn = filterOn;
    if (!filterOn)
    {
        [searchButton setBackgroundImage:[UIImage imageNamed:@"searchButtonPressedBg"] forState:UIControlStateNormal];
        //[searchButton setBackgroundImage:[UIImage imageNamed:@"searchButtonPressedBg"] forState:UIControlStateHighlighted];
    }
    else
    {
        [searchButton setBackgroundImage:[UIImage imageNamed:@"searchButtonBg"] forState:UIControlStateNormal];
        //[searchButton setBackgroundImage:[UIImage imageNamed:@"searchButtonBg"] forState:UIControlStateHighlighted];
    }
}

- (void)setCalendarOn:(BOOL)calendarOn
{
    _calendarOn = calendarOn;
    if (!calendarOn)
    {
        [calendarButton setBackgroundImage:[UIImage imageNamed:@"calendarButtonPressedBg"] forState:UIControlStateNormal];
        //[calendarButton setBackgroundImage:[UIImage imageNamed:@"calendarButtonPressedBg"] forState:UIControlStateHighlighted];
    }
    else
    {
        [calendarButton setBackgroundImage:[UIImage imageNamed:@"calendarButtonBg"] forState:UIControlStateNormal];
        //[calendarButton setBackgroundImage:[UIImage imageNamed:@"calendarButtonBg"] forState:UIControlStateHighlighted];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd.MM.yy";
    self.title = [dateFormatter stringFromDate:self.selectedDate];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeFromFavourites:) name:@"RemoveFromFavourites" object:nil];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent = NO;
    
    searchButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 25)];
    //[searchButton setBackgroundImage:[UIImage imageNamed:@"searchButtonPressedBg"] forState:UIControlStateNormal];
    //[searchButton setBackgroundImage:[UIImage imageNamed:@"searchButtonBg"] forState:UIControlStateHighlighted];
    [searchButton addTarget:self action:@selector(toggleFilter) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem* searchButtonItem = [[UIBarButtonItem alloc]initWithCustomView:searchButton];
    
    calendarButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 25)];
    //[calendarButton setBackgroundImage:[UIImage imageNamed:@"calendarButtonBg"] forState:UIControlStateNormal];
    //[calendarButton setBackgroundImage:[UIImage imageNamed:@"calendarButtonPressedBg"] forState:UIControlStateHighlighted];
    [calendarButton addTarget:self action:@selector(toggleCalendar) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem* calendarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:calendarButton];
    
    self.navigationItem.rightBarButtonItems = @[searchButtonItem, calendarButtonItem];
    
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Pharmacy" inManagedObjectContext:context]];
    NSError *error = nil;
    _pharmacies = [[context executeFetchRequest:request error:&error]mutableCopy];
    [self sortPharmacies];
    
    self.nameFilterString = @"";
    self.cityFilterString = @"";
    self.streetFilterString = @"";
    self.houseFilterString = @"";
    [self filterPharmacies];
    
    [self selectFirstFromList];
    
    self.calendarWidget = [[CKCalendarView alloc]init];
    self.calendarWidget.dayOfWeekTextColor = [UIColor whiteColor];
    self.calendarWidget.dateOfWeekFont = [UIFont systemFontOfSize:10];
    self.calendarWidget.dateFont = [UIFont systemFontOfSize:15];
    self.calendarWidget.frame = CGRectMake(0, -300, 320, 300);
    [self.view addSubview:self.calendarWidget];
    self.calendarWidget.delegate = self;
    [self.calendarWidget selectDate:[NSDate date] makeVisible:YES];
    
    self.filterOn = YES;
    self.calendarOn = NO;
    
}

- (void)toggleFilter
{
    if (self.filterOn)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.filterView.frame = CGRectMake(0, -184, 320, 184);
            self.segmentedControl.frame = CGRectMake(69, 10, 183, 29);
            self.table.frame = CGRectMake(0, 44, 320, 540);
        } completion:^(BOOL finished) {
            self.filterOn = NO;
        }];
    }
    else
    {
        if (self.calendarOn)
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.calendarWidget.frame = CGRectMake(0, -300, 320, 300);
                self.segmentedControl.frame = CGRectMake(69, 10, 183, 29);
                self.table.frame = CGRectMake(0, 44, 320, 540);
            } completion:^(BOOL finished) {
                self.calendarOn = NO;
                [UIView animateWithDuration:0.3 animations:^{
                    self.filterView.frame = CGRectMake(0, 0, 320, 184);
                    self.segmentedControl.frame = CGRectMake(69, 10 + 184, 183, 29);
                    self.table.frame = CGRectMake(0, 44 + 184, 320, 540);
                } completion:^(BOOL finished) {
                    self.filterOn = YES;
                }];
            }];
        }
        else
        {
        [UIView animateWithDuration:0.3 animations:^{
            self.filterView.frame = CGRectMake(0, 0, 320, 184);
            self.segmentedControl.frame = CGRectMake(69, 10 + 184, 183, 29);
            self.table.frame = CGRectMake(0, 44 + 184, 320, 540);
        } completion:^(BOOL finished) {
            self.filterOn = YES;
        }];
        }
    }
}

- (void)toggleCalendar
{
    if (self.calendarOn)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.calendarWidget.frame = CGRectMake(0, -300, 320, 300);
            self.segmentedControl.frame = CGRectMake(69, 10, 183, 29);
            self.table.frame = CGRectMake(0, 44, 320, 540);
        } completion:^(BOOL finished) {
            self.calendarOn = NO;
        }];
    }
    else
    {
        if (self.filterOn)
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.filterView.frame = CGRectMake(0, -184, 320, 184);
                self.segmentedControl.frame = CGRectMake(69, 10, 183, 29);
                self.table.frame = CGRectMake(0, 44, 320, 540);
            } completion:^(BOOL finished) {
                self.filterOn = NO;
                [UIView animateWithDuration:0.3 animations:^{
                    self.calendarWidget.frame = CGRectMake(0, 0, 320, 300);
                    self.segmentedControl.frame = CGRectMake(69, 10 + 300, 183, 29);
                    self.table.frame = CGRectMake(0, 44 + 300, 320, 540);
                } completion:^(BOOL finished) {
                    self.calendarOn = YES;
                }];
            }];
        }
        else
        {
        [UIView animateWithDuration:0.3 animations:^{
            self.calendarWidget.frame = CGRectMake(0, 0, 320, 300);
            self.segmentedControl.frame = CGRectMake(69, 10 + 300, 183, 29);
            self.table.frame = CGRectMake(0, 44 + 300, 320, 540);
        } completion:^(BOOL finished) {
            self.calendarOn = YES;
        }];
        }
    }
}

- (void)selectFirstFromList
{
    if (self.filteredPharmacies.count <= 0)
        return;
    Pharmacy* pharmacy = self.filteredPharmacies[0];
    UINavigationController* hostController = [AppDelegate sharedDelegate].clientsSplitController.viewControllers[1];
    PharmacyViewController* pharmacyViewController = (PharmacyViewController*)hostController.topViewController;
    [pharmacyViewController showPharmacy:pharmacy];
    [self.table selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)sortPharmacies
{
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
    _sortedPharmacies = [[self.pharmacies sortedArrayUsingDescriptors:@[sortDescriptor]]mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredPharmacies.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PharmaciesCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PharmaciesCell"];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"PharmaciesCell" owner:self options:nil]objectAtIndex:0];
    }
    if (indexPath.row == self.selectedIndexPath.row)
    {
        cell.triangleImage.hidden = NO;
    }
    else
    {
        cell.triangleImage.hidden = YES;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    Pharmacy* pharmacy = self.filteredPharmacies[indexPath.row];
    cell.pharmacyLabel.text = pharmacy.name;
    
    if (onlySelected)
    {
        //cell.accessoryType = UITableViewCellAccessoryNone;
        cell.checkmark.hidden = YES;
        return cell;
    }
    
    //cell.accessoryType = UITableViewCellAccessoryNone;
    cell.checkmark.hidden = YES;
    for (Visit* visit in pharmacy.visits)
    {
        //get date without time component. We don't need it in fact, because we already have it without time from calendar control
        NSDate* startDate;
        [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&startDate interval:NULL forDate:self.selectedDate];
        //Add one day
        NSDateComponents *oneDay = [NSDateComponents new];
        oneDay.day = 1;
        NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:oneDay
                                                                        toDate:startDate
                                                                       options:0];
        if ([visit.date compare:startDate] != NSOrderedAscending && [visit.date compare:endDate] == NSOrderedAscending && visit.user.userId == [AppDelegate sharedDelegate].currentUser.userId)
        {
            //cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.checkmark.hidden = NO;
        }
    }
    for (Conference* conference in pharmacy.conferences)
    {
        //get date without time component. We don't need it in fact, because we already have it without time from calendar control
        NSDate* startDate;
        [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&startDate interval:NULL forDate:self.selectedDate];
        //Add one day
        NSDateComponents *oneDay = [NSDateComponents new];
        oneDay.day = 1;
        NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:oneDay
                                                                        toDate:startDate
                                                                       options:0];
       if ([conference.date compare:startDate] != NSOrderedAscending && [conference.date compare:endDate] == NSOrderedAscending && conference.user.userId == [AppDelegate sharedDelegate].currentUser.userId)
        {
            //cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.checkmark.hidden = NO;
        }
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    NSLog(@"Clicked, row = %ld", (long)indexPath.row);
    Pharmacy* pharmacy = self.filteredPharmacies[indexPath.row];
    UINavigationController* hostController = [AppDelegate sharedDelegate].clientsSplitController.viewControllers[1];
    PharmacyViewController* pharmacyViewController = (PharmacyViewController*)hostController.topViewController;
    
    
    NSDate* startDate;
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&startDate interval:NULL forDate:self.selectedDate];
    //Add one day
    NSDateComponents *oneDay = [NSDateComponents new];
    oneDay.day = 1;
    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:oneDay
                                                                    toDate:startDate
                                                                   options:0];
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    
    BOOL found = NO;
    for (Visit* visit in pharmacy.visits)
    {
       
        if ([visit.date compare:startDate] != NSOrderedAscending && [visit.date compare:endDate] == NSOrderedAscending && visit.user.userId == [AppDelegate sharedDelegate].currentUser.userId)
        {
            if (!onlySelected)
                [context deleteObject:visit];
            found = YES;
        }
    }
    for (Conference* conference in pharmacy.conferences)
    {
        
        if ([conference.date compare:startDate] != NSOrderedAscending && [conference.date compare:endDate] == NSOrderedAscending && conference.user.userId == [AppDelegate sharedDelegate].currentUser.userId)
        {
            NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
            [context deleteObject:conference];
            found = YES;
        }
    }
    
    if (!found)
    {
        if (!onlySelected)
        {
        Visit* visit = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Visit"
                        inManagedObjectContext:context];
        visit.pharmacy = pharmacy;
        visit.date = self.selectedDate;
        visit.user = [AppDelegate sharedDelegate].currentUser;
        //TODO: add fucking id
        visit.visitId = 0;
        [[AppDelegate sharedDelegate]saveContext];
        }
        
        pharmacyViewController.favourite = NO;
    }
    else if (onlySelected)
        pharmacyViewController.favourite = YES;
    
    [pharmacyViewController showPharmacy:pharmacy];
    [self reloadData];
}

- (void)addPharmacy
{
    NewPharmacyViewController* pharmacyViewController = [NewPharmacyViewController new];
    pharmacyViewController.delegate = self;
    ModalNavigationController* hostingController = [[ModalNavigationController alloc]initWithRootViewController:pharmacyViewController];
    hostingController.modalPresentationStyle = UIModalPresentationFormSheet;
    hostingController.modalWidth = 590;
    hostingController.modalHeight = 330;
    [self presentViewController:hostingController animated:YES completion:nil];
}

- (void)newPharmacyViewController:(NewPharmacyViewController *)newPharmacyViewcontroller didAddPharmacy:(Pharmacy *)pharmacy
{
    [self.pharmacies addObject:pharmacy];
    [self sortPharmacies];
    [self.table reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didSelectDate:(id)sender
{
    UIDatePicker* datePicker = (UIDatePicker*)sender;
    self.selectedDate = datePicker.date;
    [self reloadData];
}

- (void)reloadData
{
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Pharmacy" inManagedObjectContext:context]];
    if (onlySelected)
    {
//        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"ANY visits.date==%@", self.selectedDate];
        
        //get date without time component. We don't need it in fact, because we already have it without time from calendar control
        NSDate* startDate;
        [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&startDate interval:NULL forDate:self.selectedDate];
        //Add one day
        NSDateComponents *oneDay = [NSDateComponents new];
        oneDay.day = 1;
        NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:oneDay
                                                                        toDate:startDate
                                                                       options:0];
        
        
        
        NSPredicate* datePredicate = [NSPredicate predicateWithFormat:@"((ANY visits.date>=%@) AND (ANY visits.date<%@) AND (ANY visits.user.userId==%@)) OR ((ANY conferences.date>=%@) AND (ANY conferences.date<%@) AND (ANY conferences.user.userId==%@))", startDate, endDate, [AppDelegate sharedDelegate].currentUser.userId, startDate, endDate, [AppDelegate sharedDelegate].currentUser.userId];
        NSPredicate* predicate1 = [NSPredicate predicateWithFormat:@"SUBQUERY(visits, $e, $e.date>=%@ && $e.date<%@ && $e.user.userId==%@).@count > 0", startDate, endDate, [AppDelegate sharedDelegate].currentUser.userId];
        NSPredicate* predicate2 = [NSPredicate predicateWithFormat:@"SUBQUERY(conferences, $e, $e.date>=%@ && $e.date<%@ && $e.user.userId==%@).@count > 0", startDate, endDate, [AppDelegate sharedDelegate].currentUser.userId];
        NSCompoundPredicate* compoundPredicate = [[NSCompoundPredicate alloc]initWithType:NSOrPredicateType subpredicates:@[predicate1, predicate2]];
        
//        NSPredicate* compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[filterByUserPredicate, datePredicate]];
        [request setPredicate:compoundPredicate];
    }
    NSError *error = nil;
    self.pharmacies = [[context executeFetchRequest:request error:&error]mutableCopy];
    [self sortPharmacies];
    [self filterPharmacies];
    [self.table reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchBar)
    [self filterPharmacies];
    [self.table reloadData];
}

- (void)filterPharmacies
{
    NSPredicate* namePredicate;
    if ([self.nameFilterString isEqualToString:@""])
    {
        namePredicate = [NSPredicate predicateWithValue:YES];
    }
    else
    {
        namePredicate = [NSPredicate predicateWithFormat:@"(name contains[cd] %@)", self.nameFilterString];
    }
    NSPredicate* cityPredicate;
    if ([self.cityFilterString isEqualToString:@""])
    {
        cityPredicate = [NSPredicate predicateWithValue:YES];
    }
    else
    {
        cityPredicate = [NSPredicate predicateWithFormat:@"(city contains[cd] %@)", self.cityFilterString];
    }
    NSPredicate* streetPredicate;
    if ([self.streetFilterString isEqualToString:@""])
    {
        streetPredicate = [NSPredicate predicateWithValue:YES];
    }
    else
    {
        streetPredicate = [NSPredicate predicateWithFormat:@"(street contains[cd] %@)", self.streetFilterString];
    }
    NSPredicate* housePredicate;
    if ([self.houseFilterString isEqualToString:@""])
    {
        housePredicate = [NSPredicate predicateWithValue:YES];
    }
    else
    {
        housePredicate = [NSPredicate predicateWithFormat:@"(house contains[cd] %@)", self.houseFilterString];
    }
    NSCompoundPredicate* predicate = [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates:@[namePredicate, cityPredicate, streetPredicate, housePredicate]];
    self.filteredPharmacies = [self.sortedPharmacies filteredArrayUsingPredicate:predicate];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.nameFilter)
    {
        self.nameFilterString = finalString;
    }
    else if (textField == self.cityFilter)
    {
        self.cityFilterString = finalString;
    }
    else if (textField == self.streetFilter)
    {
        self.streetFilterString = finalString;
    }
    else if (textField == self.houseFilter)
    {
        self.houseFilterString = finalString;
    }
    NSLog(@"Replacement string is %@", finalString);
    [self filterPharmacies];
    [self.table reloadData];
    return YES;
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date;
{
    self.selectedDate = date;
    
    [self reloadData];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd.MM.yy";
    self.title = [dateFormatter stringFromDate:date];
}

- (IBAction)leftSegmentPressed:(id)sender
{
    if (onlySelected)
    {
        [self.leftSegment setBackgroundImage:[UIImage imageNamed:@"leftPinkPressed"] forState:UIControlStateNormal];
        [self.rightSegment setBackgroundImage:[UIImage imageNamed:@"rightPink"] forState:UIControlStateNormal];
        [self.leftSegment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rightSegment setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        onlySelected = NO;
        
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self reloadData];
        [self selectFirstFromList];
    }
}

- (IBAction)rightSegmentPressed:(id)sender
{
    if (!onlySelected)
    {
        [self.leftSegment setBackgroundImage:[UIImage imageNamed:@"leftPink"] forState:UIControlStateNormal];
        [self.rightSegment setBackgroundImage:[UIImage imageNamed:@"rightPinkPressed"] forState:UIControlStateNormal];
        [self.leftSegment setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        [self.rightSegment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        onlySelected = YES;
        
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self reloadData];
        [self selectFirstFromList];
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
    for (Conference* conference in pharmacy.conferences)
    {
        
        if ([conference.date compare:startDate] != NSOrderedAscending && [conference.date compare:endDate] == NSOrderedAscending && conference.user.userId == [AppDelegate sharedDelegate].currentUser.userId)
        {
            [context deleteObject:conference];
        }
    }
    self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self reloadData];
    [self selectFirstFromList];
}
@end