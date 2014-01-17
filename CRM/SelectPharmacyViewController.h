//
//  SelectPharmacyViewController.h
//  CRM
//
//  Created by FirstMac on 16.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SelectPharmacyViewController;
@class Pharmacy;
@protocol SelectPharmacyDelegate
- (void)selectPharmacyDelegate:(SelectPharmacyViewController*)selectPharmacyViewController didSelectPharmacy:(Pharmacy*)pharmacy;
@end

@interface SelectPharmacyViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView* table;
@property (nonatomic, weak) IBOutlet UISearchBar* searchBar;
@property (nonatomic, strong) Pharmacy* selectedPharmacy;
@property (nonatomic, weak) id<SelectPharmacyDelegate>delegate;
@end