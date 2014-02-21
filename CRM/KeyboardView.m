//
//  KeyboardView.m
//  CRM
//
//  Created by FirstMac on 14.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "KeyboardView.h"

@implementation KeyboardView
@synthesize onlyRemainder = _onlyRemainder;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    self.onlyRemainder = NO;
    self.keyButtons = [NSMutableArray array];
    for (UIView* view in self.subviews)
    {
        if (view.tag < 10)
        {
            [self.keyButtons addObject:view];
        }
    }
}

- (BOOL)onlyRemainder
{
    return _onlyRemainder;
}

- (void)setOnlyRemainder:(BOOL)onlyRemainder
{
    _onlyRemainder = onlyRemainder;
    for (UIButton* key in self.keyButtons)
    {
        key.enabled = !self.onlyRemainder;
    }
    self.pointButton.enabled = !self.onlyRemainder;
    self.delButton.enabled = !self.onlyRemainder;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
@end
