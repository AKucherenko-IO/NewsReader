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

@property (weak,nonatomic) NSString *title;
@property (weak,nonatomic) NSString *content;
@property (weak,nonatomic) NSString *contentDescription;
@property (weak,nonatomic) NSString *url;

@end

NS_ASSUME_NONNULL_END
