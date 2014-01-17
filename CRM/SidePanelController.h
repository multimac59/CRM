//
//  SidePanelController.h
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SidePanelController;
@protocol SidePanelDelegate<NSObject>
- (void)sidePanelController:(SidePanelController*)controller didSelectItem:(NSInteger)item;
@end

@interface SidePanelController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) id<SidePanelDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITableView* table;
@end
