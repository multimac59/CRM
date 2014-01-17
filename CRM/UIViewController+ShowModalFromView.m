#import "UIViewController+ShowModalFromView.h"

@implementation UIViewController (ShowModalFromView)

- (void)presentModalViewController:(UIViewController *)modalViewController fromView:(UIView *)view
{
    modalViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    // Add the modal viewController but don't animate it. We will handle the animation manually
    [self presentViewController:modalViewController animated:NO completion:^{
    }];
    
    CGRect originalFrame = modalViewController.view.frame;
    modalViewController.view.frame = CGRectMake(1024, 0, 1024, 768);
    
//    [UIView animateWithDuration:1.0f
//                     animations:^{
//                         // Set the original frame back
//                         modalViewController.view.frame = originalFrame;
//                     }
//                     completion:^(BOOL finished) {
//                         
//                     }];
    
    /*
    // Remove the shadow. It causes weird artifacts while animating the view.
    CGColorRef originalShadowColor = modalViewController.view.superview.layer.shadowColor;
    modalViewController.view.superview.layer.shadowColor = [[UIColor clearColor] CGColor];
    
    // Save the original size of the viewController's view
    CGRect originalFrame = modalViewController.view.superview.frame;
    
    // Set the frame to the one of the view we want to animate from
    modalViewController.view.superview.frame = view.frame;

    // Begin animation
    [UIView animateWithDuration:1.0f
                     animations:^{
                         // Set the original frame back
                         modalViewController.view.superview.frame = originalFrame;
                     }
                     completion:^(BOOL finished) {
                         // Set the original shadow color back after the animation has finished
                         modalViewController.view.superview.layer.shadowColor = originalShadowColor;
                     }];*/
}

@end