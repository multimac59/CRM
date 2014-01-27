//
//  VisitsCell.m
//  CRM
//
//  Created by FirstMac on 15.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "VisitsCell.h"

@implementation VisitsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    if (!SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        self.contentView.backgroundColor = [UIColor yellowColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected)
    {
        self.triangleImage.hidden = NO;
    }
    else
    {
        self.triangleImage.hidden = YES;
    }
    // Configure the view for the selected state
}

@end