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
@property (nonatomic, strong) NSMutableArray* sectionStates;
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
    
    [Flurry logEvent:@"Переход" withParameters:@{@"Экран":@"Продажи", @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadTable:) name:@"UpdateComments" object:nil];
    
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
    [rightButton setBackgroundImage:[UIImage imageNamed:@"sendButtonBg"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"sendButtonPressedBg"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(saveVisit:) forControlEvents:UIControlEventTouchDown];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    if (!self.commerceVisit.visit.closed.boolValue)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableBg"]];
    [tempImageView setFrame:self.table.frame];
    self.table.alwaysBounceVertical = NO;
    
    [self loadDrugs];
    
    self.sectionStates = [[NSMutableArray alloc]init];
    for (int i = 0; i < self.drugs.count; i++)
    {
        NSNumber* state = @NO;
        [self.sectionStates addObject:state];
    }
}

- (void)loadDrugs
{
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Drug" inManagedObjectContext:context]];
    request.sortDescriptors = @[[[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES]];
    self.drugs = [[context executeFetchRequest:request error:nil]mutableCopy];
}

#pragma mark table methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.drugs.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSNumber* sectionOpened = self.sectionStates[section];
    if (sectionOpened.boolValue)
    {
        Drug* drug = self.drugs[section];
        return drug.doses.count;
    }
    else
        return 1;
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
    
    [cell setupCellWithLastSale:lastSale andCurrentSale:currentSale forDose:dose];
    
    [cell setCellEnabled:!self.commerceVisit.visit.closed.boolValue];
    
    if (indexPath.row == 0)
    {
        cell.cellBg.image = self.commerceVisit.visit.closed.boolValue ? [UIImage imageNamed:@"groupCellInactive"] : [UIImage imageNamed:@"groupCellActive"];
        cell.arrowView.hidden = NO;
        
        NSNumber* state = self.sectionStates[indexPath.section];
        if (state.boolValue)
            cell.arrowView.image = [UIImage imageNamed:@"arrowClosed"];
        else
            cell.arrowView.image = [UIImage imageNamed:@"arrowOpened"];
    }
    else
    {
        cell.cellBg.image = self.commerceVisit.visit.closed.boolValue ? [UIImage imageNamed:@"singleCellInactive"] : [UIImage imageNamed:@"singleCellActive"];
        cell.arrowView.hidden = YES;
    }
    cell.commentButton.enabled = !self.commerceVisit.visit.closed.boolValue;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveVisit:(id)sender
{
    self.commerceVisit.visit.closed = @YES;
    [self back];
}

- (void)back
{
    int y;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
        y = - 20;
    else
        y = 0;

    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.view.frame = CGRectMake(1024, y, 1024, 768);
    }completion:^(BOOL finished) {
        [self.navigationController.view removeFromSuperview];
        //[[AppDelegate sharedDelegate]reloadData];
    }];
}

- (Sale*)getCurrentSaleFor:(Dose*)dose
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"dose=%@", dose];
    NSSet* sales = [self.commerceVisit.sales filteredSetUsingPredicate:predicate];
    if (sales.count > 0)
        return [sales anyObject];
    else
        return nil;
}

- (Sale*)getLastSaleFor:(Dose*)dose mySale:(BOOL)isMine
{
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Sale" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(commerceVisit.visit.pharmacy=%@) && (commerceVisit.visit.date<%@) && (dose=%@)", self.commerceVisit.visit.pharmacy, self.commerceVisit.visit.date, dose];
    NSSortDescriptor* sortByDateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"commerceVisit.visit.date" ascending:YES];
    request.predicate = predicate;
    request.sortDescriptors = @[sortByDateDescriptor];
    request.fetchLimit = 1;
    NSError *error = nil;
    NSArray* sales = [[context executeFetchRequest:request error:&error]mutableCopy];
    return sales.count>0 ? sales[0] : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 59;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //"Section" clicked
    if (indexPath.row == 0)
    {
        [self dismissKeyboard];
        NSNumber* state = self.sectionStates[indexPath.section];
        self.sectionStates[indexPath.section] = @(!state.boolValue);
        [self.table reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //Empty input is 0
    if ([self.activeField.text isEqualToString:@""])
        self.activeField.text = @"0";
    
    [self saveInput];
    
    //Reposition keyboard
    self.activeField = textField;
    CGRect senderRect = [textField.superview convertRect:textField.frame toView:self.view];
    [self.view addSubview:self.keyboard];
    CGRect frame = self.keyboard.frame;
    frame.origin = CGPointMake(senderRect.origin.x - frame.size.width + senderRect.size.width/2, senderRect.origin.y + senderRect.size.height);
    self.keyboard.frame = frame;
    
    //Setup keyboard
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
        if ([self.activeField.text isEqualToString:@"Ост."])
        {
            self.activeField.text = @"";
            self.keyboard.onlyRemainder = !self.keyboard.onlyRemainder;
        }
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

- (Sale*)createNewSaleForDose:(Dose*)dose
{
    Sale* sale = [NSEntityDescription
            insertNewObjectForEntityForName:@"Sale"
            inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
    sale.dose = dose;
    sale.commerceVisit = self.commerceVisit;
    sale.commerceVisit.visit.user = [AppDelegate sharedDelegate].currentUser;
    sale.sold = @0;
    sale.remainder = @0;
    sale.order = @0;
    [self.commerceVisit addSalesObject:sale];
    [[AppDelegate sharedDelegate]saveContext];
    return sale;
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
    
    if (!sale)
    {
        sale = [self createNewSaleForDose:dose];
    }
    
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

//Keyboard should follow scrolling table
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect senderRect = [self.activeField.superview convertRect:self.activeField.frame toView:self.view];
    CGRect frame = self.keyboard.frame;
    frame.origin = CGPointMake(senderRect.origin.x - frame.size.width + senderRect.size.width/2, senderRect.origin.y + senderRect.size.height);
    self.keyboard.frame = frame;
}

- (void)showComment:(id)sender
{
    //Find cell
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.table];
    NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:buttonPosition];
    
    //Find dose by cell
    Drug* drug = self.drugs[indexPath.section];
    NSArray* doses = [drug.doses.allObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES]]];
    Dose* dose = doses[indexPath.row];
    
    //Find or create dose for cell
    Sale* sale = [self getCurrentSaleFor:dose];
    if (!sale)
    {
        sale = [self createNewSaleForDose:dose];
    }
    
    //Show comment controller
    CommentViewController* commentViewController = [CommentViewController new];
    commentViewController.sale = sale;
    ModalNavigationController* commentParentController = [[ModalNavigationController alloc]initWithRootViewController:commentViewController];
    commentParentController.modalPresentationStyle = UIModalPresentationPageSheet;
    commentParentController.modalWidth = 800;
    commentParentController.modalHeight = 700;
    [self presentViewController:commentParentController animated:YES completion:nil];
}

- (void)reloadTable:(id)sender
{
    [self.table reloadData];
}
@end