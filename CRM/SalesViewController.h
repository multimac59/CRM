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
@property (nonatomic, strong) NSMutableArray* sales;
@property (nonatomic, weak) IBOutlet UITableView* table;
@property (nonatomic, weak) IBOutlet UISegmentedControl* segmentedControl;

@property (nonatomic, weak) IBOutlet UIButton* lastVisitButton;
@property (nonatomic, weak) IBOutlet UIButton* myLastVisitButton;

- (IBAction)back;
- (IBAction)switchFilter:(id)sender;
- (IBAction)saveVisit:(id)sender;

//- (IBAction)lastVisitButtonPressed:(id)sender;
//- (IBAction)myLastVisitButtonPressed:(id)sender;

- (IBAction)showComment:(id)sender;
@end
