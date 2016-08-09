//
//  LZWebViewController.m
//  iOSWebViewGoBackWithTransitionAnimationDemo
//
//  Created by lz on 16/8/8.
//  Copyright © 2016年 lz. All rights reserved.
//

#import "LZWebViewController.h"
#import "LZWebView.h"
@interface LZWebViewController () <LZPanWebViewDelegate>

@end

@implementation LZWebViewController {
    id navPanTarget;
    SEL navPanAction;
    IMP imp;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    // 获取系统默认手势Handler并创建与之相同的手势
    NSMutableArray *gestureTargets = [self.navigationController.interactivePopGestureRecognizer valueForKey:@"targets"];
    id gestureTarget = [gestureTargets firstObject];
    navPanTarget = [gestureTarget valueForKey:@"target"];
    navPanAction = NSSelectorFromString(@"handleNavigationTransition:");
    if (navPanTarget && [navPanTarget respondsToSelector:navPanAction]) {
        imp =[navPanTarget methodForSelector:navPanAction];
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    LZWebView *webView = [[LZWebView alloc] initWithFrame:CGRectMake(0, 0, width,height)];
    webView.lzPanWebViewDelegate = self;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    [self.view addSubview:webView];
}

- (void)viewWillAppear:(BOOL)animated {
    //禁用iOS系统自带的navigation右滑返回
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void) viewDidDisappear:(BOOL)animated {
    //启用iOS系统自带的navigation右滑返回
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)LZWebView:(LZWebView *)webView panPopGesture:(UIPanGestureRecognizer *)pan {
    if (imp) {
        void (*func)(id, SEL, UIPanGestureRecognizer*) = (void *)imp;
        func(navPanTarget, navPanAction,pan);
    }
}

@end
