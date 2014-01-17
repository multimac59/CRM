#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface UIViewController (ShowModalFromView)

- (void)presentModalViewController:(UIViewController *)modalViewController fromView:(UIView *)view;

@end