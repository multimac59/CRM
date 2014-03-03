//
//  VisitMapCell.m
//  CRM
//
//  Created by FirstMac on 27.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "VisitMapCell.h"
#import "PharmacyCalloutView.h"
#import "Visit.h"
#import "NSDate+Additions.h"
#import "VisitManager.h"
@interface VisitMapCell()
{
    int total;
    NSMutableArray* mapAnnotations;
}
@property (nonatomic, strong) NSDate* selectedDate;
@end

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

- (void)setMapLocationForPharmacy:(Pharmacy*)pharmacy onDate:(NSDate*)date
{
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
         
         //[self.mapView setCenterCoordinate:location.coordinate atZoomLevel:15 animated:YES];
         MapAnnotation* annotation = [MapAnnotation new];
         annotation.coordinate = location.coordinate;
         annotation.title = address;
         annotation.subtitle = pharmacy.name;
         annotation.visit = [[VisitManager sharedManager] visitInPharmacy:pharmacy forDate:date];
         annotation.pharmacy = pharmacy;
         [mapAnnotations addObject:annotation];
         total--;
         
         if (total == 0)
         {
             [self zoomMap];
         }
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             total--;
         }];
}

- (void)setMapLocationsForPharmacies:(NSArray*)pharmacies onDate:(NSDate*)date
{
    self.selectedDate = date;
    self.mapView.showTraffic = NO;
    self.mapView.delegate = self;
    total = pharmacies.count;
    mapAnnotations = [NSMutableArray new];
    for (Pharmacy* pharmacy in pharmacies)
    {
        [self setMapLocationForPharmacy:pharmacy onDate:date];
    }
}

- (void)zoomMap
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:mapAnnotations];
    YMKMapRect mapRect = YMKMapRectBoundingAnnotations(mapAnnotations);
    YMKMapRegion region = YMKMapRegionFromMapRect(mapRect);
    [self.mapView setRegion:region];
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
    YMKPinAnnotationView* view = [[YMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"pin"];
    view.canShowCallout = YES;
    MapAnnotation* mapAnnotation = (MapAnnotation*)annotation;

    if (mapAnnotation.visit)
        view.pinColor = YMKPinAnnotationColorGreen;
    else
        view.pinColor = YMKPinAnnotationColorBlue;
    return view;
}

- (YMKCalloutView* )mapView:(YMKMapView *)view calloutViewForAnnotation:(id<YMKAnnotation>)annotation
{
    YMKCalloutView* calloutView = [view dequeueReusableCalloutViewWithIdentifier:@"callout"];
    if (calloutView == nil)
    {
        calloutView = [[YMKCalloutView alloc]initWithReuseIdentifier:@"callout"];
    }
    calloutView.frame = CGRectMake(0, 0, 216, 90);
    MapAnnotation* mapAnnotation = (MapAnnotation*)annotation;
    Visit* visit = mapAnnotation.visit;
    PharmacyCalloutView* calloutContent = [[NSBundle mainBundle]loadNibNamed:@"PharmacyCalloutView" owner:self options:nil][0];
    calloutContent.titleLabel.text = mapAnnotation.subtitle;
    calloutContent.addressLabel.text = mapAnnotation.title;
    calloutContent.pharmacy = mapAnnotation.pharmacy;
    
    if (visit.commerceVisit)
    {
        [calloutContent.commerceVisitButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateHighlighted];
        [calloutContent.commerceVisitButton setBackgroundImage:[UIImage imageNamed:@"typeButton2Pressed"] forState:UIControlStateNormal];
    }
    else
    {
        [calloutContent.commerceVisitButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateNormal];
        [calloutContent.commerceVisitButton setBackgroundImage:[UIImage imageNamed:@"typeButton2Pressed"] forState:UIControlStateHighlighted];
    }
    if (visit.promoVisit)
    {
        [calloutContent.promoVisitButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateHighlighted];
        [calloutContent.promoVisitButton setBackgroundImage:[UIImage imageNamed:@"typeButton2Pressed"] forState:UIControlStateNormal];
    }
    else
    {
        [calloutContent.promoVisitButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateNormal];
        [calloutContent.promoVisitButton setBackgroundImage:[UIImage imageNamed:@"typeButton2Pressed"] forState:UIControlStateHighlighted];
    }
    if (visit.pharmacyCircle)
    {
        [calloutContent.pharmacyCircleButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateHighlighted];
        [calloutContent.pharmacyCircleButton setBackgroundImage:[UIImage imageNamed:@"typeButton2Pressed"] forState:UIControlStateNormal];
    }
    else
    {
        [calloutContent.pharmacyCircleButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateNormal];
        [calloutContent.pharmacyCircleButton setBackgroundImage:[UIImage imageNamed:@"typeButton2Pressed"] forState:UIControlStateHighlighted];
    }
    
    calloutView.contentView = calloutContent;
    
    //[self.mapView setCenterCoordinate:mapAnnotation.coordinate];
    
    return calloutView;
}

- (IBAction)commerceVisitButtonClicked:(id)sender
{
    UIButton* button = sender;
    PharmacyCalloutView* calloutView = (PharmacyCalloutView*)button.superview;
    
    BOOL commerceVisitOn = [[VisitManager sharedManager]toggleCommerceVisitInPharmacy:calloutView.pharmacy forDate:self.selectedDate];
    if (commerceVisitOn)
    {
        [button setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:@"typeButton2Pressed"] forState:UIControlStateNormal];
    }
    else
    {
        [button setBackgroundImage:[UIImage imageNamed:@"typeButton2Pressed"] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateNormal];
    }
}

- (IBAction)promoVisitButtonClicked:(id)sender
{
    UIButton* button = sender;
    PharmacyCalloutView* calloutView = (PharmacyCalloutView*)button.superview;
    
    BOOL promoVisitOn = [[VisitManager sharedManager]togglePromoVisitInPharmacy:calloutView.pharmacy forDate:self.selectedDate];
    if (promoVisitOn)
    {
        [button setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:@"typeButton2Pressed"] forState:UIControlStateNormal];
    }
    else
    {
        [button setBackgroundImage:[UIImage imageNamed:@"typeButton2Pressed"] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateNormal];
    }
}

- (IBAction)pharmacyCircleButtonClicked:(id)sender
{
    UIButton* button = sender;
    PharmacyCalloutView* calloutView = (PharmacyCalloutView*)button.superview;
    
    BOOL pharmacyCircleOn = [[VisitManager sharedManager]togglePharmacyCircleInPharmacy:calloutView.pharmacy forDate:self.selectedDate];
    if (pharmacyCircleOn)
    {
        [button setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:@"typeButton2Pressed"] forState:UIControlStateNormal];
    }
    else
    {
        [button setBackgroundImage:[UIImage imageNamed:@"typeButton2Pressed"] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateNormal];
    }
}
@end
