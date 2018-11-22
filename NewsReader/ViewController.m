//
//  ViewController.m
//  NewsReader
//
//  Created by Andrei Kucherenko on 17/11/2018.
//  Copyright © 2018 AKA. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
#import "AKArticle.h"
#import "AKArticleDetailsViewController.h"

NSString * const NEWS_URL = @"https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey=78d11b972d4e44a6a8cb8f4be28ab907";
//NSString * const  NEWS_URL = @"https://newsapi.org/v2/top-headlines?country=ru&apiKey=78d11b972d4e44a6a8cb8f4be28ab907";
NSString * const NAVIGATION_TITLE= @"Breaking news";
NSString * const ARTICLE_IDENTIFIER = @"articleCell";

const NSInteger NUMBER_OF_SECTIONS = 1;

@interface ViewController ()

@property (strong,nonatomic) NSMutableArray *newsRecords;
@property (assign,nonatomic) BOOL isTransfered;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NAVIGATION_TITLE;
    if (!self.isTransfered) {
        self.newsRecords = [[NSMutableArray alloc] init];
        [self retrieveNews];
    }
    
}

#pragma mark - retrieveNews
- (void)retrieveNews{
    NSLog(@"retrieveData");

    NSURL *url = [NSURL URLWithString:NEWS_URL];

    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              if (data) {
                                                  NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                  if (!error) {
                                                      NSArray *recievedArticles = [jsonDictionary objectForKey:@"articles"];
                                                      [weakSelf updateArticlesData:recievedArticles];
                                                  }
                                              weakSelf.isTransfered = TRUE;
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [weakSelf.tableView reloadData];
                                              });
                                              }
                                          }];
    
    [downloadTask resume];
    
}

- (void)updateArticlesData:(NSArray *)articlesArray{
    for (NSDictionary *articleHeader in articlesArray) {
        
        AKArticle *article = [[AKArticle alloc] init];
        article.title = [articleHeader objectForKey:@"title"];
        article.url = [articleHeader objectForKey:@"url"];
        article.urlToImage = [articleHeader objectForKey:@"urlToImage"];
        article.publishedAt = [articleHeader objectForKey:@"publishedAt"];
        article.contentDescription = [articleHeader objectForKey:@"description"];
        article.content = [articleHeader objectForKey:@"content"];

        if ([article.contentDescription isEqual:[NSNull null]]) {
            if (![article.content isEqual:[NSNull null]]) {
                article.contentDescription = article.content;
            }else{
                article.contentDescription = @"";
                article.content = @"";
            }
        }else if ([article.content isEqual:[NSNull null]]){
            article.content = @"";
        }
        
        [self.newsRecords addObject:article];
    }
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return NUMBER_OF_SECTIONS;
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//   
//    return TITLE_FOR_HEADER_INSECTION;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.newsRecords count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ARTICLE_IDENTIFIER];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ARTICLE_IDENTIFIER];
    }
    AKArticle *articleForRow = [self.newsRecords objectAtIndex:indexPath.row];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.text = articleForRow.title;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.text = articleForRow.contentDescription;
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    AKArticle *articleForRow = [self.newsRecords objectAtIndex:indexPath.row];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    self.navigationItem.backBarButtonItem.tintColor = [UIColor lightGrayColor];
    AKArticleDetailsViewController *articleViewController = segue.destinationViewController;
    articleViewController.delegate = self;
    articleViewController.article = articleForRow;

}

@end
