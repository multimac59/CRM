//
//  SaleCell.h
//  CRM
//
//  Created by FirstMac on 11.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SaleCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (nonatomic, strong) IBOutlet UILabel* drugLabel;
@property (nonatomic, strong) IBOutlet UILabel* dateLabel;
@property (nonatomic, strong) IBOutlet UITextField* soldField;
@property (nonatomic, strong) IBOutlet UITextField* remainderField;
@property (nonatomic, strong) IBOutlet UITextField* orderField;
@property (nonatomic, strong) IBOutlet UILabel* soldLabel;
@property (nonatomic, strong) IBOutlet UILabel* remainderLabel;
@property (nonatomic, strong) IBOutlet UILabel* orderLabel;
@end
