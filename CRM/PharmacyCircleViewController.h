//
//  PharmacyCircleViewController.h
//  CRM
//
//  Created by FirstMac on 19.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PromoVisit.h"

@interface PharmacyCircleViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    BOOL brandsMode;
}
@property (nonatomic, strong) PromoVisit* pharmacyCircle;
@property (nonatomic, weak) IBOutlet UITableView* table;
@property (nonatomic, weak) IBOutlet UISegmentedControl* segmentedControl;
@property (nonatomic, weak) IBOutlet UIView* participantInput;
@property (nonatomic, weak) IBOutlet UITextField* participantField;
@property (nonatomic, weak) IBOutlet UIButton* addButton;
@property (nonatomic, weak) IBOutlet UIButton* editButton;
- (IBAction)modeSwitched:(id)sender;
- (IBAction)addParticipant:(id)sender;
- (IBAction)editParticipants:(id)sender;
@end
