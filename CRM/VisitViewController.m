//
//  VisitViewController.m
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "VisitViewController.h"
#import "SalesViewController.h"
#import "AFNetworking.h"
#import "RaptureXMLResponseSerializer.h"
#import "MapAnnotation.h"
#import "AppDelegate.h"
#import "PharmacyCircleViewController.h"

#import "VisitInfoCell.h"
#import "VisitHistoryCell.h"
#import "VisitButtonsCell.h"
#import "VisitMapCell.h"
#import "VisitButtonsCell.h"
#import "PromoVisit.h"
#import "PharmacyCircle.h"

@interface VisitViewController ()
@property (nonatomic, weak) IBOutlet YMKMapView* mapView;
@property (nonatomic, strong) UINavigationController* salesNavigationController;
@end

@implementation VisitViewController

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
    self.navigationController.navigationBar.translucent = NO;
    self.oldVisits = [NSMutableArray new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





/*

 */



- (void)back
{
    NSLog(@"back");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
    {
        return self.oldVisits.count + 1;
    }
    else
        return 1;
}

- (void)reloadContent
{

    self.title = self.visit.pharmacy.name;
    [self.oldVisits removeAllObjects];
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Visit" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"pharmacy.pharmacyId=%@", self.visit.pharmacy.pharmacyId];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray* visits = [context executeFetchRequest:request error:&error];
    [self.oldVisits addObjectsFromArray:visits];
    [self.table reloadData];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        VisitInfoCell* cell = [tableView dequeueReusableCellWithIdentifier:@"VisitInfoCell"];
        if (cell == nil)
        {
            cell =[[NSBundle mainBundle]loadNibNamed:@"VisitInfoCell" owner:self options:nil][0];
        }
        [cell showVisit:self.visit];
        cell.favouriteButton.hidden = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.section == 2)
    {
        VisitButtonsCell* cell = [[NSBundle mainBundle]loadNibNamed:@"VisitButtonsCell" owner:self options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.section == 3)
    {
        VisitMapCell* cell = [tableView dequeueReusableCellWithIdentifier:@"VisitMapCell"];
        if (cell == nil)
        {
            cell = [[NSBundle mainBundle]loadNibNamed:@"VisitMapCell" owner:self options:nil][0];
        }
        [cell setMapLocationForPharmacy:self.visit.pharmacy];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        if (indexPath.row == 0)
        {
            UITableViewCell* cell = [[NSBundle mainBundle]loadNibNamed:@"VisitHistoryHeader" owner:self options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else
        {
            VisitHistoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"VisitHistoryCell"];
            if (cell == nil)
            {
                cell =[[NSBundle mainBundle]loadNibNamed:@"VisitHistoryCell" owner:self options:nil][0];
            }
            NSManagedObject* object = self.oldVisits[indexPath.row - 1];

            [cell showVisit:(Visit*)object];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return 269;
    else if (indexPath.section == 2)
        return 90;
    else if (indexPath.section == 3)
        return 408;
    else
        if (indexPath.row == 0)
            return 79;
        else
            return 28;
}

- (IBAction)closeVisit:(id)sender
{
    if (self.visit)
    {
        self.visit.closed = @YES;
        [[AppDelegate sharedDelegate]saveContext];
        [self.table reloadData];
    }
}

- (IBAction)goToPharmacyCircle:(id)sender
{
    PharmacyCircleViewController* pharmacyCircleViewController = [PharmacyCircleViewController new];
    if (!self.visit.pharmacyCircle)
        self.visit.pharmacyCircle = [NSEntityDescription
                                insertNewObjectForEntityForName:@"PharmacyCircle"
                                inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
    pharmacyCircleViewController.pharmacyCircle = self.visit.pharmacyCircle;
    [self.navigationController pushViewController:pharmacyCircleViewController animated:YES];
}

- (IBAction)goToPromoVisit:(id)sender
{
    PharmacyCircleViewController* pharmacyCircleViewController = [PharmacyCircleViewController new];
    if (!self.visit.promoVisit)
        self.visit.promoVisit = [NSEntityDescription
                                 insertNewObjectForEntityForName:@"PromoVisit"
                                 inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
    pharmacyCircleViewController.pharmacyCircle = self.visit.promoVisit;
    [self.navigationController pushViewController:pharmacyCircleViewController animated:YES];
}

- (IBAction)goToSalesList:(id)sender
{
    SalesViewController* salesViewController = [SalesViewController new];
    AppDelegate* sharedDelegate = [AppDelegate sharedDelegate];
    NSManagedObjectContext* context = [sharedDelegate managedObjectContext];
    if (!self.visit.commerceVisit)
        self.visit.commerceVisit = [NSEntityDescription
                                insertNewObjectForEntityForName:@"CommerceVisit"
                                inManagedObjectContext:context];
    salesViewController.commerceVisit = self.visit.commerceVisit;
    self.salesNavigationController = [[UINavigationController alloc]initWithRootViewController:salesViewController];
    
    //DIRTY, DIRTY HACK
    int y;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        y = - 20;
    }
    else
    {
        y = 0;
    }
    self.salesNavigationController.view.frame = CGRectMake(1024, y, 1024, 768);
    AppDelegate* delegate = [AppDelegate sharedDelegate];
    [delegate.container.view addSubview:self.salesNavigationController.view];
    [UIView animateWithDuration:0.3 animations:^{
        self.salesNavigationController.view.frame = CGRectMake(0, y, 1024, 768);
    }];
}
@end