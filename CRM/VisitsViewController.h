//
//  VisitsViewController.h
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChoiseTableController.h"
#import "CKCalendarView.h"
#import "VisitViewController.h"

@interface VisitsViewController : UIViewController<CKCalendarDelegate>
@property (nonatomic, weak) IBOutlet UITableView* table;
@property (nonatomic, strong) CKCalendarView* calendarWidget;
@property (nonatomic, weak) IBOutlet UIView* calendarHeader;
@property (nonatomic, weak) IBOutlet UILabel* dateLabel;

@property (nonatomic, weak) VisitViewController* visitViewController;

- (void)reloadData;
@end
