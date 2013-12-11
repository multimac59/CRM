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

@interface ParticipantsViewController : UITableViewController<NewParticipantViewDelegate>
@property (nonatomic, strong) Conference* conference;
@end
