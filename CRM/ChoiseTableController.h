//
//  ChoiseTableController.h
//  CRM
//
//  Created by FirstMac on 10.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChoiseTableController;
@protocol ChoiseTableDelegate
- (void)choiseTableController:(ChoiseTableController*)choiseTableController didFinishWithResult:(NSInteger)result;
@end

@interface ChoiseTableController : UITableViewController
@property (nonatomic, weak) id<ChoiseTableDelegate> delegate;
@end
