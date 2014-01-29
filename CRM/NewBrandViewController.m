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
    
    self.navigationController.navigationBar.translucent = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.brandField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardDidShow:(NSObject*)object
{
    NSLog(@"Look");
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