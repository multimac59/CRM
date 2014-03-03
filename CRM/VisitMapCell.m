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
         annotation.visit = [self visitInPharmacy:pharmacy forDate:date];
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

- (Visit*)visitInPharmacy:(Pharmacy*)pharmacy forDate:(NSDate*)date
{
    for (Visit* visit in pharmacy.visits)
    {
        //get date without time component. We don't need it in fact, because we already have it without time from calendar control
        NSDate* startDate;
        [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&startDate interval:NULL forDate:date];
        //Add one day
        NSDateComponents *oneDay = [NSDateComponents new];
        oneDay.day = 1;
        NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:oneDay
                                                                        toDate:startDate
                                                                       options:0];
        if ([visit.date compare:startDate] != NSOrderedAscending && [visit.date compare:endDate] == NSOrderedAscending && visit.user.userId == [AppDelegate sharedDelegate].currentUser.userId)
        {
            return visit;
        }
    }
    return nil;
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
    
    [self.mapView setCenterCoordinate:mapAnnotation.coordinate];
    
    return calloutView;
}

- (IBAction)commerceVisitButtonClicked:(id)sender
{
    UIButton* button = sender;
    PharmacyCalloutView* calloutView = (PharmacyCalloutView*)button.superview;
    Pharmacy* pharmacy = calloutView.pharmacy;
    
    if ([self.selectedDate compare:[NSDate currentDate]] == NSOrderedAscending)
        return;
    
    Visit* visit = [self visitInPharmacy:pharmacy forDate:self.selectedDate];
    if (visit.closed.boolValue)
        return;
    
    if (!visit)
    {
        Visit* visit = [self createVisitInPharamacy:pharmacy forDate:self.selectedDate];
        CommerceVisit* commerceVisit = [NSEntityDescription
                                        insertNewObjectForEntityForName:@"CommerceVisit"
                                        inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
        visit.commerceVisit = commerceVisit;
        
        [button setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:@"typeButton2Pressed"] forState:UIControlStateNormal];
        //[Flurry logEvent:@"Планирование" withParameters:@{@"Событие" : @"Продажи", @"Состояние" : @"Да", @"Аптека" : visit.pharmacy.name, @"Дата визита" : self.selectedDate, @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
    }
    else
    {
        if (visit.commerceVisit)
        {
            [[AppDelegate sharedDelegate].managedObjectContext deleteObject:visit.commerceVisit];
            visit.commerceVisit = nil;
            if (!visit.promoVisit && !visit.pharmacyCircle)
            {
                [pharmacy removeVisitsObject:visit];
                [[AppDelegate sharedDelegate].managedObjectContext deleteObject:visit];
            }
            
            [button setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"typeButton2Pressed"] forState:UIControlStateHighlighted];
            //[Flurry logEvent:@"Планирование" withParameters:@{@"Событие" : @"Продажи", @"Состояние" : @"Нет", @"Аптека" : visit.pharmacy.name, @"Дата визита" : self.selectedDate, @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
        }
        else
        {
            CommerceVisit* commerceVisit = [NSEntityDescription
                                            insertNewObjectForEntityForName:@"CommerceVisit"
                                            inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
            visit.commerceVisit = commerceVisit;
            [button setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateHighlighted];
            [button setBackgroundImage:[UIImage imageNamed:@"typeButton2Pressed"] forState:UIControlStateNormal];
            //[Flurry logEvent:@"Планирование" withParameters:@{@"Событие" : @"Продажи", @"Состояние" : @"Да", @"Аптека" : visit.pharmacy.name, @"Дата визита" : self.selectedDate, @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
        }
    }
    [[AppDelegate sharedDelegate]saveContext];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"VisitsUpdated" object:self];
}

- (Visit*)createVisitInPharamacy:(Pharmacy*)pharmacy forDate:(NSDate*)date
{
    Visit* visit = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Visit"
                    inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
    visit.pharmacy = pharmacy;
    visit.date = date;
    visit.user = [AppDelegate sharedDelegate].currentUser;
    visit.visitId = [[NSUUID UUID]UUIDString];
    visit.closed = @NO;
    [pharmacy addVisitsObject:visit];
    return visit;
}

- (void)awakeFromNib
{
    
}

@end
