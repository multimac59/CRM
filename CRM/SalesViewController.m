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
    if (sale != nil)
    {
    cell.dateLabel.text = [dateFormatter stringFromDate:sale.visit.date];
    cell.nameLabel.text = sale.user.name;
    cell.drugLabel.text = sale.drug.name;
    cell.orderLabel.text = [NSString stringWithFormat:@"%@", sale.order];
    cell.soldLabel.text = [NSString stringWithFormat:@"%@", sale.sold];
    cell.remainderLabel.text = [NSString stringWithFormat:@"%@", sale.remainder];
    }
    else
    {
        cell.dateLabel.text = @"";
        cell.nameLabel.text = @"";
        cell.drugLabel.text = @"";
        cell.orderLabel.text = @"";
        cell.soldLabel.text = @"";
        cell.remainderLabel.text = @"";
    }
    cell.orderField.text = [NSString stringWithFormat:@"%@", currentSale.order];
    cell.soldField.text = [NSString stringWithFormat:@"%@", currentSale.sold];
    cell.remainderField.text = [NSString stringWithFormat:@"%@", currentSale.remainder];
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
    for (Visit* visit in self.visit.pharmacy.visits)
    {
        if (visit.date >= self.visit.date)
            continue;
        for (Sale* sale in visit.sales)
        {
            if (sale.drug.drugId.integerValue == drug.drugId.integerValue)
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

- (Sale*)getMyLastSaleFor:(Drug*)drug
{
    NSMutableArray* sales = [NSMutableArray new];
    for (Visit* visit in self.visit.pharmacy.visits)
    {
        if (visit.date >= self.visit.date)
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
         if (sale1.visit.date > sale2.visit.date)
         {
             return NSOrderedAscending;
         }
         else if (sale1.visit.date < sale2.visit.date)
         {
             return NSOrderedDescending;
         }
         else
         {
             return NSOrderedSame;
         }
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
        Sale* sale = [Sale new];
        sale.drug = drug;
        sale.visit = self.visit;
        sale.user = currentUser;
        sale.sold = @(cell.soldField.text.integerValue);
        sale.remainder = @(cell.remainderField.text.integerValue);
        sale.order = @(cell.orderField.text.integerValue);
        [self.visit addSalesObject:sale];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end