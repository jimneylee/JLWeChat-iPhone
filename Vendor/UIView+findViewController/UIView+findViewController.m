//
//  UIView+findViewController.m
//  SinaMBlogNimbus
//
//  Created by jimneylee on 13-12-2.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "UIView+findViewController.h"

@implementation UIView (findViewController)
- (UIViewController *)viewController {
    // Traverse responder chain. Return first found view controller, which will be the view's view controller.
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]))
        if ([responder isKindOfClass:[UIViewController class]])
            return (UIViewController *)responder;
    
    // If the view controller isn't found, return nil.
    return nil;
}
@end