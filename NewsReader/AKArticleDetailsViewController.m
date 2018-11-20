//
//  AKArticleDetailsViewController.m
//  NewsReader
//
//  Created by Andrei Kucherenko on 20/11/2018.
//  Copyright © 2018 AKA. All rights reserved.
//

#import "AKArticleDetailsViewController.h"

@interface AKArticleDetailsViewController () 

@property (strong, nonatomic) IBOutlet WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *articleContent;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation AKArticleDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.articleURL = @"https://www.google.com";
    self.articleURL = @"https://radiovesti.ru/news/1101884/";
    NSURL *url = [NSURL URLWithString:self.articleURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.webView.navigationDelegate = self;
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    [self.webView loadRequest:request];
    [self.articleContent addSubview:self.webView];
}
- (void) webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
 
    [self.indicator startAnimating];
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

    [self.indicator startAnimating];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.indicator stopAnimating];

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
