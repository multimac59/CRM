//
//  NewBrandViewController.m
//  CRM
//
//  Created by FirstMac on 10.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "NewBrandViewController.h"
#import "AppDelegate.h"
#import "Brand.h"

@interface NewBrandViewController ()

@end

@implementation NewBrandViewController

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
    self.navigationItem.title = @"Новый брэнд";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)save
{
    Brand* brand = [NSEntityDescription
                       insertNewObjectForEntityForName:@"Brand"
                       inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
    brand.name = self.brandField.text;
    [[AppDelegate sharedDelegate]saveContext];
    [self.delegate newBrandViewController:self didAddBrand:brand];
}
@end