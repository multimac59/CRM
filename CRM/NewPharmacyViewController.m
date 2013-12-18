//
//  NewPharmacyViewController.m
//  CRM
//
//  Created by FirstMac on 10.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "NewPharmacyViewController.h"
#import "Pharmacy.h"
#import "AppDelegate.h"

@interface NewPharmacyViewController ()

@end

@implementation NewPharmacyViewController

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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)save
{
    Pharmacy* pharmacy = [NSEntityDescription
                          insertNewObjectForEntityForName:@"Pharmacy"
                          inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
    pharmacy.name = self.nameField.text;
    pharmacy.network = self.networkField.text;
    pharmacy.city = self.cityField.text;
    pharmacy.street = self.streetField.text;
    pharmacy.house = self.houseField.text;
    pharmacy.phone = self.phoneField.text;
    pharmacy.doctorName = self.doctorField.text;
    pharmacy.visits = [NSSet new];
    [[AppDelegate sharedDelegate]saveContext];
    [self.delegate newPharmacyViewController:self didAddPharmacy:pharmacy];
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end