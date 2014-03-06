//
//  PharmacyViewController.h
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pharmacy.h"

@interface PharmacyViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView* table;
@property (nonatomic) BOOL favourite;

//For map
@property (nonatomic, weak) NSMutableArray* allPharmacies;
@property (nonatomic, weak) NSDate* planDate;
- (void)reloadMap;

- (IBAction)showPharmacy:(Pharmacy*)pharmacy;

- (IBAction)removeFromFavourites:(id)sender;
- (IBAction)closeVisit:(id)sender; //Need it here for builder
@end
