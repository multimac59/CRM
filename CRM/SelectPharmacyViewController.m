//
//  SelectPharmacyViewController.m
//  CRM
//
//  Created by FirstMac on 16.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "SelectPharmacyViewController.h"
#import "AppDelegate.h"
#import "Pharmacy.h"
#import "ParticipantCell.h"

@interface SelectPharmacyViewController ()
@property (nonatomic, strong) NSArray* pharmacies;
@property (nonatomic, strong) NSArray* filteredPharmacies;
@end

@implementation SelectPharmacyViewController

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Pharmacy" inManagedObjectContext:context]];
    NSError *error = nil;
    _pharmacies = [context executeFetchRequest:request error:&error];
    _filteredPharmacies = _pharmacies;
    
    self.title = @"Клиенты";
    
    UIButton* backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 63, 20)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"backButton"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"backButtonPressed"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.filteredPharmacies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ParticipantCell *cell = [tableView dequeueReusableCellWithIdentifier:@"participantCell"];
    if (cell == nil)
    {
        cell = [[NSBundle mainBundle]loadNibNamed:@"ParticipantCell" owner:self options:nil][0];
    }
    Pharmacy* pharmacy = self.filteredPharmacies[indexPath.row];
    cell.nameLabel.text = pharmacy.name;
    if (pharmacy.pharmacyId == self.selectedPharmacy.pharmacyId)
        cell.checkmark.hidden = NO;
    else
        cell.checkmark.hidden = YES;
    // Configure the cell...
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPharmacy = self.filteredPharmacies[indexPath.row];
    [self.table reloadData];
    [self.delegate selectPharmacyDelegate:self didSelectPharmacy:self.selectedPharmacy];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"Trying to search with text = %@", searchText);
    if (!searchText || [searchText isEqualToString:@""])
    {
        _filteredPharmacies = _pharmacies;
    }
    else
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(name contains[cd] %@) || (network contains[cd] %@) || (city contains[cd] %@) || (street contains[cd] %@) || (house contains[cd] %@) || (phone contains[cd] %@) || (doctorName contains[cd] %@)", searchText, searchText, searchText, searchText, searchText, searchText, searchText];
        _filteredPharmacies = [_pharmacies filteredArrayUsingPredicate:predicate];
    }
    [self.table reloadData];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
