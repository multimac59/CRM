//
//  VisitHistoryCell.m
//  CRM
//
//  Created by FirstMac on 27.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "VisitHistoryCell.h"
#import "Visit.h"
#import "User.h"
#import "PromoVisit.h"
#import "PharmacyCircle.h"

@implementation VisitHistoryCell

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
    NSMutableString* typeString = [NSMutableString stringWithFormat:@""];
    if (visit.commerceVisit)
        [typeString appendString:@"Движение товара"];
    if (visit.promoVisit)
    {
        if ([typeString isEqualToString:@""])
            [typeString appendString:@"Промовизит"];
        else
            [typeString appendString:@", промовизит"];
    }
    if (visit.pharmacyCircle)
    {
        if ([typeString isEqualToString:@""])
            [typeString appendString:@"Фармкружок"];
        else
            [typeString appendString:@", фармкружок"];
    }
    self.typeLabel.text = typeString;
    self.nameLabel.text = visit.user.name;
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"dd.MM.yyyy"];
    self.dateLabel.text = [timeFormatter stringFromDate:visit.date];
    
    NSMutableString* participantsString = [NSMutableString stringWithFormat:@""];
    if (visit.promoVisit)
        [participantsString appendString:[NSString stringWithFormat:@"%@", visit.promoVisit.participants]];
    if (visit.pharmacyCircle)
    {
        if ([participantsString isEqualToString:@""])
            [participantsString appendString:[NSString stringWithFormat:@"%@", visit.pharmacyCircle.participants]];
        else
            [participantsString appendString:[NSString stringWithFormat:@", %@", visit.pharmacyCircle.participants]];
    }
    self.participantLabel.text = participantsString;
}

@end
