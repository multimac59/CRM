//
//  SaleCell.m
//  CRM
//
//  Created by FirstMac on 11.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "SaleCell.h"
#import "Sale.h"
#import "Dose.h"
#import "CommerceVisit.h"
#import "Visit.h"

@implementation SaleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib{
    self.soldField.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.orderField.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.remainderField.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
}

- (void)setupCellWithLastSale:(Sale*)lastSale andCurrentSale:(Sale*)currentSale forDose:(Dose*)dose
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd.MM.yyyy HH:mm";
    
    NSCharacterSet* digits = [NSCharacterSet decimalDigitCharacterSet];
    NSRange firstNumRange = [dose.name rangeOfCharacterFromSet:digits];
    if (firstNumRange.location != NSNotFound)
    {
        self.drugLabel.text = [dose.name substringToIndex:firstNumRange.location];
        self.doseLabel.text = [dose.name substringFromIndex:firstNumRange.location];
    }
    else
        self.drugLabel.text = dose.name;
    
    if (lastSale)
    {
        self.dateLabel.text = [dateFormatter stringFromDate:lastSale.commerceVisit.visit.date];
        self.remainderLabel.text = [NSString stringWithFormat:@"%@", lastSale.remainder];
    }
    else
    {
        self.dateLabel.text = @" - ";
        self.remainderLabel.text = @"0";
    }
    
    if (currentSale)
    {
        if (currentSale.order.integerValue == -1)
            self.orderField.text = @"Ост.";
        else
            self.orderField.text = [NSString stringWithFormat:@"%@", currentSale.order];
        
        if (currentSale.sold.integerValue == -1)
            self.soldField.text = @"Ост.";
        else
            self.soldField.text = [NSString stringWithFormat:@"%@", currentSale.sold];
        
        if (currentSale.remainder.integerValue == -1)
            self.remainderField.text = @"Ост.";
        else
            self.remainderField.text = [NSString stringWithFormat:@"%@", currentSale.remainder];
    }
    else
    {
        self.orderField.text = @"0";
        self.soldField.text = @"0";
        self.remainderField.text = @"0";
    }
}

- (void)setCellEnabled:(BOOL)enabled
{
    self.orderField.enabled = enabled;
    self.soldField.enabled = enabled;
    self.remainderField.enabled = enabled;
}
@end
