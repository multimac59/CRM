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
    
    //[Flurry logEvent:@"Переход" withParameters:@{@"Экран":@"Промовизит/Фармкружок", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
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

        return [AppDelegate sharedDelegate].drugs.count;

}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
@end