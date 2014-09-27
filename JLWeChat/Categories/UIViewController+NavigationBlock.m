//
//  UIViewController+NavigationBlock.m
//  JLWeChat
//
//  Created by john on 14-5-26.
//  Copyright (c) 2014年 john. All rights reserved.
//

#import "UIViewController+NavigationBlock.h"
#import <objc/runtime.h>

static const void *NavigationBlock1 = &NavigationBlock1;
static const void *TabBlock1 = &TabBlock1;

@implementation UIViewController (NavigationBlock)

@dynamic navigationBlock;
@dynamic tabBlock;

- (void)setNavigationBlock:(NavigationCompletionBlock)navigationBlock
{
    objc_setAssociatedObject(self, NavigationBlock1, navigationBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NavigationCompletionBlock)navigationBlock
{
    return objc_getAssociatedObject(self, NavigationBlock1);
}

- (void)setTabBlock:(TabCompletionBlock)tabBlock
{
    objc_setAssociatedObject(self, TabBlock1, tabBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TabCompletionBlock)tabBlock
{
    return objc_getAssociatedObject(self, TabBlock1);
}

- (void)pop2SelfThanPushBlock:(NavigationCompletionBlock)block
{
    self.navigationBlock = block;
    self.navigationController.delegate = self;
    [self.navigationController popToViewController:self animated:NO];
}

- (void)pop2RootThanPushInFirstTab:(TabCompletionBlock)block
{
    self.tabBlock = block;
    self.navigationController.delegate = self;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark -
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.navigationBlock) {
        self.navigationBlock();
        self.navigationBlock = nil;
        navigationController.delegate = nil;
    }
    else if (self.tabBlock) {
        navigationController.tabBarController.selectedIndex = 0;
        self.tabBlock((id)navigationController.tabBarController.selectedViewController);
        self.tabBlock = nil;
        navigationController.delegate = nil;
    }
}

@end
