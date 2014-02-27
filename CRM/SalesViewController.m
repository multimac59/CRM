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
#import "Dose.h"
#import "User.h"
#import "KeyboardView.h"
#import "CommentViewController.h"
#import "ModalNavigationController.h"
#import "CommerceVisit.h"
#import "AppDelegate.h"

@interface SalesViewController ()
@property (nonatomic, strong) NSArray* drugs;
@property (nonatomic) BOOL isMyVisit;
@property (nonatomic, strong) NSMutableArray* bools;
@property (nonatomic, strong) KeyboardView* keyboard;
@property (nonatomic, strong) UITextField* activeField;
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

    NSLog(@"TOTAL : %d sales ", self.commerceVisit.sales.count);
    for (Sale* sale in self.commerceVisit.sales)
    {
        NSLog(@"dose = %@, order = %@, sold = %@, remainder = %@",sale.dose.name, sale.order, sale.sold, sale.remainder);
    }
    
    self.keyboard = [[NSBundle mainBundle]loadNibNamed:@"KeyboardView" owner:self options:nil][0];

    self.navigationController.navigationBar.shadowImage =[[UIImage alloc] init];
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 1024, 1)];
    [overlayView setBackgroundColor:[UIColor colorWithRed:75/255.0 green:48/255.0 blue:106/255.0 alpha:1.0]];
    [self.navigationController.navigationBar addSubview:overlayView]; // navBar is your UINavigationBar instance
    self.title = @"Аптека";

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
    
    self.isMyVisit = NO;
    NSSortDescriptor* sortByNameDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
    _drugs = [[AppDelegate sharedDelegate].drugs sortedArrayUsingDescriptors:@[sortByNameDescriptor]];
    if (self.commerceVisit.sales.count == 0)
        [self createSales];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableBg"]];
    [tempImageView setFrame:self.table.frame];
    self.table.alwaysBounceVertical = NO;
    
    self.bools = [[NSMutableArray alloc]init];
    for (int i = 0; i < self.drugs.count; i++)
    {
        NSNumber* state = @NO;
        [self.bools addObject:state];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.drugs.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"Table will contain %lu drugs", (unsigned long)self.drugs.count);
    NSNumber* state = self.bools[section];
    if (!state.boolValue)
        return 1;
    else
    {
        Drug* drug = self.drugs[section];
        return drug.doses.count;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SaleCell* cell = [tableView dequeueReusableCellWithIdentifier:@"sale"];
    if (cell == nil)
    {
        cell = [[NSBundle mainBundle]loadNibNamed:@"SaleCell" owner:self options:nil][0];
    }
    Drug* drug = self.drugs[indexPath.section];
    
    NSArray* doses = [drug.doses.allObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES]]];
    Dose* dose = doses[indexPath.row];

    Sale* lastSale;
    lastSale = [self getLastSaleFor:dose mySale:NO];
    Sale* currentSale = [self getCurrentSaleFor:dose];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd.MM.yyyy HH:mm";
    cell.drugLabel.text = dose.name;
    if (lastSale != nil)
    {
        cell.dateLabel.text = [dateFormatter stringFromDate:lastSale.commerceVisit.visit.date];
        cell.nameLabel.text = lastSale.commerceVisit.visit.user.name;
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

    if (currentSale.order.integerValue == -1)
        cell.orderField.text = @"Ост.";
    else
        cell.orderField.text = [NSString stringWithFormat:@"%@", currentSale.order];
    
    if (currentSale.sold.integerValue == -1)
        cell.soldField.text = @"Ост.";
    else
        cell.soldField.text = [NSString stringWithFormat:@"%@", currentSale.sold];
    
    if (currentSale.remainder.integerValue == -1)
        cell.remainderField.text = @"Ост.";
    else
        cell.remainderField.text = [NSString stringWithFormat:@"%@", currentSale.remainder];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0)
    {
        //cell.contentView.backgroundColor = [UIColor colorWithRed:252/255.0 green:236/255.0 blue:199/255.0 alpha:1.0];
        cell.cellBg.image = [UIImage imageNamed:@"groupCellBg"];
        cell.arrowView.hidden = NO;
        
        NSNumber* state = self.bools[indexPath.section];
        if (state.boolValue)
        {
            cell.arrowView.image = [UIImage imageNamed:@"arrowClosed"];
        }
        else
        {
            cell.arrowView.image = [UIImage imageNamed:@"arrowOpened"];
        }
    }
    else
    {
        //cell.contentView.backgroundColor = [UIColor colorWithRed:249/255.0 green:248/255.0 blue:247/255.0 alpha:1.0];
        cell.cellBg.image = [UIImage imageNamed:@"singleCellBg"];
        cell.arrowView.hidden = YES;
    }
    
    if (self.commerceVisit.visit.closed.boolValue)
    {
        cell.orderField.enabled = NO;
        cell.soldField.enabled = NO;
        cell.remainderField.enabled = NO;
    }
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveVisit:(id)sender
{
    self.commerceVisit.visit.closed = @YES;
    [self back];
}

- (void)back
{
    NSLog(@"TOTAL : %d sales ", self.commerceVisit.sales.count);
    
    for (Sale* sale in self.commerceVisit.sales)
    {
        NSLog(@"dose = %@, order = %@, sold = %@, remainder = %@",sale.dose.name, sale.order, sale.sold, sale.remainder);
    }
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

- (Sale*)getCurrentSaleFor:(Dose*)dose
{
    //Or use predicate instead
    for (Sale* currentSale in self.commerceVisit.sales)
    {
        if (currentSale.dose.doseId == dose.doseId)
            return currentSale;
    }
    assert("YOU SUCK");
    return nil;
}

- (Sale*)getLastSaleFor:(Dose*)dose mySale:(BOOL)isMine
{
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Sale" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(commerceVisit.visit.pharmacy=%@) && (commerceVisit.visit.date<%@) && (dose.doseId=%@)", self.commerceVisit.visit.pharmacy, self.commerceVisit.visit.date, dose.doseId];
    NSSortDescriptor* sortByDateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"commerceVisit.visit.date" ascending:YES];
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

