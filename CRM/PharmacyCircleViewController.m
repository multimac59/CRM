//
//  PharmacyCircleViewController.m
//  CRM
//
//  Created by FirstMac on 19.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "PharmacyCircleViewController.h"
#import "AppDelegate.h"
#import "Drug.h"
#import "Drug.h"
#import "PharmacyCircle.h"
#import "Participant.h"
#import "BrandCell.h"
#import "ParticipantCell.h"
#import "Visit.h"

@interface PharmacyCircleViewController ()
{
    BOOL editMode;
}
@end

@implementation PharmacyCircleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        brandsMode = YES;
        editMode = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.participantInput.hidden = YES;
    CGRect frame = self.table.frame;
    frame.size.height = self.view.frame.size.height - 97;
    frame.origin.y = 97;
    self.table.frame = frame;
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationItem.leftBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (brandsMode)
    {
        return [AppDelegate sharedDelegate].drugs.count;
    }
    else
        return self.pharmacyCircle.participants.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (brandsMode)
    {
        BrandCell* brandCell = [tableView dequeueReusableCellWithIdentifier:@"brandCell"];
        if (!brandCell)
        {
            brandCell = [[NSBundle mainBundle]loadNibNamed:@"BrandCell" owner:self options:nil][0];
        }
        
        Drug* drug = [AppDelegate sharedDelegate].drugs[indexPath.row];
        brandCell.nameLabel.text = drug.name;
        
        if ([self.pharmacyCircle.brands containsObject:drug])
        {
            //cell.accessoryType = UITableViewCellAccessoryCheckmark;
            brandCell.checkmark.hidden = NO;
        }
        else
        {
            //cell.accessoryType = UITableViewCellAccessoryNone;
            brandCell.checkmark.hidden = YES;
        }
        return brandCell;
    }
    else
    {
        ParticipantCell* participantCell = [tableView dequeueReusableCellWithIdentifier:@"participantCell"];
        if (!participantCell)
        {
            participantCell = [[NSBundle mainBundle]loadNibNamed:@"ParticipantCell" owner:self options:nil][0];
        }
        
        Participant* participant = self.pharmacyCircle.participants.allObjects[indexPath.row];
        participantCell.nameLabel.text = participant.name;
        if (editMode)
        {
            participantCell.deleteButton.hidden = NO;
            participantCell.deleteButtonWidth.constant = 14;
        }
        else
        {
            participantCell.deleteButton.hidden = YES;
            participantCell.deleteButtonWidth.constant = 0;
        }
        return participantCell;
    }
}

- (IBAction)addParticipant:(id)sender
{
    if (self.pharmacyCircle.visit.closed.boolValue)
        return;
    Participant* participant = [NSEntityDescription
                                              insertNewObjectForEntityForName:@"Participant"
                                              inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
    participant.name = self.participantField.text;
    [self.pharmacyCircle addParticipantsObject:participant];
    self.participantField.text = @"";
    [self.table reloadData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.table setEditing:editing animated:YES];
    if (editing) {
        self.addButton.enabled = NO;
    } else {
        self.addButton.enabled = YES;
    }
}

- (IBAction)editParticipants:(id)sender
{
    //[self setEditing:!self.table.editing animated:YES];
    if (!self.pharmacyCircle.visit.closed.boolValue)
    {
        editMode = !editMode;
        [self.table reloadData];
    }
}

/*
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Participant* participant = [self.pharmacyCircle.participants.allObjects objectAtIndex:indexPath.row];
    [self.pharmacyCircle removeParticipantsObject:participant];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!brandsMode || self.pharmacyCircle.visit.closed.boolValue)
        return;
    
    Drug* brand = [[AppDelegate sharedDelegate].drugs objectAtIndex:indexPath.row];
    if ([self.pharmacyCircle.brands containsObject:brand])
    {
        [self.pharmacyCircle removeBrandsObject:brand];
    }
    else
    {
        [self.pharmacyCircle addBrandsObject:brand];
    }
    [self.table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)leftSegmentPressed:(id)sender
{
    if (!brandsMode)
    {
        [self.leftSegment setBackgroundImage:[UIImage imageNamed:@"leftPinkPressed"] forState:UIControlStateNormal];
        [self.rightSegment setBackgroundImage:[UIImage imageNamed:@"rightPink"] forState:UIControlStateNormal];
        [self.leftSegment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rightSegment setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        brandsMode = YES;
        
        self.participantInput.hidden = YES;
        CGRect frame = self.table.frame;
        frame.size.height = self.view.frame.size.height - 97;
        frame.origin.y = 97;
        self.table.frame = frame;
        
        [self.table reloadData];
    }
}

- (IBAction)rightSegmentPressed:(id)sender
{
    if (brandsMode)
    {
        [self.leftSegment setBackgroundImage:[UIImage imageNamed:@"leftPink"] forState:UIControlStateNormal];
        [self.rightSegment setBackgroundImage:[UIImage imageNamed:@"rightPinkPressed"] forState:UIControlStateNormal];
        [self.leftSegment setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        [self.rightSegment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        brandsMode = NO;
        
        self.participantInput.hidden = NO;
        CGRect frame = self.table.frame;
        frame.size.height = self.view.frame.size.height - 144;
        frame.origin.y = 144;
        self.table.frame = frame;
        
        [self.table reloadData];
    }
}

- (IBAction)deleteParticipant:(id)sender
{
    CGPoint center= ((UIButton*)sender).center;
    CGPoint rootViewPoint = [((UIButton*)sender).superview convertPoint:center toView:self.table];
    NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:rootViewPoint];
    Participant* participant = [self.pharmacyCircle.participants.allObjects objectAtIndex:indexPath.row];
    [self.pharmacyCircle removeParticipantsObject:participant];
    [self.table reloadData];
}
@end