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
@property (nonatomic, strong) NSArray* drugs;
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
    User* currentUser = [AppDelegate sharedDelegate].currentUser;
    NSSortDescriptor* sortByNameDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
    _drugs = [currentUser.drugs.allObjects sortedArrayUsingDescriptors:@[sortByNameDescriptor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Table will contain %lu drugs", (unsigned long)self.drugs.count);
    return self.drugs.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SaleCell* cell = [tableView dequeueReusableCellWithIdentifier:@"sale"];
    if (cell == nil)
    {
        cell = [[NSBundle mainBundle]loadNibNamed:@"SaleCell" owner:self options:nil][0];
    }
    Drug* drug = self.drugs[indexPath.row];
    //NSLog(@"drug name = %@", drug.name);
    Sale* lastSale;
    if (self.segmentedControl.selectedSegmentIndex == 1)
    {
        lastSale = [self getLastSaleFor:drug mySale:YES];
    }
    else
    {
        lastSale = [self getLastSaleFor:drug mySale:NO];
    }
    
    Sale* currentSale = [self getCurrentSaleFor:drug];
    
    for (Sale* visitSale in self.visit.sales)
    {
        if (visitSale.drug == drug)
            currentSale = visitSale;
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd.MM.yyyy HH:mm";
    cell.drugLabel.text = drug.name;
    if (lastSale != nil)
    {
        cell.dateLabel.text = [dateFormatter stringFromDate:lastSale.visit.date];
        cell.nameLabel.text = lastSale.user.name;
        cell.orderLabel.text = [NSString stringWithFormat:@"%@", lastSale.order];
        cell.soldLabel.text = [NSString stringWithFormat:@"%@", lastSale.sold];
        cell.remainderLabel.text = [NSString stringWithFormat:@"%@", lastSale.remainder];
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

- (Sale*)getCurrentSaleFor:(Drug*)drug
{
    //Or use predicate instead
    for (Sale* currentSale in self.visit.sales)
    {
        if (currentSale.drug == drug)
            return currentSale;
    }
    return nil;
}

- (Sale*)getLastSaleFor:(Drug*)drug mySale:(BOOL)isMine
{
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Sale" inManagedObjectContext:context]];
    NSPredicate* predicate;
    if (isMine)
        predicate = [NSPredicate predicateWithFormat:@"(visit.pharmacy=%@) && (visit.date<%@) && (drug=%@) && (visit.user=%@)", self.visit.pharmacy, self.visit.date, drug, [AppDelegate sharedDelegate].currentUser];
    else
        predicate = [NSPredicate predicateWithFormat:@"(visit.pharmacy=%@) && (visit.date<%@) && (drug=%@)", self.visit.pharmacy, self.visit.date, drug];
    NSSortDescriptor* sortByDateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"visit.date" ascending:YES];
    request.predicate = predicate;
    request.sortDescriptors = @[sortByDateDescriptor];
    request.fetchLimit = 1;
    NSError *error = nil;
    NSArray* sales = [[context executeFetchRequest:request error:&error]mutableCopy];
    return sales.count>0 ? sales[0] : nil;
}

- (IBAction)switchFilter:(id)sender
{
    [self.table reloadData];
}

- (IBAction)saveVisit:(id)sender
{
    User* currentUser = [AppDelegate sharedDelegate].currentUser;
    for (int i = 0; i < self.drugs.count; i++)
    {
        Drug* drug = self.drugs[i];
        SaleCell* cell = (SaleCell*)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        Sale* sale = [self getCurrentSaleFor:drug];
        if (!sale)
            sale = [NSEntityDescription
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 110;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[[NSBundle mainBundle]loadNibNamed:@"SaleHeader" owner:self options:nil]firstObject];
}
@end