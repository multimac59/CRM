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
    self.nameLabel.text = visit.pharmacy.name;
    //TODO:set text
    //self.networkLabel.text = visit.pharmacy.network;
    self.phoneLabel.text = visit.pharmacy.phone;
    self.doctorLabel.text = visit.pharmacy.doctorName;
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@", visit.pharmacy.city, visit.pharmacy.street, visit.pharmacy.house];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    self.timeLabel.text = [timeFormatter stringFromDate:visit.date];
    [timeFormatter setDateFormat:@"dd.MM.yyyy"];
    self.dateLabel.text = [timeFormatter stringFromDate:visit.date];
    
    NSDateComponents* dateComponents =[[NSCalendar currentCalendar]components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:visit.date];
    NSDateComponents* dateComponents2 =[[NSCalendar currentCalendar]components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    
    if (!visit.closed.boolValue && dateComponents.year == dateComponents2.year && dateComponents.month == dateComponents2.month && dateComponents.day == dateComponents2.day)
    {
        self.closeVisitButton.hidden = NO;
    }
    else
    {
        self.closeVisitButton.hidden = YES;
    }
}

- (void)showPharmacy:(Pharmacy *)pharmacy
{
    self.nameLabel.text = pharmacy.name;
    //TODO: set text
    //self.networkLabel.text = pharmacy.network;
    self.phoneLabel.text = pharmacy.phone;
    self.doctorLabel.text = pharmacy.doctorName;
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@", pharmacy.city, pharmacy.street, pharmacy.house];
}

@end
