//
//  PharmacyViewController.m
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "PharmacyViewController.h"
#import "YandexMapKit.h"
#import "AFNetworking.h"
#import "RaptureXMLResponseSerializer.h"
#import "MapAnnotation.h"
#import "VisitInfoCell.h"
#import "VisitMapCell.h"

@interface PharmacyViewController ()
@property (nonatomic, weak) IBOutlet YMKMapView* mapView;
@property (nonatomic, strong) Pharmacy* pharmacy;
@end

@implementation PharmacyViewController

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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPharmacy:(Pharmacy *)pharmacy
{
    self.pharmacy = pharmacy;
    [self.table reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        VisitInfoCell* cell = [tableView dequeueReusableCellWithIdentifier:@"VisitInfoCell"];
        if (cell == nil)
        {
            cell =[[NSBundle mainBundle]loadNibNamed:@"VisitInfoCell" owner:self options:nil][0];
        }
        
        [cell showPharmacy:self.pharmacy];
    
        cell.closeVisitButton.hidden = YES;
        //cell.favouriteButton.hidden = !self.favourite;
        cell.favouriteButton.hidden = YES;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        VisitMapCell* cell = [tableView dequeueReusableCellWithIdentifier:@"VisitMapCell"];
        if (cell == nil)
        {
            cell = [[NSBundle mainBundle]loadNibNamed:@"VisitMapCell" owner:self options:nil][0];
        }
        //TODO: switch off map for now
        //[cell setMapLocationsForPharmacies:self.allPharmacies onDate:self.planDate];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return 260;
    else
        return 510;
}

- (IBAction)removeFromFavourites:(id)sender
{
    self.favourite = NO;
    
    NSMutableDictionary* userDic = [NSMutableDictionary new];
    [userDic setObject:self.pharmacy forKey:@"Pharmacy"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"RemoveFromFavourites" object:self userInfo:userDic];
    
    [self.table reloadData];
}

- (void)reloadMap
{
    [self.table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}
@end