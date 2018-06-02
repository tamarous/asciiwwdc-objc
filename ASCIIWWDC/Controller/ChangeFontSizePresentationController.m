//
//  ChangeFontSizePresentationController.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/6/2.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "ChangeFontSizePresentationController.h"

@interface ChangeFontSizePresentationController()
@property (nonatomic, strong) UIView *blackView;
@end

@implementation ChangeFontSizePresentationController
- (CGRect)frameOfPresentedViewInContainerView {
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    NSLog(@"height is %lf, width is %lf",height, width);
    return CGRectMake(0, height/2, width, height-height/2);
}

- (void)presentationTransitionWillBegin {
    self.blackView.alpha = 0;
    [self.containerView addSubview:self.blackView];
    [self.blackView addSubview:self.presentedViewController.view];
//    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
//        self.blackView.alpha = 1.0;
//    } completion:nil];
    [UIView animateWithDuration:0.5 animations:^{
        self.blackView.alpha = 1.0;
    }];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [self.blackView removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin {
//    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
//        self.blackView.alpha = 0;
//    } completion:nil];
    [UIView animateWithDuration:0.5 animations:^{
        self.blackView.alpha = 0;
    }];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [self.blackView removeFromSuperview];
    }
}

- (instancetype) initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    NSLog(@"presentedVC: %@",NSStringFromClass(presentedViewController.class));
    NSLog(@"presentingVC: %@",NSStringFromClass(presentingViewController.class));
    return self;
}



- (UIView *)blackView {
    if (! _blackView) {
        _blackView = [[UIView alloc] init];
        _blackView.frame = self.containerView.bounds;
        _blackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _blackView;
}

@end
