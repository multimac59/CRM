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
#import "BrandCell.h"
#import "ParticipantCell.h"
#import "Visit.h"

@interface PharmacyCircleViewController ()
@property (nonatomic, strong) NSArray* drugs;
@end

@implementation PharmacyCircleViewController

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
    
    if ([self.pharmacyCircle isKindOfClass:[PharmacyCircle class]])
    {
        self.screenTitleLabel.text = @"Фармкружок";
        self.headerView.backgroundColor = [UIColor colorWithRed:149/255.0 green:198/255.0 blue:51/255.0 alpha:1];
    }
    else
    {
        self.screenTitleLabel.text = @"Промовизит";
        self.headerView.backgroundColor = [UIColor colorWithRed:111/255.0 green:89/255.0 blue:136/255.0 alpha:1];
    }
    
    NSManagedObjectContext* context = [[AppDelegate sharedDelegate]managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Drug" inManagedObjectContext:context]];
    NSError *error = nil;
    self.drugs = [context executeFetchRequest:request error:&error];
    
    [Flurry logEvent:@"Переход" withParameters:@{@"Экран":@"Промовизит/Фармкружок", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationItem.leftBarButtonItem = nil;
    self.participantField.text = [NSString stringWithFormat:@"%@", self.pharmacyCircle.participants];
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
    return self.drugs.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        BrandCell* brandCell = [tableView dequeueReusableCellWithIdentifier:@"brandCell"];
        if (!brandCell)
        {
            brandCell = [[NSBundle mainBundle]loadNibNamed:@"BrandCell" owner:self options:nil][0];
        }
        
        Drug* drug = self.drugs[indexPath.row];
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


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.pharmacyCircle.visit.closed.boolValue)
        return NO;
    NSString* finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.pharmacyCircle.participants = @(finalString.integerValue);
    [[AppDelegate sharedDelegate]saveContext];
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.pharmacyCircle.visit.closed.boolValue)
        return;
    
    Drug* brand = [self.drugs objectAtIndex:indexPath.row];
    if ([self.pharmacyCircle.brands containsObject:brand])
    {
        [self.pharmacyCircle removeBrandsObject:brand];
    }
    else
    {
        [self.pharmacyCircle addBrandsObject:brand];
    }
    [[AppDelegate sharedDelegate]saveContext];
    [self.table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)increaseParticipants:(id)sender
{
    if (self.pharmacyCircle.visit.closed.boolValue)
        return;
    int participants = self.pharmacyCircle.participants.integerValue;
    participants++;
    self.pharmacyCircle.participants = @(participants);
    self.participantField.text = [NSString stringWithFormat:@"%@", self.pharmacyCircle.participants];
    [[AppDelegate sharedDelegate]saveContext];
}

- (IBAction)decreaseParticipants:(id)sender
{
    if (self.pharmacyCircle.visit.closed.boolValue)
        return;
    int participants = self.pharmacyCircle.participants.integerValue;
    if (participants > 0)
    {
        participants--;
        self.pharmacyCircle.participants = @(participants);
        self.participantField.text = [NSString stringWithFormat:@"%@", self.pharmacyCircle.participants];
    }
    [[AppDelegate sharedDelegate]saveContext];
}
@end