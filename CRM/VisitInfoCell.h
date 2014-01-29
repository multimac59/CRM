//
//  VisitInfoCell.h
//  CRM
//
//  Created by FirstMac on 27.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Visit.h"
#import "Conference.h"
#import "Pharmacy.h"

@interface VisitInfoCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel* dateLabel;
@property (nonatomic, weak) IBOutlet UILabel* timeLabel;
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* networkLabel;
@property (nonatomic, weak) IBOutlet UILabel* addressLabel;
@property (nonatomic, weak) IBOutlet UILabel* phoneLabel;
@property (nonatomic, weak) IBOutlet UILabel* doctorLabel;

@property (nonatomic, weak) IBOutlet UIButton* favouriteButton;

- (void)showPharmacy:(Pharmacy *)pharmacy;
- (void)showVisit:(Visit *)visit;
- (void)showConference:(Conference *)conference;
@end
