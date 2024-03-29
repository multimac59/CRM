//
//  PharmacyCircleViewController.h
//  CRM
//
//  Created by FirstMac on 19.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PromoVisit.h"

@interface PharmacyCircleViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{}
@property (nonatomic, strong) PromoVisit* pharmacyCircle;
@property (nonatomic, weak) IBOutlet UITableView* table;
@property (nonatomic, weak) IBOutlet UITextField* participantField;
@property (nonatomic, weak) IBOutlet UILabel* screenTitleLabel;
@property (nonatomic, weak) IBOutlet UIView* headerView;

- (IBAction)goBack:(id)sender;
- (IBAction)increaseParticipants:(id)sender;
- (IBAction)decreaseParticipants:(id)sender;
@end
