//
//  VisitMapCell.m
//  CRM
//
//  Created by FirstMac on 27.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "VisitMapCell.h"

@implementation VisitMapCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMapLocationForPharmacy:(Pharmacy*)pharmacy
{
    self.mapView.showTraffic = NO;
    self.mapView.delegate = self;
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

- (void)mapView:(YMKMapView *)mapView annotationView:(YMKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"HOHO");
}

- (void)mapView:(YMKMapView *)mapView annotationViewCalloutTapped:(YMKAnnotationView *)view
{
    NSLog(@"Hooty");
}

- (void)draggablePinAnnotationViewDidStartInteraction:(YMKDraggablePinAnnotationView *)view
{
    NSLog(@"OKK");
}

- (void)draggablePinAnnotationViewDidStartMoving:(YMKDraggablePinAnnotationView *)view
{
    NSLog(@"OKK");
}

- (void)draggablePinAnnotationViewDidEndMoving:(YMKDraggablePinAnnotationView *)view
{
    NSLog(@"OKK");
}

- (YMKAnnotationView *)mapView:(YMKMapView *)mapView viewForAnnotation:(id<YMKAnnotation>)annotation
{
    YMKDraggablePinAnnotationView* view = [[YMKDraggablePinAnnotationView alloc]initWithAnnotation:(MapAnnotation*)annotation reuseIdentifier:@"pin"];
    view.delegate = self;
    //view.pinColor = YMKPinAnnotationColorGreen;
    return view;
}

- (void)awakeFromNib
{
    
}

@end
