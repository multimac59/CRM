//
//  PharmacyViewController.m
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "PharmacyViewController.h"

@interface PharmacyViewController ()

@end

@implementation PharmacyViewController

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

- (void)showPharmacy:(Pharmacy *)pharmacy
{
    self.navigationItem.title = pharmacy.name;
    self.nameLabel.text = pharmacy.name;
    self.networkLabel.text = pharmacy.network;
    self.phoneLabel.text = pharmacy.phone;
    self.doctorLabel.text = pharmacy.doctorName;
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@", pharmacy.city, pharmacy.street, pharmacy.house];
}

@end
