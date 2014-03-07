//
//  VisitViewController.h
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Visit.h"
#import "YandexMapKit.h"


@interface VisitViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITabBarDelegate>
@property (nonatomic, weak) IBOutlet UITableView* table;

//Data for map
@property (nonatomic, strong) NSArray* allPharmacies;
@property (nonatomic, weak) NSDate* planDate;
@property (nonatomic, strong) Pharmacy* selectedPharmacy;

- (IBAction)goToSalesList:(id)sender;
- (IBAction)goToPromoVisit:(id)sender;
- (IBAction)goToPharmacyCircle:(id)sender;

- (void)showVisit:(Visit*)visit;
@end
