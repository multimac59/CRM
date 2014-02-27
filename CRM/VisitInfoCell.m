//
//  VisitInfoCell.m
//  CRM
//
//  Created by FirstMac on 27.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "VisitInfoCell.h"

@implementation VisitInfoCell

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


- (void)showVisit:(Visit *)visit
{
    [self showPharmacy:visit.pharmacy];
}

- (void)showPharmacy:(Pharmacy *)pharmacy
{
        self.nameLabel.text = pharmacy.name;
        self.networkLabel.text = pharmacy.network.boolValue ?  @"Да" : @"Нет";
        self.phoneLabel.text = pharmacy.phone;
        self.doctorLabel.text = pharmacy.doctorName;
        self.addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@", pharmacy.city, pharmacy.street, pharmacy.house];
        switch (pharmacy.status)
        {
            case GoldStatus:
                self.statusLabel.text = @"Gold";
                break;
            case SilverStatus:
                self.statusLabel.text = @"Silver";
                break;
            case BronzeStatus:
                self.statusLabel.text = @"Bronze";
                break;
            default:
                self.statusLabel.text = @"Без категории";
                break;
        }
        self.PSPLabel.text = pharmacy.psp.boolValue ? @"Да" : @"Нет";
        self.salesLabel.text = pharmacy.sales;
}
@end