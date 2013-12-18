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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = @"Визиты";
            break;
        case 1:
            cell.textLabel.text = @"Клиенты";
            break;
        case 2:
            cell.textLabel.text = @"Цели";
            break;
        case 3:
            cell.textLabel.text = @"Синхронизация";
            break;
        case 4:
            cell.textLabel.text = @"Настройки";
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Clicked, row = %ld", (long)indexPath.row);
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIViewController* targetController;
    switch (indexPath.row)
    {
        case 0:
            targetController = [AppDelegate sharedDelegate].visitsSplitController;
            break;
        case 1:
            targetController = [AppDelegate sharedDelegate].clientsSplitController;
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
@end
