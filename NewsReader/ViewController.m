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

//const NSString *newsURL = @"https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey=78d11b972d4e44a6a8cb8f4be28ab907";
const NSString *newsURL = @"https://newsapi.org/v2/top-headlines?country=ru&apiKey=78d11b972d4e44a6a8cb8f4be28ab907";
@interface ViewController ()

@property (strong,nonatomic) NSMutableArray *newsRecords;
@property (weak,nonatomic) NSString *testString;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.newsRecords = [[NSMutableArray alloc] init];
    [self retrieveNews];
    self.testString = @"Test Var";
    
}

#pragma mark - retrieveNews
- (void)retrieveNews{
    NSLog(@"retrieveData");
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"%@", newsURL];
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    if (data) {
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!error) {
            NSArray *recievedArticles = [jsonDictionary objectForKey:@"articles"];
            [self updateArticlesData:recievedArticles];
        }
    }
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
    NSLog(@"numberOfSectionsInTableView:%d",1);
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [NSString stringWithFormat:@"Latest news in section#%ld",(long)section];
    NSLog(@"titleForHeaderInSection:%ld",(long)section);
    return sectionTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"records=%lu section=%ld ",(unsigned long)[self.newsRecords count],(long)section);
    
    return [self.newsRecords count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* articleIdentifier = @"articleCell";
    NSLog(@"indexPath:%ld",(long)indexPath.row);
        
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:articleIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:articleIdentifier];
    }
    cell.textLabel.textColor = [UIColor blueColor];
    AKArticle *articleForRow = [self.newsRecords objectAtIndex:indexPath.row];
    cell.textLabel.text = articleForRow.title;
//    cell.detailTextLabel.text = self.testString;
//    articleForRow.contentDescription;
    return cell;
}
#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
