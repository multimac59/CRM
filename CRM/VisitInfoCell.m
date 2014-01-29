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


//TODO: use inheritance
- (void)showVisit:(Visit *)visit
{
    self.nameLabel.text = visit.pharmacy.name;
    self.networkLabel.text = visit.pharmacy.network;
    self.phoneLabel.text = visit.pharmacy.phone;
    self.doctorLabel.text = visit.pharmacy.doctorName;
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@", visit.pharmacy.city, visit.pharmacy.street, visit.pharmacy.house];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    self.timeLabel.text = [timeFormatter stringFromDate:visit.date];
    [timeFormatter setDateFormat:@"dd.MM.yyyy"];
    self.dateLabel.text = [timeFormatter stringFromDate:visit.date];
}

- (void)showConference:(Conference *)conference
{
    self.nameLabel.text = conference.pharmacy.name;
    self.networkLabel.text = conference.pharmacy.network;
    self.phoneLabel.text = conference.pharmacy.phone;
    self.doctorLabel.text = conference.pharmacy.doctorName;
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@", conference.pharmacy.city, conference.pharmacy.street, conference.pharmacy.house];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    self.timeLabel.text = [timeFormatter stringFromDate:conference.date];
    [timeFormatter setDateFormat:@"dd.MM.yyyy"];
    self.dateLabel.text = [timeFormatter stringFromDate:conference.date];
}

- (void)showPharmacy:(Pharmacy *)pharmacy
{
    self.nameLabel.text = pharmacy.name;
    self.networkLabel.text = pharmacy.network;
    self.phoneLabel.text = pharmacy.phone;
    self.doctorLabel.text = pharmacy.doctorName;
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@", pharmacy.city, pharmacy.street, pharmacy.house];
}

@end
