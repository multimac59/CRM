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
@property (nonatomic, strong) IBOutlet UITableView* table;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPharmacy:(Pharmacy *)pharmacy
{
    self.navigationItem.title = pharmacy.name;
    self.pharmacy = pharmacy;
    [self.table reloadData];
}

//- (void)setMapLocationForPharmacy:(Pharmacy*)pharmacy
//{
//    self.mapView.showTraffic = NO;
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [RaptureXMLResponseSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
//    NSString* address = [NSString stringWithFormat:@"г. %@ %@ %@", pharmacy.city, pharmacy.street, pharmacy.house];
//    NSString* urlString = [[NSString stringWithFormat:@"http://geocode-maps.yandex.ru/1.x/?geocode=%@", address]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, NSArray* positionArray)
//     {
//         NSLog(@"JSON: %@", positionArray);
//         if (positionArray.count == 0)
//         {
//             NSLog(@"Not found");
//             return;
//         }
//         CLLocation* location = positionArray[0];
//         
//         [self.mapView setCenterCoordinate:location.coordinate atZoomLevel:15 animated:YES];
//         MapAnnotation* annotation = [MapAnnotation new];
//         annotation.coordinate = location.coordinate;
//         annotation.title = address;
//         annotation.subtitle = @"";
//         [self.mapView removeAnnotations:self.mapView.annotations];
//         [self.mapView addAnnotation:annotation];
//     }
//         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             NSLog(@"Error: %@", error);
//         }];
//}

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
        cell.closeVisitButton.hidden = YES;
        
        [cell showPharmacy:self.pharmacy];
        if (self.favourite)
        {
            cell.favouriteButton.hidden = NO;
        }
        else
        {
            cell.favouriteButton.hidden = YES;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else //if (indexPath.row == 2)
    {
        VisitMapCell* cell = [tableView dequeueReusableCellWithIdentifier:@"VisitMapCell"];
        if (cell == nil)
        {
            cell = [[NSBundle mainBundle]loadNibNamed:@"VisitMapCell" owner:self options:nil][0];
        }
        [cell setMapLocationForPharmacy:self.pharmacy];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return 283;
    else
        return 408;
}

- (IBAction)removeFromFavourites:(id)sender
{
    self.favourite = NO;
    
    NSMutableDictionary* userDic = [NSMutableDictionary new];
    [userDic setObject:self.pharmacy forKey:@"Pharmacy"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"RemoveFromFavourites" object:self userInfo:userDic];
    
    [self.table reloadData];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches began");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches moved");
}
@end