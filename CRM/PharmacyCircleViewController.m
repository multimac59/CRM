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

@interface PharmacyCircleViewController ()
{
    NSIndexPath* selectedIndexPath;
}
@end

@implementation PharmacyCircleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        brandsMode = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.participantInput.hidden = YES;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)modeSwitched:(id)sender
{
    brandsMode = !self.segmentedControl.selectedSegmentIndex;
    self.participantInput.hidden = brandsMode;
    [self.table reloadData];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (brandsMode)
    {
        Drug* drug = [AppDelegate sharedDelegate].drugs[indexPath.row];
        cell.textLabel.text = drug.name;
        
        if ([self.pharmacyCircle.brands containsObject:drug])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else
    {
        Participant* participant = self.pharmacyCircle.participants.allObjects[indexPath.row];
        cell.textLabel.text = participant.name;
    }
    return cell;
}

- (IBAction)addParticipant:(id)sender
{
    Participant* participant = [NSEntityDescription
                                              insertNewObjectForEntityForName:@"Participant"
                                              inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
    participant.name = self.participantField.text;
    [self.pharmacyCircle addParticipantsObject:participant];
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
    [self setEditing:!self.table.editing animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Participant* participant = [self.pharmacyCircle.participants.allObjects objectAtIndex:indexPath.row];
    [self.pharmacyCircle removeParticipantsObject:participant];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndexPath = indexPath;
    Drug* brand = [[AppDelegate sharedDelegate].drugs objectAtIndex:indexPath.row];
    [self.pharmacyCircle addBrandsObject:brand];
    [self.table reloadData];
}
@end