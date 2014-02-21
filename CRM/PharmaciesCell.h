//
//  VisitsCell.h
//  CRM
//
//  Created by FirstMac on 15.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PharmaciesCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel* pharmacyLabel;
@property (nonatomic, weak) IBOutlet UIImageView* triangleImage;
@property (nonatomic, weak) IBOutlet UIImageView* checkmark;
@property (nonatomic, weak) IBOutlet UILabel* addressLabel;
@property (nonatomic, weak) IBOutlet UIView* statusView;
@property (nonatomic, weak) IBOutlet UILabel* visitsLabel;
@end
