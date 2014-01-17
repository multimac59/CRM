//
//  TopicSideCell.m
//  CRM
//
//  Created by FirstMac on 17.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "TopicSideCell.h"

@implementation TopicSideCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (!selected)
    {
        if (self.tag == 0)
        {
            self.sideImage.backgroundColor = [UIColor colorWithRed:230/255.0 green:204/255.0 blue:220/255.0 alpha:1.0];
        }
        else
        {
            self.sideImage.backgroundColor = [UIColor colorWithRed:241/255.0 green:227/255.0 blue:192/255.0 alpha:1.0];
        }
    }
    else
    {
        if (self.tag == 0)
        {
            self.sideImage.backgroundColor = [UIColor colorWithRed:156/255.0 green:51/255.0 blue:116/255.0 alpha:1.0];
        }
        else
        {
            self.sideImage.backgroundColor = [UIColor colorWithRed:239/255.0 green:171/255.0 blue:0/255.0 alpha:1.0];
        }
        
    }
}

@end
