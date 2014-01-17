//
//  NewBrandViewController.m
//  CRM
//
//  Created by FirstMac on 10.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "NewParticipantViewController.h"
#import "AppDelegate.h"

@interface NewParticipantViewController ()

@end

@implementation NewParticipantViewController

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
    UIButton* cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 63, 20)];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton"] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButtonPressed"] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelButton];
    
    UIButton* saveButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 82, 20)];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"saveButton"] forState:UIControlStateNormal];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"saveButtonPressed"] forState:UIControlStateHighlighted];
    [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:saveButton];
    self.navigationItem.title = @"Новый участник";
    
    self.navigationController.navigationBar.translucent = NO;
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

- (void)viewWillAppear:(BOOL)animated
{
    //VERY IMPORTANT!!! REMOVE KEYBOARD SHIFT
    [self.participantField becomeFirstResponder];
}

- (void)save
{
    Participant* participant = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"Participant"
                                   inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
    participant.name = self.participantField.text;
    [[AppDelegate sharedDelegate]saveContext];
    [self.delegate newParticipantViewController:self didAddParticipant:participant];
}
@end
