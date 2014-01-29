//
//  VisitViewController.h
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Visit.h"
#import "Conference.h"
#import "YandexMapKit.h"


@interface VisitViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITabBarDelegate>

@property (nonatomic, strong) Conference* conference;
@property (nonatomic, strong) Visit* visit;
@property (nonatomic) BOOL isConference;
//@property (nonatomic, weak) IBOutlet UILabel* dateLabel;
//@property (nonatomic, weak) IBOutlet UILabel* timeLabel;
//@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
//@property (nonatomic, weak) IBOutlet UILabel* networkLabel;
//@property (nonatomic, weak) IBOutlet UILabel* addressLabel;
//@property (nonatomic, weak) IBOutlet UILabel* phoneLabel;
//@property (nonatomic, weak) IBOutlet UILabel* doctorLabel;

@property (nonatomic, weak) IBOutlet UITableView* table;

@property (nonatomic, weak) IBOutlet UIButton* brandsButton;
@property (nonatomic, weak) IBOutlet UIButton* participantsButton;
@property (nonatomic, weak) IBOutlet UIButton* salesButton;

@property (nonatomic, strong) NSMutableArray* oldVisits;

- (IBAction)goToSalesList:(id)sender;
- (IBAction)goToParticipants:(id)sender;
- (IBAction)goToBrands:(id)sender;
- (void)reloadContent;
@end
