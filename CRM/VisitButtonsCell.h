//
//  VisitButtonsCell.h
//  CRM
//
//  Created by FirstMac on 27.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Visit;

@interface VisitButtonsCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIButton* salesButton;
@property (nonatomic, weak) IBOutlet UIButton* promoVisitButton;
@property (nonatomic, weak) IBOutlet UIButton* pharmacyCircleButton;

- (void)showVisit:(Visit *)visit;
@end
