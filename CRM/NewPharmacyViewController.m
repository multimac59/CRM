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
    self.title = @"Новый клиент";
    
    self.navigationController.navigationBar.translucent = NO;
    
    UIButton* cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 63, 20)];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButtonPressed"] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton"] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelButton];
    
    UIButton* saveButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 82, 20)];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"saveButtonPressed"] forState:UIControlStateNormal];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"saveButton"] forState:UIControlStateHighlighted];
    [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:saveButton];
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