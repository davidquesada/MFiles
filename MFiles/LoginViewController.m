//
//  LoginViewController.m
//  MFiles
//
//  Created by David Paul Quesada on 3/28/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()<UIWebViewDelegate>
{
    UIWebView *_webView;
    BOOL _didAuth;
    BOOL _hasLoadedRedirect;
}

-(void)dismiss:(id)sender;

@end

@implementation LoginViewController

-(id)init
{
    _webView = [[UIWebView alloc] init];
    UIViewController *root = [[UIViewController alloc] init];
    root.view = _webView;
    root.navigationItem.title = @"Login";
    root.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
    
    self = [self initWithRootViewController:root];
    if (self)
    {
        _webView.delegate = self;
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://mfile.umich.edu"]];
        [_webView loadRequest:req];
    }
    
    return self;
}

-(void)dismiss:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(loginViewController:didDismissWithLoginResult:)])
            [self.delegate loginViewController:self didDismissWithLoginResult:_didAuth];
    }];
}

#pragma mark - UIWebViewDelegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"ShouldStartLoad: %@", request.URL);
    
    if ([request.URL.description isEqualToString:@"https://mfile.umich.edu/"])
    {
        if (_hasLoadedRedirect)
        {
            _didAuth = YES;
            [self dismiss:nil];
            return YES;
        }
        _hasLoadedRedirect = YES;
    }
    
    return YES;
}

@end
