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

@interface SalesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) CommerceVisit* commerceVisit;
@property (nonatomic, strong) NSArray* drugs;

@property (nonatomic, weak) IBOutlet UITableView* table;
@end
