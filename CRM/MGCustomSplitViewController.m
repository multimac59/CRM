//
//  MGCustomSplitViewController.m
//  CRM
//
//  Created by FirstMac on 29.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "MGCustomSplitViewController.h"

@interface MGCustomSplitViewController ()

@end

@implementation MGCustomSplitViewController
- (CGSize)splitViewSizeForOrientation:(UIInterfaceOrientation)theOrientation
{
	UIScreen *screen = [UIScreen mainScreen];
	CGRect fullScreenRect = screen.bounds; // always implicitly in Portrait orientation.
	
	// Initially assume portrait orientation.
	float width = fullScreenRect.size.width;
	float height = fullScreenRect.size.height;
	
	// Correct for orientation.
	if (UIInterfaceOrientationIsLandscape(theOrientation)) {
		width = height;
		height = fullScreenRect.size.width;
	}
	
	return CGSizeMake(width, height);
}
@end
