//
//  VisitsCell.h
//  CRM
//
//  Created by FirstMac on 15.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pharmacy.h"
#import "Visit.h"

@interface VisitsCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel* pharmacyLabel;
@property (nonatomic, weak) IBOutlet UILabel* visitsLabel;
@property (nonatomic, weak) IBOutlet UIImageView* triangle;
@property (nonatomic, weak) IBOutlet UILabel* addressLabel;
@property (nonatomic, weak) IBOutlet UIImageView* statusView;
@property (nonatomic, weak) IBOutlet UIImageView* pspView;

@property (nonatomic, weak) IBOutlet UIButton* commerceVisitButton;
@property (nonatomic, weak) IBOutlet UIButton* promoVisitButton;
@property (nonatomic, weak) IBOutlet UIButton* pharmacyCircleButton;

- (void)setupCellWithPharmacy:(Pharmacy*)pharmacy andVisit:(Visit*)visit;
- (void)disableButtons;
@end
