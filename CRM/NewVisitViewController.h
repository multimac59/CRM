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
#import "SelectPharmacyViewController.h"
@class NewVisitViewController;
@protocol NewVisitViewDelegate
- (void)newVisitViewController:(NewVisitViewController*)newVisitViewController didAddVisit:(Visit*)visit;
- (void)newVisitViewController:(NewVisitViewController*)newVisitViewController didAddConference:(Conference*)conference;
@end

@interface NewVisitViewController : UIViewController<UISearchBarDelegate, SelectPharmacyDelegate>
@property (nonatomic, weak) IBOutlet UITextField* dateField;
@property (nonatomic, weak) IBOutlet UITextField* timeField;
@property (nonatomic, weak) IBOutlet UITextField* visitNameField;
@property (nonatomic, weak) IBOutlet UITextField* participantsField;
@property (nonatomic, weak) IBOutlet UISearchBar* searchBar;
@property (nonatomic, weak) IBOutlet UITableView* table;

@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* networkLabel;
@property (nonatomic, weak) IBOutlet UILabel* cityLabel;
@property (nonatomic, weak) IBOutlet UILabel* streetLabel;
@property (nonatomic, weak) IBOutlet UILabel* houseLabel;

@property (nonatomic) BOOL isConference;
@property (nonatomic, weak) IBOutlet UIView* conferenceControls;

@property (nonatomic, weak) id<NewVisitViewDelegate> delegate;

- (IBAction)addParticipant;
- (IBAction)selectPharmacy:(id)sender;
@end
