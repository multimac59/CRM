//
//  VisitViewController.m
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "VisitViewController.h"
#import "SalesViewController.h"
#import "ParticipantsViewController.h"
#import "BrandsViewController.h"
#import "AFNetworking.h"
#import "RaptureXMLResponseSerializer.h"
#import "MapAnnotation.h"
#import "UIViewController+ShowModalFromView.h"
#import "AppDelegate.h"

#import "VisitInfoCell.h"
#import "VisitHistoryCell.h"
#import "VisitButtonsCell.h"
#import "VisitMapCell.h"

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

- (IBAction)goToSalesList:(id)sender
{
    SalesViewController* salesViewController = [SalesViewController new];
    salesViewController.visit = self.visit;
    self.salesNavigationController = [[UINavigationController alloc]initWithRootViewController:salesViewController];
    //CATransition *transition = [CATransition animation];
    //transition.duration = 0.35;
    //transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //transition.type = kCATransitionMoveIn;
    //transition.subtype = kCATransitionFromBottom;
    //[self.view.window.layer addAnimation:transition forKey:nil];
    //[delegate.visitsSplitController presentViewController:navController animated:NO completion:^{
    //}];
    //[self.navigationController pushViewController:salesViewController animated:YES];
    
    
    
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

- (void)back
{
    NSLog(@"back");
}

- (void)goToParticipants:(id)sender
{
    ParticipantsViewController* participantsViewController = [ParticipantsViewController new];
    participantsViewController.conference = self.conference;
    [self.navigationController pushViewController:participantsViewController animated:YES];
}

- (void)goToBrands:(id)sender
{
    BrandsViewController* brandsViewController = [BrandsViewController new];
    brandsViewController.conference = self.conference;
    [self.navigationController pushViewController:brandsViewController animated:YES];
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
    if (self.isConference)
    {
        self.title = self.conference.pharmacy.name;
    }
    else
    {
        self.title = self.visit.pharmacy.name;
    }
    [self.oldVisits removeAllObjects];
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Visit" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"pharmacy.pharmacyId=%@", self.visit.pharmacy.pharmacyId];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray* visits = [context executeFetchRequest:request error:&error];
    [self.oldVisits addObjectsFromArray:visits];
    [request setEntity:[NSEntityDescription entityForName:@"Conference" inManagedObjectContext:context]];
    NSArray* conferences = [context executeFetchRequest:request error:&error];
    [self.oldVisits addObjectsFromArray:conferences];
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
        if (self.isConference)
        {
            [cell showConference:self.conference];
        }
        else
        {
            [cell showVisit: self.visit];
        }
        return cell;
    }
    else if (indexPath.section == 2)
    {
        return [[NSBundle mainBundle]loadNibNamed:@"VisitButtonsCell" owner:self options:nil][0];
    }
    else if (indexPath.section == 3)
    {
        VisitMapCell* cell = [tableView dequeueReusableCellWithIdentifier:@"VisitMapCell"];
        if (cell == nil)
        {
            cell = [[NSBundle mainBundle]loadNibNamed:@"VisitMapCell" owner:self options:nil][0];
        }
        if (self.isConference)
        {
            [cell setMapLocationForPharmacy:self.conference.pharmacy];
        }
        else
        {
            [cell setMapLocationForPharmacy:self.visit.pharmacy];
        }
        return cell;
    }
    else
    {
        if (indexPath.row == 0)
        {
            return [[NSBundle mainBundle]loadNibNamed:@"VisitHistoryHeader" owner:self options:nil][0];
        }
        else
        {
            VisitHistoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"VisitHistoryCell"];
            if (cell == nil)
            {
                cell =[[NSBundle mainBundle]loadNibNamed:@"VisitHistoryCell" owner:self options:nil][0];
            }
            NSManagedObject* object = self.oldVisits[indexPath.row - 1];
            if ([object isKindOfClass:[Visit class]])
            {
                [cell showVisit:(Visit*)object];
            }
            else
            {
                [cell showConference:(Conference*)object];
            }
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
@end