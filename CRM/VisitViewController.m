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

@interface VisitViewController ()
@property (nonatomic, strong) Conference* conference;
@property (nonatomic, strong) Visit* visit;
@property (nonatomic) BOOL isConference;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Better to use inheritance
- (void)showVisit:(Visit *)visit
{
    self.navigationItem.title = visit.pharmacy.name;
    self.nameLabel.text = visit.pharmacy.name;
    self.networkLabel.text = visit.pharmacy.network;
    self.phoneLabel.text = visit.pharmacy.phone;
    self.doctorLabel.text = visit.pharmacy.doctorName;
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@", visit.pharmacy.city, visit.pharmacy.street, visit.pharmacy.house];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    self.timeLabel.text = [timeFormatter stringFromDate:visit.date];
    [timeFormatter setDateFormat:@"dd.MM.yyyy"];
    self.dateLabel.text = [timeFormatter stringFromDate:visit.date];
    
    self.brandsButton.hidden = YES;
    self.participantsButton.hidden = YES;
    self.salesButton.hidden = NO;
    
    self.visit = visit;
    self.isConference = NO;
    
    [self setMapLocationForPharmacy:visit.pharmacy];
}

- (void)showConference:(Conference *)conference
{
    self.navigationItem.title = conference.pharmacy.name;
    self.nameLabel.text = conference.pharmacy.name;
    self.networkLabel.text = conference.pharmacy.network;
    self.phoneLabel.text = conference.pharmacy.phone;
    self.doctorLabel.text = conference.pharmacy.doctorName;
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@", conference.pharmacy.city, conference.pharmacy.street, conference.pharmacy.house];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    self.timeLabel.text = [timeFormatter stringFromDate:conference.date];
    [timeFormatter setDateFormat:@"dd.MM.yyyy"];
    self.dateLabel.text = [timeFormatter stringFromDate:conference.date];
    
    self.brandsButton.hidden = NO;
    self.participantsButton.hidden = NO;
    self.salesButton.hidden = YES;
    
    self.conference = conference;
    self.isConference = YES;
    
    [self setMapLocationForPharmacy:conference.pharmacy];
}

- (void)setMapLocationForPharmacy:(Pharmacy*)pharmacy
{
    self.mapView.showTraffic = NO;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [RaptureXMLResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
    NSString* address = [NSString stringWithFormat:@"г. %@ %@ %@", pharmacy.city, pharmacy.street, pharmacy.house];
    NSString* urlString = [[NSString stringWithFormat:@"http://geocode-maps.yandex.ru/1.x/?geocode=%@", address]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, NSArray* positionArray)
     {
         NSLog(@"JSON: %@", positionArray);
         if (positionArray.count == 0)
         {
             NSLog(@"Not found");
             return;
         }
         CLLocation* location = positionArray[0];
         
         [self.mapView setCenterCoordinate:location.coordinate atZoomLevel:15 animated:YES];
         MapAnnotation* annotation = [MapAnnotation new];
         annotation.coordinate = location.coordinate;
         annotation.title = address;
         annotation.subtitle = @"";
         [self.mapView removeAnnotations:self.mapView.annotations];
         [self.mapView addAnnotation:annotation];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

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
@end