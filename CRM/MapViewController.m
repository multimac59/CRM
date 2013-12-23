//
//  MapViewController.m
//  CRM
//
//  Created by FirstMac on 19.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "MapViewController.h"
#import "AFNetworking.h"
#import "RaptureXMLResponseSerializer.h"
#import "MapAnnotation.h"

@interface MapViewController ()
@property (nonatomic, weak) IBOutlet YMKMapView* mapView;
@end

@implementation MapViewController

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
    self.mapView.showTraffic = NO;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [RaptureXMLResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
    NSString* address = @"TverskayaUl";
    NSString* urlString = [NSString stringWithFormat:@"http://geocode-maps.yandex.ru/1.x/?geocode=%@", address];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, NSArray* positionArray)
     {
         NSLog(@"JSON: %@", positionArray);
         CLLocation* location = positionArray[0];
         
         [self.mapView setCenterCoordinate:location.coordinate atZoomLevel:15 animated:YES];
         MapAnnotation* annotation = [MapAnnotation new];
         annotation.coordinate = location.coordinate;
         annotation.title = address;
         annotation.subtitle = @"";
         [self.mapView addAnnotation:annotation];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
