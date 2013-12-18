//
//  NewBrandViewController.h
//  CRM
//
//  Created by FirstMac on 10.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Participant.h"

@class NewParticipantViewController;
@protocol NewParticipantViewDelegate
- (void)newParticipantViewController:(NewParticipantViewController*)newParticipantViewController didAddParticipant:(Participant*)participant;
@end

@interface NewParticipantViewController : UIViewController
@property (nonatomic, weak) IBOutlet UITextField* participantField;
@property (nonatomic, weak) id<NewParticipantViewDelegate> delegate;
@end
