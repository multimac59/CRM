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

@interface BrandsViewController ()
@property (nonatomic, strong) NSArray* brands;
@end

@implementation BrandsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonSystemItemAdd target:self action:@selector(addBrand)];
    self.navigationItem.title = @"Бренды";
    [self sortBrands];
    
}

- (void)sortBrands
{
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Brand" inManagedObjectContext:context]];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    _brands = [results sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
               {
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Brand" inManagedObjectContext:context]];
    [request setIncludesSubentities:NO];
    NSError *error = nil;
    NSInteger count = [context countForFetchRequest:request error:&error];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Brand* brand = self.brands[indexPath.row];
    cell.textLabel.text = brand.name;
    if ([self.conference.brands containsObject:brand])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    Brand* brand = self.brands[indexPath.row];
    if ([self.conference.brands containsObject:brand])
    {
        [self.conference removeBrandsObject:brand];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        [self.conference addBrandsObject:brand];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)addBrand
{
    NewBrandViewController* brandViewController = [NewBrandViewController new];
    brandViewController.delegate = self;
    UINavigationController* hostingController = [[UINavigationController alloc]initWithRootViewController:brandViewController];
    hostingController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:hostingController animated:YES completion:nil];
}

- (void)addBrand:(NSString *)brand
{
    Brand* newBrand = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Brand"
                    inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
    newBrand.name = brand;
    [self sortBrands];
    [self.tableView reloadData];
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
