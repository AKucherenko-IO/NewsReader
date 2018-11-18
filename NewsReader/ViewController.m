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

const NSString *newsURL = @"https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey=78d11b972d4e44a6a8cb8f4be28ab907";
//const NSString *newsURL = @"https://newsapi.org/v2/top-headlines?country=ru&apiKey=78d11b972d4e44a6a8cb8f4be28ab907";
@interface ViewController ()

@property (strong,nonatomic) NSMutableArray *newsRecords;
@property (assign,nonatomic) BOOL isTransfered;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if (!_isTransfered) {
        self.newsRecords = [[NSMutableArray alloc] init];
        [self retrieveNews];
    }
    
}

#pragma mark - retrieveNews
- (void)retrieveNews{
    NSLog(@"retrieveData");
    NSString *url_string = [NSString stringWithFormat: @"%@", newsURL];

    NSURL *url = [NSURL URLWithString:url_string];

    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                  NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                  if (!error) {
                                                      NSArray *recievedArticles = [jsonDictionary objectForKey:@"articles"];
                                                      [self updateArticlesData:recievedArticles];
                                                  }
                                              self.isTransfered = TRUE;
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [self.tableView reloadData];
                                              });
                                              
                                          }];
    
    [downloadTask resume];
    
}

- (void)updateArticlesData:(NSArray *)articlesArray{
    for (NSDictionary *articleHeader in articlesArray) {
        AKArticle *article = [[AKArticle alloc] init];
        article.title = [articleHeader objectForKey:@"title"];
        article.content = [articleHeader objectForKey:@"content"];
        article.contentDescription = [articleHeader objectForKey:@"description"];
        article.url = [articleHeader objectForKey:@"url"];
//        if (![article.content isEqual:[NSNull null]]) {
//            NSLog(@"title:%@ \nContent: %@\nURL: %@",article.title,article.content,article.url);
//        }else{
//            NSLog(@"title:%@ \nContent: %@\nURL: %@",article.title,article.contentDescription,article.url);
//        }
        [self.newsRecords addObject:article];
    }
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
   
    return @"Latest news in section";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.newsRecords count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* articleIdentifier = @"articleCell";
    NSLog(@"indexPath:%ld",(long)indexPath.row);
        
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:articleIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:articleIdentifier];
    }
    AKArticle *articleForRow = [self.newsRecords objectAtIndex:indexPath.row];
    cell.textLabel.text = articleForRow.title;
//    cell.detailTextLabel.text = self.testString;
//    articleForRow.contentDescription;
    return cell;
}
#pragma mark - TableView Delegate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//
//}

@end
