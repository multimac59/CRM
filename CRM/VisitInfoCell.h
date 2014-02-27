//
//  VisitInfoCell.h
//  CRM
//
//  Created by FirstMac on 27.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Visit.h"
#import "Pharmacy.h"

@interface VisitInfoCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* networkLabel;
@property (nonatomic, weak) IBOutlet UILabel* addressLabel;
@property (nonatomic, weak) IBOutlet UILabel* phoneLabel;
@property (nonatomic, weak) IBOutlet UILabel* doctorLabel;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* PSPLabel;
@property (nonatomic, weak) IBOutlet UILabel* statusLabel;
@property (nonatomic, weak) IBOutlet UILabel* salesLabel;

@property (nonatomic, weak) IBOutlet UIButton* favouriteButton;
@property (nonatomic, weak) IBOutlet UIButton* closeVisitButton;

- (void)showPharmacy:(Pharmacy *)pharmacy;
- (void)showVisit:(Visit *)visit;
@end
