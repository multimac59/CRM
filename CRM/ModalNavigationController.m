//
//  ModalNavigationController.m
//  CRM
//
//  Created by FirstMac on 16.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "ModalNavigationController.h"

@interface ModalNavigationController ()

@end

@implementation ModalNavigationController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0, 0, self.modalWidth, self.modalHeight);
}
@end
