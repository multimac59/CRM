//
//  PharmacyViewController.m
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "PharmacyViewController.h"
#import "YandexMapKit.h"
#import "AFNetworking.h"
#import "RaptureXMLResponseSerializer.h"
#import "MapAnnotation.h"

@interface PharmacyViewController ()
@property (nonatomic, weak) IBOutlet YMKMapView* mapView;
@end

@implementation PharmacyViewController

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
    self.navigationController.navigationBar.translucent = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPharmacy:(Pharmacy *)pharmacy
{
    self.navigationItem.title = pharmacy.name;
    self.nameLabel.text = pharmacy.name;
    self.networkLabel.text = pharmacy.network;
    self.phoneLabel.text = pharmacy.phone;
    self.doctorLabel.text = pharmacy.doctorName;
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@", pharmacy.city, pharmacy.street, pharmacy.house];
    [self setMapLocationForPharmacy:pharmacy];
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
