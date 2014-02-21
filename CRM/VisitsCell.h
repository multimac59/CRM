//
//  VisitsCell.h
//  CRM
//
//  Created by FirstMac on 15.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VisitsCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel* pharmacyLabel;
@property (nonatomic, weak) IBOutlet UILabel* timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView* triangleImage;
@property (nonatomic, weak) IBOutlet UILabel* addressLabel;
@property (nonatomic, weak) IBOutlet UIView* statusView;
@end
