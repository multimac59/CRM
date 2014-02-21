//
//  KeyboardView.h
//  CRM
//
//  Created by FirstMac on 14.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyboardView : UIView
@property (nonatomic, weak) IBOutlet UIButton* numberButton;
@property (nonatomic, weak) IBOutlet UIButton* pointButton;
@property (nonatomic, weak) IBOutlet UIButton* delButton;
@property (nonatomic, weak) IBOutlet UIButton* remainderButton;
@property (nonatomic, weak) IBOutlet UIButton* doneButton;
@property (nonatomic, strong) NSMutableArray* keyButtons;
@property (nonatomic) BOOL onlyRemainder;
@end
