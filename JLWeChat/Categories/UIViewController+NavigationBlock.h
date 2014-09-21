//
//  UIViewController+NavigationBlock.h
//  JLIM4iPhone
//
//  Created by jimneylee on 14-5-26.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <UIKit/UIKit.h>


/* sample
 
 [self pop2SelfThanPushBlock:^{
    UIViewController* c = [[UIViewController all] init];
    [self.navigationController pushViewController:c animation:YES];
 }];
 */

typedef void (^NavigationCompletionBlock)(void);
typedef void (^TabCompletionBlock)(UINavigationController* nc);

@interface UIViewController (NavigationBlock) <UINavigationControllerDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) NavigationCompletionBlock navigationBlock;
@property (strong, nonatomic) TabCompletionBlock tabBlock;

- (void)pop2SelfThanPushBlock:(NavigationCompletionBlock)block;

- (void)pop2RootThanPushInFirstTab:(TabCompletionBlock)block;

@end
