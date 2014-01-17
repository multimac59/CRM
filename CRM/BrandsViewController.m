//
//  BrandsViewController.m
//  CRM
//
//  Created by FirstMac on 10.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "BrandsViewController.h"
#import "AppDelegate.h"
#import "NewBrandViewController.h"
#import "ParticipantCell.h"

@interface BrandsViewController ()
@property (nonatomic, strong) NSMutableArray* brands;
@property (nonatomic, strong) NSArray* sortedBrands;
@end

@implementation BrandsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIButton* leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 63, 20)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"backButton"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"backButtonPressed"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    
    UIButton* addButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
    [addButton setBackgroundImage:[UIImage imageNamed:@"addButton"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageNamed:@"addButtonPressed"] forState:UIControlStateHighlighted];
    [addButton addTarget:self action:@selector(addBrand) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:addButton];
    self.navigationItem.title = @"Бренды";
    
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Brand" inManagedObjectContext:context]];
    NSError *error = nil;
    _brands = [[context executeFetchRequest:request error:&error]mutableCopy];
    [self sortBrands];
    [self countBrands];
    
}

- (void)back
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)sortBrands
{
    //We must use it after fetching, because we can't pass self as key while fetching for some reason
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"self" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        if ([self.conference.brands containsObject:obj1] && ![self.conference.brands containsObject:obj2])
        {
            return NSOrderedAscending;
        }
        else if (![self.conference.brands containsObject:obj1] && [self.conference.brands containsObject:obj2])
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
    NSSortDescriptor* sortByNameDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
    _sortedBrands = [_brands sortedArrayUsingDescriptors:@[sortDescriptor, sortByNameDescriptor]];
}

- (void)countBrands
{
    self.countLabel.text = [NSString stringWithFormat:@"%d", self.brands.count];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sortedBrands.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"participantCell";
    ParticipantCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[NSBundle mainBundle]loadNibNamed:@"ParticipantCell" owner:self options:nil][0];
    }
    Brand* brand = self.sortedBrands[indexPath.row];
    cell.nameLabel.text = brand.name;
    if ([self.conference.brands containsObject:brand])
    {
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.checkmark.hidden = NO;
    }
    else
    {
        //cell.accessoryType = UITableViewCellAccessoryNone;
        cell.checkmark.hidden = YES;
    }
    // Configure the cell...
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ParticipantCell* cell = (ParticipantCell*)[tableView cellForRowAtIndexPath:indexPath];
    Brand* brand = self.sortedBrands[indexPath.row];
    if ([self.conference.brands containsObject:brand])
    {
        [self.conference removeBrandsObject:brand];
        //cell.accessoryType = UITableViewCellAccessoryNone;
        cell.checkmark.hidden = YES;
        
    }
    else
    {
        [self.conference addBrandsObject:brand];
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.checkmark.hidden = NO;
    }
}

- (void)addBrand
{
    NewBrandViewController* brandViewController = [NewBrandViewController new];
    brandViewController.delegate = self;
    ModalNavigationController* hostingController = [[ModalNavigationController alloc]initWithRootViewController:brandViewController];
    hostingController.modalPresentationStyle = UIModalPresentationFormSheet;
    hostingController.modalWidth = 540;
    hostingController.modalHeight = 130;
    [self presentViewController:hostingController animated:YES completion:nil];
}

- (void)newBrandViewController:(NewBrandViewController *)newBrandViewController didAddBrand:(Brand *)brand
{
    [self.brands addObject:brand];
    [self sortBrands];
    [self.tableView reloadData];
    [self countBrands];
    [self dismissViewControllerAnimated:YES completion:nil];
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
