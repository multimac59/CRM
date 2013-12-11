//
//  NewBrandViewController.h
//  CRM
//
//  Created by FirstMac on 10.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NewBrandViewDelegate
- (void)addBrand:(NSString*)brand;
@end

@interface NewBrandViewController : UIViewController
@property (nonatomic, weak) IBOutlet UITextField* brandField;
@property (nonatomic, weak) id<NewBrandViewDelegate> delegate;
@end
