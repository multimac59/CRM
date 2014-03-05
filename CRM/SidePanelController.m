//
//  SidePanelController.m
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "SidePanelController.h"
#import "MFSideMenu.h"
#import "VisitsViewController.h"
#import "PharmaciesViewController.h"
#import "AppDelegate.h"
#import "TopicSideCell.h"

@interface SidePanelController ()

@end

@implementation SidePanelController

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
    self.navigationController.navigationBar.translucent = NO;
    // Do any additional setup after loading the view from its nib.
    [self.table registerNib:[UINib nibWithNibName:@"TopicSideCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"upperCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TopicSideCell* cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"upperCell"];
    switch (indexPath.row)
    {
        case 0:
            cell.topicLabel.text = @"Визиты";
            cell.tag = 0;
            break;
        case 1:
            cell.topicLabel.text = @"Клиенты";
            cell.tag = 1;
            break;
        case 2:
            cell.topicLabel.text = @"Отправить";
            cell.tag = 2;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate sidePanelController:self didSelectItem:indexPath.row];
    return;
    
    
    NSLog(@"Clicked, row = %ld", (long)indexPath.row);
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIViewController* targetController;
    switch (indexPath.row)
    {
        case 0:
            targetController = [AppDelegate sharedDelegate].visitsSplitController;
            //[Flurry logEvent:@"Переход" withParameters:@{@"Экран":@"Визиты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
            break;
        case 1:
            targetController = [AppDelegate sharedDelegate].clientsSplitController;
            //[Flurry logEvent:@"Переход" withParameters:@{@"Экран":@"Клиенты", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
        default:
            break;
    }
    if (targetController == nil)
        return;
    //very important for correct positioning inside container
    targetController.view.frame = CGRectMake(0, 0, 1024, 768);
    self.menuContainerViewController.centerViewController = targetController;
    self.menuContainerViewController.leftMenuViewController = self;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{}];
}

- (void)logout:(id)sender
{
    [[AppDelegate sharedDelegate]showLoginScreenWithAnimation:YES];
}
@end