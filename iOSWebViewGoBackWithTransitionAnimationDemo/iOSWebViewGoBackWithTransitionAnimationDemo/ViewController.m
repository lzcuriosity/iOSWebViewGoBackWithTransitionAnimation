//
//  ViewController.m
//  iOSWebViewGoBackWithTransitionAnimationDemo
//
//  Created by lz on 16/8/8.
//  Copyright © 2016年 lz. All rights reserved.
//

#import "ViewController.h"
#import "LZWebViewController.h"

@interface ViewController ()

- (IBAction)pushWebView:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushWebView:(id)sender {
    LZWebViewController *webVC = [[LZWebViewController alloc] init];
    webVC.url = @"http://www.baidu.com";
    [self.navigationController pushViewController:webVC animated:YES];
}
@end
