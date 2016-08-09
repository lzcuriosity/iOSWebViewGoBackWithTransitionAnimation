//
//  LZWebView.h
//  iOSWebViewGoBackWithTransitionAnimationDemo
//
//  Created by lz on 16/8/8.
//  Copyright © 2016年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LZWebView;

@protocol LZPanWebViewDelegate <NSObject>

- (void)LZWebView:(LZWebView *)webView panPopGesture:(UIPanGestureRecognizer *)pan;

@end


@interface LZWebView : UIWebView

@property (nonatomic,weak) id<LZPanWebViewDelegate> lzPanWebViewDelegate;
@property (nonatomic,assign) BOOL enablePanGesture;

@end
