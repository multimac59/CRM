//
//  LoginViewController.m
//  CRM
//
//  Created by FirstMac on 11.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToMain:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.loginField)
    {
        [self.loginBgView setImage:[UIImage imageNamed:@"loginField"]];
    }
    else
    {
        [self.passwordBgView setImage:[UIImage imageNamed:@"passwordField"]];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.loginField)
    {
        [self.loginBgView setImage:[UIImage imageNamed:@"loginFieldActive"]];
    }
    else
    {
        [self.passwordBgView setImage:[UIImage imageNamed:@"passwordFieldActive"]];
    }
}

@end
