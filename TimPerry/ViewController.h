//
//  ViewController.h
//  TimPerry
//
//  Created by Tim Perry on 21/07/2015.
//  Copyright (c) 2015 Tim Perry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ViewController : UIViewController <WKNavigationDelegate, UINavigationBarDelegate, WKScriptMessageHandler> {
    WKWebView *appWebView;
    UIToolbar *appToolbar;
    UINavigationBar *appNavBar;
    WKScriptMessage *mostRecentScriptMessage;
}

-(void) gotoURL:(NSString *) url;
-(void) gotoStartPage;
-(void) setupNavigationBar;
-(void) setupWebView;
@end

