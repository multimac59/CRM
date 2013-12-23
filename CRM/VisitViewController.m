//
//  VisitViewController.m
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "VisitViewController.h"
#import "SalesViewController.h"
#import "ParticipantsViewController.h"
#import "BrandsViewController.h"
#import "AFNetworking.h"
#import "RaptureXMLResponseSerializer.h"
#import "MapAnnotation.h"

@interface VisitViewController ()
@property (nonatomic, strong) Conference* conference;
@property (nonatomic, strong) Visit* visit;
@property (nonatomic) BOOL isConference;
@property (nonatomic, weak) IBOutlet YMKMapView* mapView;
@end

@implementation VisitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Better to use inheritance
- (void)showVisit:(Visit *)visit
{
    self.navigationItem.title = visit.pharmacy.name;
    self.nameLabel.text = visit.pharmacy.name;
    self.networkLabel.text = visit.pharmacy.network;
    self.phoneLabel.text = visit.pharmacy.phone;
    self.doctorLabel.text = visit.pharmacy.doctorName;
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@", visit.pharmacy.city, visit.pharmacy.street, visit.pharmacy.house];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    self.timeLabel.text = [timeFormatter stringFromDate:visit.date];
    [timeFormatter setDateFormat:@"dd.MM.yyyy"];
    self.dateLabel.text = [timeFormatter stringFromDate:visit.date];
    
    self.brandsButton.hidden = YES;
    self.participantsButton.hidden = YES;
    self.salesButton.hidden = NO;
    
    self.visit = visit;
    self.isConference = NO;
    
    [self setMapLocationForPharmacy:visit.pharmacy];
}

- (void)showConference:(Conference *)conference
{
    self.navigationItem.title = conference.pharmacy.name;
    self.nameLabel.text = conference.pharmacy.name;
    self.networkLabel.text = conference.pharmacy.network;
    self.phoneLabel.text = conference.pharmacy.phone;
    self.doctorLabel.text = conference.pharmacy.doctorName;
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@", conference.pharmacy.city, conference.pharmacy.street, conference.pharmacy.house];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    self.timeLabel.text = [timeFormatter stringFromDate:conference.date];
    [timeFormatter setDateFormat:@"dd.MM.yyyy"];
    self.dateLabel.text = [timeFormatter stringFromDate:conference.date];
    
    self.brandsButton.hidden = NO;
    self.participantsButton.hidden = NO;
    self.salesButton.hidden = YES;
    
    self.conference = conference;
    self.isConference = YES;
    
    [self setMapLocationForPharmacy:conference.pharmacy];
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

- (IBAction)goToSalesList:(id)sender
{
    SalesViewController* salesViewController = [SalesViewController new];
    salesViewController.visit = self.visit;
    [self presentViewController:salesViewController animated:YES completion:^{
    }];
}

- (void)back
{
    NSLog(@"back");
}

- (void)goToParticipants:(id)sender
{
    ParticipantsViewController* participantsViewController = [ParticipantsViewController new];
    participantsViewController.conference = self.conference;
    [self.navigationController pushViewController:participantsViewController animated:YES];
}

- (void)goToBrands:(id)sender
{
    BrandsViewController* brandsViewController = [BrandsViewController new];
    brandsViewController.conference = self.conference;
    [self.navigationController pushViewController:brandsViewController animated:YES];
}
@end