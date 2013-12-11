//
//  ParticipantsViewController.m
//  CRM
//
//  Created by FirstMac on 10.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "ParticipantsViewController.h"
#import "NewParticipantViewController.h"

@interface ParticipantsViewController ()

@end

@implementation ParticipantsViewController

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonSystemItemAdd target:self action:@selector(addParticipant)];
    self.navigationItem.title = @"Участники";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.conference.participants.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = (NSString*)[self.conference.participants objectAtIndex:indexPath.row];
    return cell;
}

- (void)addParticipant
{
    NewParticipantViewController* participantViewController = [NewParticipantViewController new];
    participantViewController.delegate = self;
    UINavigationController* hostingController = [[UINavigationController alloc]initWithRootViewController:participantViewController];
    hostingController.modalPresentationStyle = UIModalPresentationFormSheet;
   [self presentViewController:hostingController animated:YES completion:nil];
}

- (void)addParticipant:(NSString *)participant
{
    [self.conference.participants addObject:participant];
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end