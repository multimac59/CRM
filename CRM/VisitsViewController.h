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

@interface VisitsViewController : UIViewController<NewVisitViewDelegate, ChoiseTableDelegate>
@property (nonatomic, weak) IBOutlet UITableView* table;
@property (nonatomic, weak) IBOutlet UIDatePicker* datePicker;
- (IBAction)changeFilterDate:(id)sender;
@end
