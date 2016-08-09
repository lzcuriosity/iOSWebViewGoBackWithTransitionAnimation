//
//  LZWebView.m
//  iOSWebViewGoBackWithTransitionAnimationDemo
//
//  Created by lz on 16/8/8.
//  Copyright © 2016年 lz. All rights reserved.
//

#import "LZWebView.h"

@interface LZWebView ()<UIWebViewDelegate>
{
    __weak id<UIWebViewDelegate> originDelegate;
    
    UIScreenEdgePanGestureRecognizer* popGesture;
    CGFloat panStartX;
    
    NSMutableArray *historyStack;
    UIImageView *historyView;
}

@end

@implementation LZWebView

//初始化
- (id)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    historyStack = [NSMutableArray array];
    popGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [popGesture setEdges:UIRectEdgeLeft];
    [self addGestureRecognizer:popGesture];
    [super setDelegate:self];
    [LZWebView addShadowToView:self];
}

- (void)dealloc {
    if (historyView) {
        [historyView removeFromSuperview];
        historyView = nil;
    }
}

- (void)setDelegate:(id<UIWebViewDelegate>)delegate {
    originDelegate = delegate;
}

- (id<UIWebViewDelegate>)delegate {
    return originDelegate;
}

- (void)setEnablePanGesture:(BOOL)enablePanGesture {
    popGesture.enabled = enablePanGesture;
}

- (BOOL)enablePanGesture {
    return popGesture.enabled;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self historyView].frame = self.bounds;
}

- (UIImageView *)historyView {
    if (!historyView) {
        if (self.superview) {
            historyView = [[UIImageView alloc] initWithFrame:self.bounds];
            [self.superview insertSubview:historyView belowSubview:self];
        }
    }
    return historyView;
}


#pragma mark - 复原
- (void)reSetWebViewAlpha {
    
    if (self.alpha == 1) {
        return;
    }else {
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 1;
        }];
        if ([historyStack count] > 0) {
            [historyStack removeObject:[historyStack lastObject]];
        }
    }
}

#pragma mark - 类功能
/**
 *  屏幕截图
 */
+ (UIImage *)screenshotOfView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, 0.0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 *  添加阴影效果
 */
+ (void)addShadowToView:(UIView *)view {
    CALayer *layer = view.layer;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:layer.bounds];
    layer.shadowPath = path.CGPath;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeZero;
    layer.shadowOpacity = 0.4f;
    layer.shadowRadius = 8.0f;
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL ret = YES;
    if (originDelegate && [originDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        ret = [originDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
    }
    
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    BOOL isHTTPOrFile = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"] || [request.URL.scheme isEqualToString:@"file"];
    
    if (ret && !isFragmentJump && isHTTPOrFile && isTopLevelNavigation) {
        if ((navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeOther) && [[webView.request.URL description] length]) {
            if (![[[historyStack lastObject] objectForKey:@"url"] isEqualToString:[self.request.URL description]]) {
                UIImage *curPreview = [LZWebView screenshotOfView:self];
                [historyStack addObject:@{@"preview":curPreview, @"url":[self.request.URL description]}];
            }
        }
    }
    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (originDelegate && [originDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [originDelegate webViewDidStartLoad:webView];
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self reSetWebViewAlpha];
    if (originDelegate && [originDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [originDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self reSetWebViewAlpha];
    if (originDelegate && [originDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [originDelegate webView:webView didFailLoadWithError:error];
    }
}

#pragma mark UIGestureDelegate
- (void)panGesture:(UIPanGestureRecognizer *)sender {
    if (![self canGoBack] || historyStack.count == 0) {
        if (self.lzPanWebViewDelegate && [self.lzPanWebViewDelegate respondsToSelector:@selector(LZWebView:panPopGesture:)]) {
            [self.lzPanWebViewDelegate LZWebView:self panPopGesture:sender];
        }
        return;
    }
    
    CGPoint translationPoint = [sender translationInView:self];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        panStartX = translationPoint.x;
    }else if (sender.state == UIGestureRecognizerStateChanged) {
        CGFloat deltaX = translationPoint.x - panStartX;
        if (deltaX > 0) {
            if ([self canGoBack]) {
                assert([historyStack count] > 0);
                
                CGRect rc = self.frame;
                rc.origin.x = deltaX;
                self.frame = rc;
                [self historyView].image = [[historyStack lastObject] objectForKey:@"preview"];
                rc.origin.x = -self.bounds.size.width/2.0f + deltaX/2.0f;
                [self historyView].frame = rc;
            }
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        CGFloat deltaX = translationPoint.x - panStartX;
        CGFloat duration = .5f;
        if ([self canGoBack]) {
            if (deltaX > self.bounds.size.width/4.0f) {
                [UIView animateWithDuration:(1.0f - deltaX/self.bounds.size.width)*duration animations:^{
                    CGRect rc = self.frame;
                    rc.origin.x = self.bounds.size.width;
                    self.frame = rc;
                    rc.origin.x = 0;
                    [self historyView].frame = rc;
                } completion:^(BOOL finished) {
                    [self goBack];
                    CGRect rc = self.frame;
                    rc.origin.x = 0;
                    self.frame = rc;
                    self.alpha = 0;
                }];
            } else {
                [UIView animateWithDuration:(deltaX/self.bounds.size.width)*duration animations:^{
                    CGRect rc = self.frame;
                    rc.origin.x = 0;
                    self.frame = rc;
                    rc.origin.x = -self.bounds.size.width/2.0f;
                    [self historyView].frame = rc;
                } completion:^(BOOL finished) {
                }];
            }
        }
    }
}


@end
