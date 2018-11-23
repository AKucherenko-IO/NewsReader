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

#pragma mark - Constants

//NSString * const NEWS_URL = @"https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey=78d11b972d4e44a6a8cb8f4be28ab907";
//NSString * const  NEWS_URL = @"https://newsapi.org/v2/top-headlines?country=ru&apiKey=78d11b972d4e44a6a8cb8f4be28ab907";
NSString * const  NEWS_URL = @"https://newsapi.org/v2/top-headlines?country=us&apiKey=78d11b972d4e44a6a8cb8f4be28ab907";
NSString * const NAVIGATION_TITLE= @"Breaking news";
NSString * const ARTICLE_IDENTIFIER = @"articleCell";
NSString * const DATE_FORMAT = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
NSString * const REFRESH_STRING = @"Updating News";
NSInteger const UPDATE_INTERVAL = 5*60 ;

const NSInteger NUMBER_OF_SECTIONS = 1;

@interface ViewController ()

@property (strong,nonatomic) NSMutableArray *newsRecords;
@property (strong,nonatomic) NSString *storedPublishedAtDate;
@property (assign,nonatomic) BOOL isStored;
@property (assign,nonatomic) BOOL toRefreshData;

@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATE_FORMAT];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshNews:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    self.navigationItem.title = NAVIGATION_TITLE;
    

    [self downloadNews];
    
    
    [NSTimer scheduledTimerWithTimeInterval:UPDATE_INTERVAL target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    
}

- (void)timerFireMethod:(NSTimer *)timer {
    
    [self downloadNews];
    NSLog(@"Timer executed");
}

#pragma mark - retrieveNews
- (void)downloadNews{

    NSLog(@"retrieveData");

    NSURL *url = [NSURL URLWithString:NEWS_URL];
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              if (data) {
                                                  NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                  if (!error) {
                                                      NSArray *recievedArticles = [jsonDictionary objectForKey:@"articles"];
                                                      weakSelf.isStored = FALSE;
                                                      [weakSelf updateArticlesData:recievedArticles];
                                                  }
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  if (weakSelf.toRefreshData) {
                                                  [weakSelf.tableView reloadData];
                                                  }
                                              });
                                              }
                                          }];
    
    [downloadTask resume];
    
}

- (void)updateArticlesData:(NSArray *)articlesArray{

    if (!self.isStored) {
        NSDictionary *latestArticle = [articlesArray objectAtIndex:0];
        NSString *latestArticleData = [latestArticle objectForKey:@"publishedAt"];
        self.toRefreshData = [self shouldRefreshTableView:latestArticleData];
        self.storedPublishedAtDate = latestArticleData;
        self.isStored = TRUE;
        self.newsRecords = [[NSMutableArray alloc] init];
    }
    
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

- (BOOL) shouldRefreshTableView:(NSString *) publishedAt {
    
//  NSString *publishedAt = @"2018-11-22T00:19:29Z";
    NSDateFormatter *publishedAtFormater = [[NSDateFormatter alloc] init];
    [publishedAtFormater setDateFormat:DATE_FORMAT];

    NSDate *publishedAtDate = [publishedAtFormater dateFromString:publishedAt];
    NSDate *storedPublishedAtDate = [publishedAtFormater dateFromString:self.storedPublishedAtDate];
    NSString *publishedAtDateString = [publishedAtFormater stringFromDate:publishedAtDate];
    NSString *storedPublishedAtDateString = [publishedAtFormater stringFromDate:storedPublishedAtDate];
    
    if (![storedPublishedAtDate isEqualToDate:publishedAtDate]) {
        NSLog(@"TRUE: %@ != %@",storedPublishedAtDateString,publishedAtDateString);
        return TRUE;
    } else {
        NSLog(@"FALSE: %@ = %@",storedPublishedAtDateString,publishedAtDateString);
        return FALSE;
    }

}

# pragma mark - Refresh

- (void) refreshNews:(UIRefreshControl *) refresh {
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:REFRESH_STRING];
    
    NSLog(@"Refreshing");
    
    [self downloadNews];
    
    [refresh endRefreshing];
    
}
#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return NUMBER_OF_SECTIONS;

}

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
