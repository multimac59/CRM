//
//  ClientsViewController.h
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKCalendarView.h"
#import "PharmacyViewController.h"

@interface PharmaciesViewController : UIViewController<UITextFieldDelegate, CKCalendarDelegate>
@property (nonatomic, weak) IBOutlet UITableView* table;
@property (nonatomic, weak) IBOutlet UIView* filterView;
@property (nonatomic, strong) CKCalendarView* calendarWidget;

@property (nonatomic, weak) IBOutlet UIView* segmentedControl;
@property (nonatomic, weak) IBOutlet UIButton* leftSegment;
@property (nonatomic, weak) IBOutlet UIButton* rightSegment;

@property (nonatomic, weak) IBOutlet UILabel* targetLabel;
@property (nonatomic, strong) IBOutlet UITextField* filterField;

@property (nonatomic, weak) IBOutlet UIView* calendarHeader;
@property (nonatomic, weak) IBOutlet UILabel* dateLabel;

@property (nonatomic, weak) IBOutlet UIButton* targetButton;

@property (nonatomic, weak) PharmacyViewController* pharmacyViewController;

- (IBAction)leftSegmentPressed:(id)sender;
- (IBAction)rightSegmentPressed:(id)sender;
- (IBAction)targetSwitched:(id)sender;

- (IBAction)commerceVisitClicked:(id)sender;
- (IBAction)promoVisitClicked:(id)sender;
- (IBAction)pharmacyCircleClicked:(id)sender;

- (void)reloadData;
- (void)selectFirstFromList;
@end
