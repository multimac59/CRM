//
//  MFSideMenuCustomContainer.m
//  CRM
//
//  Created by FirstMac on 29.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "MFSideMenuCustomContainer.h"

@interface MFSideMenuCustomContainer ()

@end

@implementation MFSideMenuCustomContainer

- (void)setCenterViewController:(UIViewController *)centerViewController {
    [super setCenterViewController:centerViewController];
    //Добавил
    [((UIViewController *)self.centerViewController) view].frame = CGRectMake(0, 0, 1024, 768);
}

+ (MFSideMenuCustomContainer *)containerWithCenterViewController:(id)centerViewController
                                                  leftMenuViewController:(id)leftMenuViewController
                                                 rightMenuViewController:(id)rightMenuViewController {
    MFSideMenuCustomContainer *controller = [MFSideMenuCustomContainer new];
    controller.leftMenuViewController = leftMenuViewController;
    controller.centerViewController = centerViewController;
    controller.rightMenuViewController = rightMenuViewController;
    return controller;
}

@end
