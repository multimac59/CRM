//
//  SaleCell.h
//  CRM
//
//  Created by FirstMac on 11.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sale.h"
#import "Dose.h"

@interface SaleCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIImageView* cellBg;
@property (nonatomic, strong) IBOutlet UILabel* drugLabel;
@property (nonatomic, strong) IBOutlet UILabel* doseLabel;
@property (nonatomic, strong) IBOutlet UILabel* dateLabel;
@property (nonatomic, strong) IBOutlet UITextField* soldField;
@property (nonatomic, strong) IBOutlet UITextField* remainderField;
@property (nonatomic, strong) IBOutlet UITextField* orderField;
@property (nonatomic, strong) IBOutlet UILabel* remainderLabel;
@property (nonatomic, weak) IBOutlet UIImageView* arrowView;
@property (nonatomic, weak) IBOutlet UIButton* commentButton;
@property (nonatomic, weak) IBOutlet UIImageView* commentMark;

- (void)setupCellWithLastSale:(Sale*)lastSale andCurrentSale:(Sale*)currentSale forDose:(Dose*)dose;
- (void)setCellEnabled:(BOOL)enabled;
@end
