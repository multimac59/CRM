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
@property (nonatomic, strong) NSDate* date;
@property (nonatomic) BOOL favourite;

@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* networkLabel;
@property (nonatomic, weak) IBOutlet UILabel* addressLabel;
@property (nonatomic, weak) IBOutlet UILabel* phoneLabel;
@property (nonatomic, weak) IBOutlet UILabel* doctorLabel;


- (IBAction)showPharmacy:(Pharmacy*)pharmacy;
- (IBAction)removeFromFavourites:(id)sender;
- (IBAction)closeVisit:(id)sender; //Need it here for builder
@end
