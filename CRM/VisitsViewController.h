//
//  VisitsViewController.h
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewVisitViewController.h"
#import "ChoiseTableController.h"
#import "CKCalendarView.h"

@interface VisitsViewController : UIViewController<NewVisitViewDelegate, ChoiseTableDelegate, CKCalendarDelegate>
@property (nonatomic, weak) IBOutlet UITableView* table;
@end
