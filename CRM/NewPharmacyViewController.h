//
//  NewPharmacyViewController.h
//  CRM
//
//  Created by FirstMac on 10.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pharmacy.h"

@class NewPharmacyViewController;

@protocol NewPharmacyViewDelegate
- (void)newPharmacyViewController:(NewPharmacyViewController*)newPharmacyViewcontroller didAddPharmacy:(Pharmacy*)pharmacy;
@end

@interface NewPharmacyViewController : UIViewController
@property (nonatomic, weak) IBOutlet UITextField* nameField;
@property (nonatomic, weak) IBOutlet UITextField* networkField;
@property (nonatomic, weak) IBOutlet UITextField* cityField;
@property (nonatomic, weak) IBOutlet UITextField* streetField;
@property (nonatomic, weak) IBOutlet UITextField* houseField;
@property (nonatomic, weak) IBOutlet UITextField* phoneField;
@property (nonatomic, weak) IBOutlet UITextField* doctorField;
@property (nonatomic, weak) id<NewPharmacyViewDelegate> delegate;
@end
