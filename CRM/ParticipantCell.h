//
//  ParticipantCell.h
//  CRM
//
//  Created by FirstMac on 25.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParticipantCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UIButton* deleteButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* deleteButtonWidth;
@end
