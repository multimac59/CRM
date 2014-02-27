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

@interface VisitsViewController : UIViewController<CKCalendarDelegate>
@property (nonatomic, weak) IBOutlet UITableView* table;
@property (nonatomic, weak) IBOutlet UITableView* popoverTable;
@property (nonatomic, weak) IBOutlet UIView* calendarHeader;
@property (nonatomic, weak) IBOutlet UILabel* dateLabel;
- (IBAction)hidePopover:(id)sender;
@end
