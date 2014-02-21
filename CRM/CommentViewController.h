//
//  CommentViewController.h
//  CRM
//
//  Created by FirstMac on 17.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sale.h"

@interface CommentViewController : UIViewController
@property (nonatomic, retain) Sale* sale;
@property (nonatomic, weak) IBOutlet UITextView* textView;
@end
