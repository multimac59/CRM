//
//  ParticipantsViewController.h
//  CRM
//
//  Created by FirstMac on 10.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Conference.h"
#import "NewParticipantViewController.h"

@interface ParticipantsViewController : UIViewController<NewParticipantViewDelegate>
@property (nonatomic, strong) Conference* conference;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UILabel* countLabel;
@end
