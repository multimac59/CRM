//
//  CommentViewController.m
//  CRM
//
//  Created by FirstMac on 17.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "CommentViewController.h"
#import "AppDelegate.h"

@interface CommentViewController ()

@end

@implementation CommentViewController

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
    
   // [Flurry logEvent:@"Переход" withParameters:@{@"Экран":@"Комментарий", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
    
    self.title = @"Комментарий";
    
    UIButton* leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 63, 20)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"backButton"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"backButtonPressed"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    
    self.textView.text = self.sale.comment;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back
{
    self.sale.comment = self.textView.text;
    [[AppDelegate sharedDelegate]saveContext];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
