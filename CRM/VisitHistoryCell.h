//
//  VisitHistoryCell.h
//  CRM
//
//  Created by FirstMac on 27.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Visit.h"
#import "Conference.h"
#import "User.h"

@interface VisitHistoryCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel* dateLabel;
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* participantLabel;
@property (nonatomic, weak) IBOutlet UILabel* typeLabel;

- (void)showVisit:(Visit *)visit;
- (void)showConference:(Conference *)conference;
@end
