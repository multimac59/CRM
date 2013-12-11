//
//  SalesViewController.h
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Visit.h"
#import "Pharmacy.h"
#import "Sale.h"

@interface SalesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) Visit* visit;
@property (nonatomic, strong) NSMutableArray* sales;
@property (nonatomic, weak) IBOutlet UITableView* table;
@property (nonatomic, weak) IBOutlet UISegmentedControl* segmentedControl;
- (IBAction)back;
- (IBAction)switchFilter:(id)sender;
- (IBAction)saveVisit:(id)sender;
@end
