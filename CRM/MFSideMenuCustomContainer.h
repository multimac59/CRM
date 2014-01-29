//
//  MFSideMenuCustomContainer.h
//  CRM
//
//  Created by FirstMac on 29.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "MFSideMenuContainerViewController.h"

@interface MFSideMenuCustomContainer : MFSideMenuContainerViewController
+ (MFSideMenuCustomContainer *)containerWithCenterViewController:(id)centerViewController
                                          leftMenuViewController:(id)leftMenuViewController
                                         rightMenuViewController:(id)rightMenuViewController;
@end
