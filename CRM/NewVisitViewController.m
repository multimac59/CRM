//
//  NewVisitViewController.m
//  CRM
//
//  Created by FirstMac on 10.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "NewVisitViewController.h"
#import "ParticipantsViewController.h"
#import "AppDelegate.h"
#import "Pharmacy.h"

@interface NewVisitViewController ()
@property (nonatomic, strong) NSIndexPath* selectedIndexPath;

@property (nonatomic, strong) Conference* conference;
@property (nonatomic, strong) Visit* visit;

@property (nonatomic, strong) NSArray* pharmacies;
@property (nonatomic, strong) NSArray* filteredPharmacies;
//@property (nonatomic, strong) UISearchDisplayController* searchController;

@end

@implementation NewVisitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _visit = [NSEntityDescription
                              insertNewObjectForEntityForName:@"Visit"
                              inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
        self.visit.sales = [NSSet new];
        _conference = [NSEntityDescription
                       insertNewObjectForEntityForName:@"Conference"
                       inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
        _conference.participants = [NSSet new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //_searchController = [[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
    self.navigationItem.title = @"Новый визит";
    if (self.isConference)
        self.conferenceControls.hidden = NO;
    else
        self.conferenceControls.hidden = YES;
    
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Pharmacy" inManagedObjectContext:context]];
    NSError *error = nil;
    _pharmacies = [[context executeFetchRequest:request error:&error]mutableCopy];
    _filteredPharmacies = _pharmacies;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.participantsField.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.conference.participants.count];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel
{
    NSManagedObjectContext* context = [[AppDelegate sharedDelegate]managedObjectContext];
    [context deleteObject:self.visit];
    [context deleteObject:self.conference];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)save
{
    if (self.isConference)
    {
        self.conference.pharmacy = self.pharmacies[_selectedIndexPath.row];
        self.conference.user = [AppDelegate sharedDelegate].currentUser;
        NSDateFormatter* dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd.MM.yyyy HH:mm";
        NSString* dateString = [NSString stringWithFormat:@"%@ %@", self.dateField.text, self.timeField.text];
        self.conference.date = [dateFormatter dateFromString:dateString];
        self.conference.name = self.nameField.text;
        [self.delegate newVisitViewController:self didAddConference:self.conference];
    }
    else
    {
        self.visit.pharmacy = self.pharmacies[_selectedIndexPath.row];
        self.visit.user = [AppDelegate sharedDelegate].currentUser; //our visit
        NSDateFormatter* dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd.MM.yyyy HH:mm";
        NSString* dateString = [NSString stringWithFormat:@"%@ %@", self.dateField.text, self.timeField.text];
        self.visit.date = [dateFormatter dateFromString:dateString];
        [self.delegate newVisitViewController:self didAddVisit:self.visit];
    }
}

- (IBAction)addParticipant
{
    ParticipantsViewController* participantsViewController = [ParticipantsViewController new];
    participantsViewController.conference = self.conference;
    [self.navigationController pushViewController:participantsViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredPharmacies.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    Pharmacy* pharmacy = self.filteredPharmacies[indexPath.row];
    cell.textLabel.text = pharmacy.name;
    if (self.selectedIndexPath.row == indexPath.row)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    [tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"Trying to search with text = %@", searchText);
    if (!searchText || [searchText isEqualToString:@""])
    {
        _filteredPharmacies = _pharmacies;
    }
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(name contains[cd] %@) || (network contains[cd] %@) || (city contains[cd] %@) || (street contains[cd] %@) || (house contains[cd] %@) || (phone contains[cd] %@) || (doctorName contains[cd] %@)", searchText, searchText, searchText, searchText, searchText, searchText, searchText];
    _filteredPharmacies = [_pharmacies filteredArrayUsingPredicate:predicate];
    [self.table reloadData];
}
                              /*
                              @property (nonatomic, retain) NSNumber * pharmacyId;
                              @property (nonatomic, retain) NSString * name;
                              @property (nonatomic, retain) NSString * network;
                              @property (nonatomic, retain) NSString * city;
                              @property (nonatomic, retain) NSString * street;
                              @property (nonatomic, retain) NSString * house;
                              @property (nonatomic, retain) NSString * phone;
                              @property (nonatomic, retain) NSString * doctorName;
                              @property (nonatomic, retain) NSSet *visits;*/
@end