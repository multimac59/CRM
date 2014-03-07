//
//  VisitsCell.m
//  CRM
//
//  Created by FirstMac on 15.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "VisitsCell.h"
#import "Pharmacy.h"
#import "Pharmacy+QuarterVisits.h"
#import "Visit.h"

@implementation VisitsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
//    if (!SYSTEM_VERSION_LESS_THAN(@"7.0"))
//    {
//        self.contentView.backgroundColor = [UIColor yellowColor];
//    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected)
    {
        self.triangleImage.hidden = NO;
    }
    else
    {
        self.triangleImage.hidden = YES;
    }
    // Configure the view for the selected state
}

- (void)setupCellWithPharmacy:(Pharmacy*)pharmacy andVisit:(Visit*)visit
{
    self.pharmacyLabel.text = pharmacy.name;
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@", pharmacy.city, pharmacy.street, pharmacy.house];
    self.visitsLabel.text = [NSString stringWithFormat:@"%d", pharmacy.visitsInCurrentQuarter.count];
    
    switch (pharmacy.status)
    {
        case GoldStatus:
            self.statusView.hidden = NO;
            self.statusView.image = [UIImage imageNamed:@"goldButton"];
            break;
        case SilverStatus:
            self.statusView.hidden = NO;
            self.statusView.image = [UIImage imageNamed:@"silverButton"];
            break;
        case BronzeStatus:
            self.statusView.hidden = NO;
            self.statusView.image = [UIImage imageNamed:@"bronzeButton"];
            break;
        default:
            self.statusView.hidden = YES;
            break;
    }
    self.pspView.hidden = pharmacy.psp.boolValue ? NO : YES;
    
    if (visit.commerceVisit)
    {
        [self.commerceVisitButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateHighlighted];
        [self.commerceVisitButton setBackgroundImage:[UIImage imageNamed:@"commerceButton"] forState:UIControlStateNormal];
    }
    else
    {
        [self.commerceVisitButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateNormal];
        [self.commerceVisitButton setBackgroundImage:[UIImage imageNamed:@"commerceButton"] forState:UIControlStateHighlighted];
    }
    if (visit.promoVisit)
    {
        [self.promoVisitButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateHighlighted];
        [self.promoVisitButton setBackgroundImage:[UIImage imageNamed:@"promoButton"] forState:UIControlStateNormal];
    }
    else
    {
        [self.promoVisitButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateNormal];
        [self.promoVisitButton setBackgroundImage:[UIImage imageNamed:@"promoButton"] forState:UIControlStateHighlighted];
    }
    if (visit.pharmacyCircle)
    {
        [self.pharmacyCircleButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateHighlighted];
        [self.pharmacyCircleButton setBackgroundImage:[UIImage imageNamed:@"pharmacyCircleButton"] forState:UIControlStateNormal];
    }
    else
    {
        [self.pharmacyCircleButton setBackgroundImage:[UIImage imageNamed:@"typeButton2"] forState:UIControlStateNormal];
        [self.pharmacyCircleButton setBackgroundImage:[UIImage imageNamed:@"pharmacyCircleButton"] forState:UIControlStateHighlighted];
    }
    
    if (visit.sent.boolValue)
    {
        self.contentView.backgroundColor = [UIColor greenColor];
    }
    else if (visit.closed.boolValue)
    {
        self.contentView.backgroundColor = [UIColor redColor];
    }
    else
    {
        self.contentView.backgroundColor = [UIColor clearColor];
    }
}

- (void)disableButtons
{
    self.commerceVisitButton.enabled = NO;
    self.promoVisitButton.enabled = NO;
    self.pharmacyCircleButton.enabled = NO;
}

@end
