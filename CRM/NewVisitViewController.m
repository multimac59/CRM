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
#import "AFNetworking.h"
#import "RaptureXMLResponseSerializer.h"
#import "MapAnnotation.h"
#import "UIViewController+ShowModalFromView.h"
#import "AppDelegate.h"

@interface NewVisitViewController ()
@property (nonatomic, strong) NSIndexPath* selectedIndexPath;
@property (nonatomic, strong) Pharmacy* selectedPharmacy;

@property (nonatomic, strong) Conference* conference;
@property (nonatomic, strong) Visit* visit;

@property (nonatomic, strong) NSArray* pharmacies;
@property (nonatomic, strong) NSArray* filteredPharmacies;

@property (nonatomic, weak) IBOutlet YMKMapView* mapView;

@property (nonatomic, strong) SelectPharmacyViewController* selectPharmacyViewController;
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

    if (self.isConference)
    {
        self.conferenceControls.hidden = NO;
        self.navigationItem.title = @"Новая конференция";
    }
    else
    {
        self.conferenceControls.hidden = YES;
        self.navigationItem.title = @"Новый визит";
    }
    
    self.navigationController.navigationBar.translucent = NO;
    
    UIButton* cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 63, 20)];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButtonPressed"] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton"] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelButton];
    
    UIButton* saveButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 82, 20)];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"saveButtonPressed"] forState:UIControlStateNormal];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"saveButton"] forState:UIControlStateHighlighted];
    [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:saveButton];
    
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
        self.conference.name = self.visitNameField.text;
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

- (IBAction)selectPharmacy:(id)sender
{
    _selectPharmacyViewController = [SelectPharmacyViewController new];
    self.selectPharmacyViewController.delegate = self;
    self.selectPharmacyViewController.selectedPharmacy = self.selectedPharmacy;
    [self.navigationController pushViewController:self.selectPharmacyViewController animated:YES];
}

- (void)selectPharmacyDelegate:(SelectPharmacyViewController *)selectPharmacyViewController didSelectPharmacy:(Pharmacy *)pharmacy
{
    self.selectedPharmacy = pharmacy;
    self.nameLabel.text = self.selectedPharmacy.name;
    self.networkLabel.text = self.selectedPharmacy.network;
    self.cityLabel.text = self.selectedPharmacy.city;
    self.streetLabel.text = self.selectedPharmacy.street;
    self.houseLabel.text = self.selectedPharmacy.house;
    [self setMapLocationForPharmacy:self.selectedPharmacy];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setMapLocationForPharmacy:(Pharmacy*)pharmacy
{
    self.mapView.showTraffic = NO;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [RaptureXMLResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
    NSString* address = [NSString stringWithFormat:@"г. %@ %@ %@", pharmacy.city, pharmacy.street, pharmacy.house];
    NSString* urlString = [[NSString stringWithFormat:@"http://geocode-maps.yandex.ru/1.x/?geocode=%@", address]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, NSArray* positionArray)
     {
         NSLog(@"JSON: %@", positionArray);
         if (positionArray.count == 0)
         {
             NSLog(@"Not found");
             return;
         }
         CLLocation* location = positionArray[0];
         
         [self.mapView setCenterCoordinate:location.coordinate atZoomLevel:15 animated:YES];
         MapAnnotation* annotation = [MapAnnotation new];
         annotation.coordinate = location.coordinate;
         annotation.title = address;
         annotation.subtitle = @"";
         [self.mapView removeAnnotations:self.mapView.annotations];
         [self.mapView addAnnotation:annotation];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

@end