//
//  VisitButtonsCell.m
//  CRM
//
//  Created by FirstMac on 27.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "VisitButtonsCell.h"
#import "Visit.h"

@implementation VisitButtonsCell

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

- (void)showVisit:(Visit*)visit
{
    if (visit.commerceVisit)
        self.salesButton.hidden = NO;
    else
        self.salesButton.hidden = YES;
    
    if (visit.pharmacyCircle)
        self.pharmacyCircleButton.hidden = NO;
    else
        self.pharmacyCircleButton.hidden = YES;
    
    if (visit.promoVisit)
        self.promoVisitButton.hidden = NO;
    else
        self.promoVisitButton.hidden = YES;
}
@end
