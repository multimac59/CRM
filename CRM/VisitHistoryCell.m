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
    User* user = visit.user;
    NSLog(@"User Id = %@, user name = %@", user.userId, user.name);
    
    NSLog(@"%@", visit.user.name);
    NSLog(@"%@", visit.date);
    
    self.typeLabel.text = @"Визит";
    self.nameLabel.text = visit.user.name;
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"dd.MM.yyyy"];
    self.dateLabel.text = [timeFormatter stringFromDate:visit.date];
    //self.participantLabel.text = [NSString stringWithFormat:@"%d", visit.participants.count];
}

@end
