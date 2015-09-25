//
//  ViewController.m
//  TimPerry
//
//  Created by Tim Perry on 21/07/2015.
//  Copyright (c) 2015 Tim Perry. All rights reserved.
//

#import "ViewController.h"
#define START_URL @"http://localhost:8080/"
#define TOOLBAR_HEIGHT 44
#define NAVBAR_HEIGHT 44

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [self setupWebView];
    [self setupToolbar];
}

-(void) setupNavigationBar {
    CGSize size = self.view.frame.size;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    appNavBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, statusBarHeight, size.width, NAVBAR_HEIGHT)];
    [appNavBar setBarStyle:UIBarStyleBlack];
    [appNavBar pushNavigationItem:[[UINavigationItem alloc] initWithTitle:@"Main Menu"] animated:NO];
    [appNavBar setDelegate: self];
    
    [[self view] addSubview: appNavBar];
}

-(void) setupToolbar {
    appToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-TOOLBAR_HEIGHT, self.view.frame.size.width, TOOLBAR_HEIGHT)];
    [appToolbar setItems:[NSArray arrayWithObject:[[UIBarButtonItem alloc]initWithTitle:@"Main Menu" style:UIBarButtonItemStylePlain target: self action: @selector(gotoStartPage)]]];
    
    [[self view] addSubview:appToolbar];
}

-(void) setupWebView {
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    
    WKUserContentController *controller = [[WKUserContentController alloc] init];
    [controller addScriptMessageHandler:self name:@"topRightNav"];
    configuration.userContentController = controller;
    
    appWebView = [[WKWebView alloc] initWithFrame: CGRectMake(0, appNavBar.frame.origin.y+appNavBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-TOOLBAR_HEIGHT-NAVBAR_HEIGHT) configuration:configuration];
    [appWebView setNavigationDelegate:self];
    
    [self.view addSubview:appWebView];
    
    [self gotoURL:START_URL];
}

-(void) webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    mostRecentScriptMessage = nil;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: webView.title];
    
    if(mostRecentScriptMessage) {
        navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:mostRecentScriptMessage.body style:UIBarButtonItemStylePlain target:self action: @selector(runJavascript:)];
    }
    
    if([[webView.URL absoluteString] isEqualToString:START_URL]) {
        [appNavBar setItems:[NSArray arrayWithObject:navItem]];
    } else {
        [appNavBar pushNavigationItem:navItem animated: NO];
    }
}

-(void) runJavascript:(id) sender {
    UINavigationItem *navItem = (UINavigationItem *) sender;
    NSString *javascript = [NSString stringWithFormat:@"window.handleAction('%@');", [[[navItem title] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
    [appWebView evaluateJavaScript: javascript completionHandler: ^(NSString *result, NSError *error)
     {
         NSLog(@"Error %@",error);
         NSLog(@"Result %@",result);
     }];
}

- (void)navigationBar:(UINavigationBar *)navigationBar
           didPopItem:(UINavigationItem *)item {
    [appWebView loadRequest:[NSURLRequest requestWithURL:[[[appWebView backForwardList] backItem] URL]]];
}

-(void) userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    // TOOD: handle route changes from SPA apps.
    mostRecentScriptMessage = message;
}

-(void) gotoURL:(NSString *) url {
    [appWebView loadRequest: [NSURLRequest requestWithURL:[NSURL URLWithString: url]]];
}

-(void) gotoStartPage {
    [self gotoURL: START_URL];
}

@end