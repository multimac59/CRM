//
//  NewVisitViewController.h
//  CRM
//
//  Created by FirstMac on 10.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Visit.h"
#import "Conference.h"
#import "NewParticipantViewController.h"
@class NewVisitViewController;
@protocol NewVisitViewDelegate
- (void)newVisitViewController:(NewVisitViewController*)newVisitViewController didAddVisit:(Visit*)visit;
- (void)newVisitViewController:(NewVisitViewController*)newVisitViewController didAddConference:(Conference*)conference;
@end

@interface NewVisitViewController : UIViewController
@property (nonatomic, weak) IBOutlet UITextField* dateField;
@property (nonatomic, weak) IBOutlet UITextField* timeField;
@property (nonatomic, weak) IBOutlet UITextField* nameField;
@property (nonatomic, weak) IBOutlet UITextField* participantsField;

@property (nonatomic, strong) NSArray* pharmacies;
@property (nonatomic) BOOL isConference;
@property (nonatomic, weak) IBOutlet UIView* conferenceControls;

@property (nonatomic, weak) id<NewVisitViewDelegate> delegate;

- (IBAction)addParticipant;
@end
