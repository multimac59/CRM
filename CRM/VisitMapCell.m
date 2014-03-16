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
    //int total;
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


#pragma mark map setup methods
- (void)setMapLocationForPharmacy:(Pharmacy*)pharmacy onDate:(NSDate*)date selected:(BOOL)selected
{
    /*
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [RaptureXMLResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
    NSString* address = [NSString stringWithFormat:@"г. %@ %@ %@", pharmacy.city, pharmacy.street, pharmacy.house];
    NSString* urlString = [[NSString stringWithFormat:@"http://geocode-maps.yandex.ru/1.x/?geocode=%@", address]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Search for %@", address);
    total++;
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, NSArray* positionArray)
     {
         NSLog(@"returned for %@", address);
         //NSLog(@"MORE %d ops", manager.operationQueue.operationCount);
         //NSLog(@"JSON: %@", positionArray);
         if (positionArray.count == 0)
         {
             total--;
             if (total == 0)
             {
                 [self zoomMap];
             }
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
             if (total == 0)
             {
                 [self zoomMap];
             }
         }];*/
    
    if (pharmacy.latitude.doubleValue == 0 || pharmacy.latitude.doubleValue == 1)
        return;
    MapAnnotation* annotation = [MapAnnotation new];
    CLLocation* location = [[CLLocation alloc]initWithLatitude:pharmacy.latitude.doubleValue longitude:pharmacy.longitude.doubleValue];
    annotation.coordinate = location.coordinate;
    NSString* address = [NSString stringWithFormat:@"г. %@ %@ %@", pharmacy.city, pharmacy.street, pharmacy.house];
    annotation.title = address;
    annotation.subtitle = pharmacy.name;
    annotation.visit = [[VisitManager sharedManager] visitInPharmacy:pharmacy forDate:date];
    annotation.pharmacy = pharmacy;
    annotation.selected = selected;
    [mapAnnotations addObject:annotation];
}

- (void)setMapLocationsForPharmacies:(NSArray*)pharmacies withSelectedPharmacy:(Pharmacy*)selectedPharmacy onDate:(NSDate*)date;
{
    self.selectedDate = date;
    self.mapView.showTraffic = NO;
    self.mapView.delegate = self;
    //total = 0;
    
    if (!selectedPharmacy && pharmacies.count == 0)
        [self.mapView removeAnnotations:self.mapView.annotations];
    else
    {
    mapAnnotations = [NSMutableArray new];
    for (int i = 0; i < pharmacies.count; i++)
    {
        Pharmacy* pharmacy = pharmacies[i];
        if (pharmacy != selectedPharmacy)
            [self setMapLocationForPharmacy:pharmacy onDate:date selected:NO];
    }
    if (selectedPharmacy)
        [self setMapLocationForPharmacy:selectedPharmacy onDate:date selected:YES];
    [self zoomMap];
    }
}

- (void)zoomMap
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:mapAnnotations];
    
    if (mapAnnotations.count == 1)
    {
        MapAnnotation* ann = mapAnnotations[0];
        [self.mapView setCenterCoordinate:ann.coordinate atZoomLevel:16 animated:NO];
    }
    
    YMKMapRect mapRect = YMKMapRectBoundingAnnotations(mapAnnotations);
    YMKMapRegion region = YMKMapRegionFromMapRect(mapRect);
    [self.mapView setRegion:region];
}

#pragma mark map delegates

- (YMKAnnotationView *)mapView:(YMKMapView *)mapView viewForAnnotation:(id<YMKAnnotation>)annotation
{
    YMKPinAnnotationView* view = [[YMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"pin"];
    view.canShowCallout = YES;
    MapAnnotation* mapAnnotation = (MapAnnotation*)annotation;

    if (!mapAnnotation.selected)
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
    
    if (!self.allowPlanning)
    {
        calloutContent.commerceVisitButton.userInteractionEnabled = NO;
        calloutContent.promoVisitButton.userInteractionEnabled = NO;
        calloutContent.pharmacyCircleButton.userInteractionEnabled = NO;
    }
    
    if (visit.commerceVisit)
    {
        [calloutContent.commerceVisitButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateHighlighted];
        [calloutContent.commerceVisitButton setBackgroundImage:[UIImage imageNamed:@"commerceButton"] forState:UIControlStateNormal];
    }
    else
    {
        [calloutContent.commerceVisitButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateNormal];
        [calloutContent.commerceVisitButton setBackgroundImage:[UIImage imageNamed:@"commerceButton"] forState:UIControlStateHighlighted];
    }
    if (visit.promoVisit)
    {
        [calloutContent.promoVisitButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateHighlighted];
        [calloutContent.promoVisitButton setBackgroundImage:[UIImage imageNamed:@"promoButton"] forState:UIControlStateNormal];
    }
    else
    {
        [calloutContent.promoVisitButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateNormal];
        [calloutContent.promoVisitButton setBackgroundImage:[UIImage imageNamed:@"promoButton"] forState:UIControlStateHighlighted];
    }
    if (visit.pharmacyCircle)
    {
        [calloutContent.pharmacyCircleButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateHighlighted];
        [calloutContent.pharmacyCircleButton setBackgroundImage:[UIImage imageNamed:@"pharmacyCircleButton"] forState:UIControlStateNormal];
    }
    else
    {
        [calloutContent.pharmacyCircleButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateNormal];
        [calloutContent.pharmacyCircleButton setBackgroundImage:[UIImage imageNamed:@"pharmacyCircleButton"] forState:UIControlStateHighlighted];
    }
    
    calloutView.contentView = calloutContent;
    
    //[self.mapView setCenterCoordinate:mapAnnotation.coordinate];
    
    return calloutView;
}

#pragma mark planning buttons
- (IBAction)commerceVisitButtonClicked:(id)sender
{
    UIButton* button = sender;
    PharmacyCalloutView* calloutView = (PharmacyCalloutView*)button.superview;
    
    BOOL commerceVisitOn = [[VisitManager sharedManager]toggleCommerceVisitInPharmacy:calloutView.pharmacy forDate:self.selectedDate];
    if (commerceVisitOn)
    {
        [button setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:@"commerceButton"] forState:UIControlStateNormal];
    }
    else
    {
        [button setBackgroundImage:[UIImage imageNamed:@"commerceButtom"] forState:UIControlStateHighlighted];
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
        [button setBackgroundImage:[UIImage imageNamed:@"promoButton"] forState:UIControlStateNormal];
    }
    else
    {
        [button setBackgroundImage:[UIImage imageNamed:@"promoButton"] forState:UIControlStateHighlighted];
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
        [button setBackgroundImage:[UIImage imageNamed:@"pharmacyCircleButton"] forState:UIControlStateNormal];
    }
    else
    {
        [button setBackgroundImage:[UIImage imageNamed:@"pharmacyCircleButton"] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateNormal];
    }
}
@end