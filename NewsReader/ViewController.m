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
NSString * const TITLE_FOR_HEADER_INSECTION= @"Latest news";
NSString * const ARTICLE_IDENTIFIER = @"articleCell";

const NSInteger TITLE_NUMBER_OF_LINES = 2;
const NSInteger CONTENT_NUMBER_OF_LINES = 10;
const NSInteger NUMBER_OF_SECTIONS = 1;

@interface ViewController ()

@property (strong,nonatomic) NSMutableArray *newsRecords;
@property (assign,nonatomic) BOOL isTransfered;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
        article.content = [articleHeader objectForKey:@"content"];
        if ([article.content isEqual:[NSNull null]]) {
            NSString *contentDescription = [articleHeader objectForKey:@"description"];
            if (![contentDescription isEqual:[NSNull null]]) {
                article.content = contentDescription;
            }else{
                article.content = @"";
            }
        }
        article.contentDescription = [articleHeader objectForKey:@"description"];
        if ([article.contentDescription isEqual:[NSNull null]]) {
            article.contentDescription = @"";
        }
        article.url = [articleHeader objectForKey:@"url"];
        [self.newsRecords addObject:article];
    }
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMBER_OF_SECTIONS;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
   
    return TITLE_FOR_HEADER_INSECTION;
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
    cell.textLabel.numberOfLines = TITLE_NUMBER_OF_LINES ;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.text = articleForRow.title;
    cell.detailTextLabel.numberOfLines = CONTENT_NUMBER_OF_LINES;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.text = articleForRow.content;
    return cell;
}
#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    AKArticle *articleForRow = [self.newsRecords objectAtIndex:indexPath.row];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    AKArticleDetailsViewController *articleViewController = segue.destinationViewController;
    articleViewController.delegate = self;
    articleViewController.navigationItem.title = @"Article";
    articleViewController.articleURL = articleForRow.url;
    
//    let backButton = UIBarButtonItem()
//    backButton.title = "Cancel"
//    navigationItem.backBarButtonItem = backButton
//    let editTruckViewControoler = segue.destination as! AKTruckEditViewController
//    editTruckViewControoler.delegate = self
//    editTruckViewControoler.navigationItem.title = "Edit Truck Details"
//    editTruckViewControoler.truckDetails = self.truckDetails
}

@end
