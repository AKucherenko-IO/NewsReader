//
//  AKArticleDetailsViewController.h
//  NewsReader
//
//  Created by Andrei Kucherenko on 20/11/2018.
//  Copyright © 2018 AKA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKArticle.h"

NS_ASSUME_NONNULL_BEGIN

@interface AKArticleDetailsViewController : UIViewController

@property (strong,nonatomic)  UIViewController *delegate;
@property (strong, nonatomic) AKArticle *article;

@end

NS_ASSUME_NONNULL_END
