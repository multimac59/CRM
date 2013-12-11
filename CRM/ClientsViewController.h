//
//  ClientsViewController.h
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewPharmacyViewController.h"

@interface ClientsViewController : UIViewController<NewPharmacyViewDelegate>
@property (nonatomic, strong) NSMutableArray* pharmacies;
@property (nonatomic, weak) IBOutlet UITableView* table;
@end
