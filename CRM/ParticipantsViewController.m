//
//  ParticipantsViewController.m
//  CRM
//
//  Created by FirstMac on 10.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "ParticipantsViewController.h"
#import "NewParticipantViewController.h"
#import "AppDelegate.h"
#import "Participant.h"

@interface ParticipantsViewController ()
{
}
@property (nonatomic, strong) NSArray* participants;
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
    [self sortParticipants];
    [self.tableView reloadData];
}

- (void)sortParticipants
{
    NSSortDescriptor* sortByNameDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
    _participants = [self.conference.participants sortedArrayUsingDescriptors:@[sortByNameDescriptor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.participants count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    Participant* participant = [self.participants objectAtIndex:indexPath.row];
    cell.textLabel.text = participant.name;
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

- (void)newParticipantViewController:(NewParticipantViewController *)newParticipantViewController didAddParticipant:(Participant *)participant
{
    [self.conference addParticipantsObject:participant];
    [self sortParticipants];
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end