- (void)createSales
{
    User* currentUser = [AppDelegate sharedDelegate].currentUser;
    for (Drug* drug in self.drugs)
    {
        for (Dose* dose in drug.doses)
        {
            Sale* sale = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Sale"
                        inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
            sale.dose = dose;
            sale.commerceVisit = self.commerceVisit;
            sale.commerceVisit.visit.user = currentUser;
            sale.sold = @0;
            sale.remainder = @0;
            sale.order = @0;
        }
    }
}


//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return [UIView new];
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] init];
//    
//    return view;
//}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (scrollView.contentOffset.y < 0) {
//        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
//        NSLog(@"Little");
//           }
//}

/*
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
}*/

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 59;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0)
        return;
    [self dismissKeyboard];
    NSNumber* state = self.bools[indexPath.section];
    self.bools[indexPath.section] = @(!state.boolValue);
    [self.table reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self saveInput];
    self.activeField = textField;
    CGRect senderRect = [textField.superview convertRect:textField.frame toView:self.view];
    [self.view addSubview:self.keyboard];
    CGRect frame = self.keyboard.frame;
    frame.origin = CGPointMake(senderRect.origin.x - frame.size.width + senderRect.size.width/2, senderRect.origin.y + senderRect.size.height);
    self.keyboard.frame = frame;
    if ([self.activeField.text isEqualToString:@"Ост."])
    {
        self.keyboard.onlyRemainder = YES;
    }
    else
    {
        self.keyboard.onlyRemainder = NO;
    }
    
}

- (IBAction)keyPressed:(id)sender
{
    UIButton* key = (UIButton*)sender;
    if ([self.keyboard.keyButtons containsObject:key])
    {
        if ([self.activeField.text isEqualToString:@"0"])
            self.activeField.text = @"";
        self.activeField.text = [self.activeField.text stringByAppendingString:[NSString stringWithFormat:@"%d", key.tag]];
    }
    else if (key == self.keyboard.pointButton)
    {
        if (self.activeField.text.length > 0 && [self.activeField.text rangeOfString:@","].location == NSNotFound)
             self.activeField.text = [self.activeField.text stringByAppendingString:@","];
    }
    else if (key == self.keyboard.delButton)
    {
        if (self.activeField.text.length > 0)
            self.activeField.text = [self.activeField.text substringToIndex:[self.activeField.text length]-1];
    }
    else if (key == self.keyboard.remainderButton)
    {
        self.keyboard.onlyRemainder = !self.keyboard.onlyRemainder;
        if (self.keyboard.onlyRemainder)
            self.activeField.text = @"Ост.";
        else
            self.activeField.text = @"";
    }
    else if (key == self.keyboard.doneButton)
    {
        [self saveInput];
        [self dismissKeyboard];
    }
}

- (void)saveInput
{
    if (!self.activeField)
        return;
    SaleCell* cell = (SaleCell*)self.activeField.superview.superview.superview;
    NSIndexPath* indexPath = [self.table indexPathForCell:cell];
    Drug* drug = self.drugs[indexPath.section];
    NSArray* doses = [drug.doses.allObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES]]];
    Dose* dose = doses[indexPath.row];
    Sale* sale = [self getCurrentSaleFor:dose];
    
    if (self.activeField == cell.remainderField)
    {
        if ([self.activeField.text isEqualToString:@"Ост."])
            sale.remainder = @-1;
        else
            sale.remainder = @(self.activeField.text.floatValue);
    }
    else if (self.activeField == cell.soldField)
    {
        if ([self.activeField.text isEqualToString:@"Ост."])
            sale.sold = @-1;
        else
            sale.sold = @(self.activeField.text.floatValue);
    }
    else if (self.activeField == cell.orderField)
    {
        if ([self.activeField.text isEqualToString:@"Ост."])
            sale.order = @-1;
        else
            sale.order = @(self.activeField.text.floatValue);
    }
    [[AppDelegate sharedDelegate] saveContext];
}

- (void)dismissKeyboard
{
    [self.activeField resignFirstResponder];
    self.activeField = nil;
    [self.keyboard removeFromSuperview];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect senderRect = [self.activeField.superview convertRect:self.activeField.frame toView:self.view];
    CGRect frame = self.keyboard.frame;
    frame.origin = CGPointMake(senderRect.origin.x - frame.size.width + senderRect.size.width/2, senderRect.origin.y + senderRect.size.height);
    self.keyboard.frame = frame;
}

- (void)showComment:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.table];
    NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:buttonPosition];
    
    Drug* drug = self.drugs[indexPath.section];
    NSArray* doses = [drug.doses.allObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES]]];
    Dose* dose = doses[indexPath.row];
    Sale* sale = [self getCurrentSaleFor:dose];
    
    CommentViewController* commentViewController = [CommentViewController new];
    commentViewController.sale = sale;
    ModalNavigationController* commentParentController = [[ModalNavigationController alloc]initWithRootViewController:commentViewController];
    commentParentController.modalPresentationStyle = UIModalPresentationPageSheet;
    commentParentController.modalWidth = 800;
    commentParentController.modalHeight = 700;
    [self presentViewController:commentParentController animated:YES completion:nil];
}
@end