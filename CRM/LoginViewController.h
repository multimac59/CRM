//
//  LoginViewController.h
//  CRM
//
//  Created by FirstMac on 11.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate>
- (IBAction)goToMain:(id)sender;

@property (nonatomic, weak) IBOutlet UIImageView* loginBgView;
@property (nonatomic, weak) IBOutlet UIImageView* passwordBgView;
@property (nonatomic, weak) IBOutlet UITextField* loginField;
@property (nonatomic, weak) IBOutlet UITextField* passwordField;
@end
