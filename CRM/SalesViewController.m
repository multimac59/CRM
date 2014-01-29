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
@property (nonatomic) BOOL isMyVisit;
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
//    if ([self respondsToSelector:@selector(extendedLayoutIncludesOpaqueBars)])
//    {
//       [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBarBg"] forBarMetrics:UIBarMetricsDefault];
//    }
//    else
//    {
//        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBarBg"] forBarMetrics:UIBarMetricsDefault];
//        self.navigationController.navigationBar.translucent = NO;
//        self.wantsFullScreenLayout = YES;
//    }
    //self.navigationController.navigationBar.translucent = NO;
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBarBg"] forBarMetrics:UIBarMetricsDefault];
    //self.navigationController.navigationBar.clipsToBounds = YES;
    self.navigationController.navigationBar.shadowImage =[[UIImage alloc] init];
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 1024, 1)];
    [overlayView setBackgroundColor:[UIColor colorWithRed:75/255.0 green:48/255.0 blue:106/255.0 alpha:1.0]];
    [self.navigationController.navigationBar addSubview:overlayView]; // navBar is your UINavigationBar instance
    self.title = @"Аптека";
//    [self.navigationController.navigationBar setTitleTextAttributes:@{
//                                                           UITextAttributeTextColor: [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
//                                                           UITextAttributeTextShadowColor: [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
//                                                           UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
//                                                           UITextAttributeFont: [UIFont fontWithName:@"Arial-BoldMT" size:17.0],
//                                                           }];
    self.navigationController.navigationBar.translucent = NO;
    UIButton* leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 63, 20)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"backButtonPressed"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"backButton"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchDown];
    
    UIButton* rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 82, 20)];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"saveButtonPressed"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"saveButton"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(saveVisit:) forControlEvents:UIControlEventTouchDown];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    
    self.isMyVisit = YES;
    // Do any additional setup after loading the view from its nib.
    User* currentUser = [AppDelegate sharedDelegate].currentUser;
    NSSortDescriptor* sortByNameDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
    _drugs = [currentUser.drugs.allObjects sortedArrayUsingDescriptors:@[sortByNameDescriptor]];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableBg"]];
    [tempImageView setFrame:self.table.frame];
    //self.table.backgroundView = tempImageView;
    //self.table.tableHeaderView = [[[NSBundle mainBundle]loadNibNamed:@"SaleHeader" owner:self options:nil]firstObject];
    self.table.alwaysBounceVertical = NO;
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
    if (indexPath.row % 2 == 0)
    {
        cell.cellBg.image = [UIImage imageNamed:@"evenCell"];
    }
    return cell;
    Drug* drug = self.drugs[indexPath.row];
    //NSLog(@"drug name = %@", drug.name);
    Sale* lastSale;
    if (self.isMyVisit)
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
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.35;
//    transition.timingFunction =
//    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = kCATransitionReveal;
//    transition.subtype = kCATransitionFromTop;
//    UIView *containerView = self.view.window;
//    [containerView.layer addAnimation:transition forKey:nil];
//    
//    [self dismissViewControllerAnimated:NO completion:nil];
    
    int y;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        y = - 20;
    }
    else
    {
        y = 0;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.view.frame = CGRectMake(1024, y, 1024, 768);
    }completion:^(BOOL finished) {
        [self.navigationController.view removeFromSuperview];
    }];
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


//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return [[[NSBundle mainBundle]loadNibNamed:@"SaleHeader" owner:self options:nil]firstObject];
//}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    
    return view;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
        NSLog(@"Little");
           }
}

- (IBAction)lastVisitButtonPressed:(id)sender
{
    if (self.isMyVisit)
    {
        [self.lastVisitButton setBackgroundImage:[UIImage imageNamed:@"leftSegmentPressed"] forState:UIControlStateNormal];
        [self.myLastVisitButton setBackgroundImage:[UIImage imageNamed:@"rightSegment"] forState:UIControlStateNormal];
        [self.lastVisitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.myLastVisitButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        self.isMyVisit = NO;
    }
}

- (IBAction)myLastVisitButtonPressed:(id)sender
{
    if (!self.isMyVisit)
    {
        [self.myLastVisitButton setBackgroundImage:[UIImage imageNamed:@"rightSegmentPressed"] forState:UIControlStateNormal];
        [self.lastVisitButton setBackgroundImage:[UIImage imageNamed:@"leftSegment"] forState:UIControlStateNormal];
        [self.myLastVisitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.lastVisitButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        self.isMyVisit = YES;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}
@end