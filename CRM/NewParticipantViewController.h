//
//  NewBrandViewController.h
//  CRM
//
//  Created by FirstMac on 10.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NewParticipantViewDelegate
- (void)addParticipant:(NSString*)participant;
@end

@interface NewParticipantViewController : UIViewController
@property (nonatomic, weak) IBOutlet UITextField* participantField;
@property (nonatomic, weak) id<NewParticipantViewDelegate> delegate;
@end
