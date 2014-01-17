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
#import "ParticipantCell.h"

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
    
    UIButton* leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 63, 20)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"backButton"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"backButtonPressed"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    
    UIButton* addButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
    [addButton setBackgroundImage:[UIImage imageNamed:@"addButton"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageNamed:@"addButtonPressed"] forState:UIControlStateHighlighted];
    [addButton addTarget:self action:@selector(addParticipant) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:addButton];
    
    self.navigationItem.title = @"Участники";
    [self sortParticipants];
    [self.tableView reloadData];
    [self countParticipants];
    
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableSeparator§"]];
    [self.tableView setSeparatorColor:color];
}

- (void)back
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)countParticipants
{
    self.countLabel.text = [NSString stringWithFormat:@"%d", self.conference.participants.count];
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
    ParticipantCell* cell = [tableView dequeueReusableCellWithIdentifier:@"participantCell"];
    if (cell == nil)
    {
        cell = [[NSBundle mainBundle]loadNibNamed:@"ParticipantCell" owner:self options:nil][0];
    }
    Participant* participant = [self.participants objectAtIndex:indexPath.row];
    cell.nameLabel.text = participant.name;
    cell.checkmark.hidden = YES;
    return cell;
}

- (void)addParticipant
{
    NewParticipantViewController* participantViewController = [NewParticipantViewController new];
    participantViewController.delegate = self;
    ModalNavigationController* hostingController = [[ModalNavigationController alloc]initWithRootViewController:participantViewController];
    hostingController.modalPresentationStyle = UIModalPresentationFormSheet;
    hostingController.modalWidth = 540;
    hostingController.modalHeight = 130;
    
    AppDelegate* delegate = [AppDelegate sharedDelegate];
   [delegate.container presentViewController:hostingController animated:YES completion:^{
   }];
}

- (void)newParticipantViewController:(NewParticipantViewController *)newParticipantViewController didAddParticipant:(Participant *)participant
{
    [self.conference addParticipantsObject:participant];
    [self sortParticipants];
    [self.tableView reloadData];
    [self countParticipants];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end