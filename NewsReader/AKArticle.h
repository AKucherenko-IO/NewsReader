//
//  AKArticle.h
//  NewsReader
//
//  Created by Andrei Kucherenko on 17/11/2018.
//  Copyright © 2018 AKA. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AKArticle : NSObject

@property (strong,nonatomic) NSString *title;
@property (strong,nonatomic) NSString *content;
@property (strong,nonatomic) NSString *contentDescription;
@property (strong,nonatomic) NSString *url;
@property (strong,nonatomic) NSString *urlToImage;
@property (strong,nonatomic) NSString *publishedAt;

@end

NS_ASSUME_NONNULL_END
