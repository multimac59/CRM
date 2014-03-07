//
//  VisitMapCell.h
//  CRM
//
//  Created by FirstMac on 27.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pharmacy.h"
#import "YandexMapKit.h"
#import "AFNetworking.h"
#import "RaptureXMLResponseSerializer.h"
#import "MapAnnotation.h"
#import "AppDelegate.h"

@interface VisitMapCell : UITableViewCell<YMKDraggablePinAnnotationViewDelegate, YMKMapViewDelegate>
@property (nonatomic, weak) IBOutlet YMKMapView* mapView;
@property (nonatomic, weak) Pharmacy* pharmacy;

- (void)setMapLocationsForPharmacies:(NSArray*)pharmacies withSelectedPharmacy:(Pharmacy*)selectedPharmacy onDate:(NSDate*)date;
- (IBAction)commerceVisitButtonClicked:(id)sender;
- (IBAction)promoVisitButtonClicked:(id)sender;
- (IBAction)pharmacyCircleButtonClicked:(id)sender;
@end
