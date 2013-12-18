//
//  SalesViewController.m
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "SalesViewController.h"
#import "Visit.h"
#import "Drug.h"
#import "AppDelegate.h"
#import "SaleCell.h"
#import "User.h"

@interface SalesViewController ()

@end

@implementation SalesViewController

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
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    User* currentUser = [AppDelegate sharedDelegate].currentUser;
    NSLog(@"Table will contain %d drugs", currentUser.drugs.count);
    return currentUser.drugs.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SaleCell* cell = [tableView dequeueReusableCellWithIdentifier:@"sale"];
    if (cell == nil)
    {
        cell = [[NSBundle mainBundle]loadNibNamed:@"SaleCell" owner:self options:nil][0];
    }
    User* currentUser = [AppDelegate sharedDelegate].currentUser;
    Drug* drug = currentUser.drugs.allObjects[indexPath.row];
    NSLog(@"drug name = %@", drug.name);
    Sale* sale;
    if (self.segmentedControl.selectedSegmentIndex == 1)
    {
        sale = [self getMyLastSaleFor:drug];
    }
    else
    {
        sale = [self getLastSaleFor:drug];
    }
    
    Sale* currentSale;
    for (Sale* visitSale in self.visit.sales)
    {
        if (visitSale.drug == drug)
            currentSale = visitSale;
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd.MM.yyyy HH:mm";
    cell.drugLabel.text = drug.name;
    if (sale != nil)
    {
        cell.dateLabel.text = [dateFormatter stringFromDate:sale.visit.date];
        cell.nameLabel.text = sale.user.name;
        cell.orderLabel.text = [NSString stringWithFormat:@"%@", sale.order];
        cell.soldLabel.text = [NSString stringWithFormat:@"%@", sale.sold];
        cell.remainderLabel.text = [NSString stringWithFormat:@"%@", sale.remainder];
    }
    else
    {
        cell.dateLabel.text = @" - ";
        cell.nameLabel.text = @" - ";
        cell.orderLabel.text = @"0";
        cell.soldLabel.text = @"0";
        cell.remainderLabel.text = @"0";
    }
    if (currentSale != nil)
    {
        cell.orderField.text = [NSString stringWithFormat:@"%@", currentSale.order];
        cell.soldField.text = [NSString stringWithFormat:@"%@", currentSale.sold];
        cell.remainderField.text = [NSString stringWithFormat:@"%@", currentSale.remainder];
    }
    else
    {
        cell.orderField.text = @"0";
        cell.soldField.text = @"0";
        cell.remainderField.text = @"0";
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (Sale*)getLastSaleFor:(Drug*)drug
{
    NSMutableArray* sales = [NSMutableArray new];
    NSLog(@"total %d visits in pharmacy %@", self.visit.pharmacy.visits.count, self.visit.pharmacy.name);
    for (Visit* visit in self.visit.pharmacy.visits)
    {
        //We need to get data for old visits, not current
        if ([visit.date compare:self.visit.date] == NSOrderedSame || [visit.date compare:self.visit.date] == NSOrderedDescending)
        {
            NSLog(@"This is current visit date = %@, current date = %@", visit.date, self.visit.date);
            continue;
        }
        NSLog(@"This is old visit date = %@, current date = %@", visit.date, self.visit.date);
        //Here we get all old sales in the pharmacy for current drug
        for (Sale* sale in visit.sales)
        {
            if (sale.drug.drugId.integerValue == drug.drugId.integerValue)
            {
                [sales addObject:sale];
            }
        }
    }
    //Sort list by date, and return last
    if (sales.count > 0)
        return [self sortSales:sales][0];
    else
    {
        return nil;
    }
}

- (Sale*)getMyLastSaleFor:(Drug*)drug
{
    NSMutableArray* sales = [NSMutableArray new];
    for (Visit* visit in self.visit.pharmacy.visits)
    {
        if ([visit.date compare:self.visit.date] == NSOrderedSame || [visit.date compare:self.visit.date] == NSOrderedDescending)
            continue;
        for (Sale* sale in visit.sales)
        {
            if (sale.user.userId.integerValue == [AppDelegate sharedDelegate].currentUser.userId.integerValue && sale.drug.drugId.integerValue == drug.drugId.integerValue)
            {
                [sales addObject:sale];
            }
        }
    }
    if (sales.count > 0)
        return [self sortSales:sales][0];
    else
    {
        return nil;
    }
}

- (NSArray*)sortSales:(NSArray*)sales
{
    return [sales sortedArrayUsingComparator:^NSComparisonResult(Sale* sale1, Sale* sale2)
     {
         return [sale1.visit.date compare:sale2.visit.date];
     }];
}

- (IBAction)switchFilter:(id)sender
{
    [self.table reloadData];
}

- (IBAction)saveVisit:(id)sender
{
    User* currentUser = [AppDelegate sharedDelegate].currentUser;
    for (int i = 0; i < currentUser.drugs.count; i++)
    {
        Drug* drug = currentUser.drugs.allObjects[i];
        SaleCell* cell = (SaleCell*)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        Sale* sale = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Sale"
                      inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
        sale.drug = drug;
        sale.visit = self.visit;
        sale.user = currentUser;
        sale.sold = @(cell.soldField.text.integerValue);
        sale.remainder = @(cell.remainderField.text.integerValue);
        sale.order = @(cell.orderField.text.integerValue);
        [self.visit addSalesObject:sale];
    }
    [[AppDelegate sharedDelegate]saveContext];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end