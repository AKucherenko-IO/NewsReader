//
//  AKArticleDetailsViewController.m
//  NewsReader
//
//  Created by Andrei Kucherenko on 20/11/2018.
//  Copyright © 2018 AKA. All rights reserved.
//

#import "AKArticleDetailsViewController.h"

NSString * const PLACEHOLDER_IMAGE_NAME = @"no-photo";
@interface AKArticleDetailsViewController () 

@property (weak, nonatomic) IBOutlet UILabel *articleTitle;
@property (weak, nonatomic) IBOutlet UILabel *articleContent;
@property (strong, nonatomic) IBOutlet UIImageView *articleImage;

- (IBAction)readMoreAction:(id)sender;

@end

@implementation AKArticleDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.articleTitle.text = self.article.title;
    self.articleContent.text = self.article.content;
    UIImage *noPhotoPlaceHolder = [UIImage imageNamed:PLACEHOLDER_IMAGE_NAME];
    [self.articleImage setImage:noPhotoPlaceHolder];
    
    __weak typeof(self) weakSelf = self;
    NSURL *url = [NSURL URLWithString:self.article.urlToImage];
    NSURLSessionDownloadTask *downloadImageTask = [[NSURLSession sharedSession]
                                                   downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                       UIImage *downloadedArticleImage = [UIImage imageWithData:
                                                                                          [NSData dataWithContentsOfURL:location]];
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [weakSelf.articleImage setImage:downloadedArticleImage];
                                                       });
                                                   }];

    [downloadImageTask resume];
    
}

- (IBAction)readMoreAction:(id)sender {
    NSURL *url = [NSURL URLWithString:self.article.url];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}
@end
