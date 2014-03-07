//
//  LoginViewController.m
//  CRM
//
//  Created by FirstMac on 11.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "LoginViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "NSString+MD5Extension.h"
#import "AppDelegate.h"

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
    [self hideLoader];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSNumber* lastId = [[NSUserDefaults standardUserDefaults]objectForKey:@"lastUserId"];
    User* user = [[AppDelegate sharedDelegate]findUserById:lastId.integerValue];
    if (user)
    {
        self.loginField.text = user.login;
    }
    
}

- (void)showLoader
{
    self.overlay.alpha = 0.5;
    [self.activityIndicator startAnimating];
}

- (void)hideLoader
{
    self.overlay.alpha = 0;
    [self.activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)test
//{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager GET:[NSString stringWithFormat:@"http://crm.mydigital.guru/server/sync", login, hashedPassword] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary* jsonDic)
//     {
//}

- (IBAction)goToMain:(id)sender
{

    NSString* login = self.loginField.text;
    NSString* password = self.passwordField.text;
    
    NSString* hashedPassword = [password md5];
    
    User* user = [[AppDelegate sharedDelegate]findUserByLogin:login andPassword:hashedPassword];
    if (user != nil)
    {
        [[NSUserDefaults standardUserDefaults]setObject:user.userId forKey:@"lastUserId"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [AppDelegate sharedDelegate].currentUser = user;
        //[Flurry logEvent:@"Логин" withParameters:@{@"Пользователь" : user.login, @"Дата" : [NSDate date]}];
        [self showLoader];
        [[AppDelegate sharedDelegate]loadDataFromServer];
        //[self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:[NSString stringWithFormat:@"http://crm.mydigital.guru/server/auth?email=%@&passwd=%@", login, hashedPassword] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary* jsonDic)
        {
            //if success
            NSDictionary* okDict = [jsonDic objectForKey:@"ok"];
            if (okDict)
            {
                User* user = [NSEntityDescription
                 insertNewObjectForEntityForName:@"User"
                 inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
                user.userId = [okDict objectForKey:@"id"];
                user.login = login;
                user.password = hashedPassword;
                
//                NSArray* regions = @[@1, @2];
//                [regions enumerateObjectsUsingBlock:^(NSNumber* regionObj, NSUInteger idx, BOOL *stop) {
//                    NSInteger regionId = [regionObj integerValue];
//                    Region* region = [[AppDelegate sharedDelegate]findRegionById:regionId];
//                    [user addRegionsObject:region];
//                }];
                
                [AppDelegate sharedDelegate].currentUser = user;
                
                [[NSUserDefaults standardUserDefaults]setObject:user.userId forKey:@"lastUserId"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                //[Flurry logEvent:@"Логин" withParameters:@{@"Пользователь" : user.login, @"Дата" : [NSDate date]}];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                UIAlertView* alert;
                NSDictionary* errorDict = [jsonDic objectForKey:@"error"];
                if (errorDict)
                {
                    alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Неверный логин / пароль." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                }
                else
                {
                    alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Произошла неизвестная ошибка." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                }
                [alert show];
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Сервер недоступен." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    }
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self goToMain:self];
    return YES;
}

@end
