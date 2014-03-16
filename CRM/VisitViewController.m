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
#import "NSDate+Additions.h"

@interface VisitViewController ()
@property (nonatomic, strong) Visit* visit;
@property (nonatomic, strong) NSArray* oldVisits;

@property (nonatomic, strong) UINavigationController* salesNavigationController;
@end

@implementation VisitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.oldVisits = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Show no more than 6 visits
    if (section == 1)
    {
        if (self.oldVisits.count < 6)
            return self.oldVisits.count + 1;
        else
            return 6;
    }
    else
        return 1;
}

- (void)showVisit:(Visit*)visit
{
    self.visit = visit;
    [self loadOldVisits];
    [self.table reloadData];
}

- (void)loadOldVisits
{
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Visit" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"pharmacy.pharmacyId=%@ AND date<%@", self.visit.pharmacy.pharmacyId, [NSDate currentDate]];
    [request setPredicate:predicate];
    NSError *error = nil;
    self.oldVisits = [context executeFetchRequest:request error:&error];
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
        [cell showVisit:self.visit];
        
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
        cell.allowPlanning = NO;
        [cell setMapLocationsForPharmacies:self.allPharmacies withSelectedPharmacy:self.selectedPharmacy onDate:self.planDate];
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
        return 260;
    else if (indexPath.section == 2)
        return 75;
    else if (indexPath.section == 3)
        return 408;
    else
        if (indexPath.row == 0)
            return 55;
        else
            return 40;
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
    UIButton* senderButton = sender;
    senderButton.enabled =  NO;
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
    }completion:^(BOOL finished) {
        senderButton.enabled = YES;
    }];
}
@end