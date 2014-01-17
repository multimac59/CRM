//
//  BrandsViewController.h
//  CRM
//
//  Created by FirstMac on 10.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Conference.h"
#import "Brand.h"
#import "NewBrandViewController.h"

@interface BrandsViewController : UIViewController<NewBrandViewDelegate>
@property (nonatomic, weak) Conference* conference;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UILabel* countLabel;
@end
