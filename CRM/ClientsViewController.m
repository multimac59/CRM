//
//  ClientsViewController.m
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "ClientsViewController.h"
#import "PharmacyViewController.h"
#import "AppDelegate.h"
#import "Pharmacy.h"


@interface ClientsViewController ()

@end

@implementation ClientsViewController

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
    self.navigationItem.title = @"Аптеки";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonSystemItemAdd target:self action:@selector(addPharmacy)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [AppDelegate sharedDelegate].pharmacies.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    Pharmacy* pharmacy = [AppDelegate sharedDelegate].pharmacies[indexPath.row];
    cell.textLabel.text = pharmacy.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Clicked, row = %ld", (long)indexPath.row);
    Pharmacy* pharmacy = [AppDelegate sharedDelegate].pharmacies[indexPath.row];
    UINavigationController* hostController = [AppDelegate sharedDelegate].clientsSplitController.viewControllers[1];
    PharmacyViewController* pharmacyViewController = (PharmacyViewController*)hostController.topViewController;
    [pharmacyViewController showPharmacy:pharmacy];
}

- (void)addPharmacy
{
    NewPharmacyViewController* pharmacyViewController = [NewPharmacyViewController new];
    pharmacyViewController.delegate = self;
    UINavigationController* hostingController = [[UINavigationController alloc]initWithRootViewController:pharmacyViewController];
    hostingController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:hostingController animated:YES completion:nil];
}

- (void)addPharmacy:(Pharmacy *)pharmacy
{
    [[AppDelegate sharedDelegate].pharmacies addObject:pharmacy];
    [self.table reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
