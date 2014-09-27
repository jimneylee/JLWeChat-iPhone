//
//  MKUIHelper.m
//  JLWeChat
//
//  Created by jimneylee on 14-5-20.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMUIHelper.h"
#import "UINavigationBar+FlatUI.h"
#import "UIBarButtonItem+FlatUI.h"

@implementation IMUIHelper

#pragma mark Show HUD Message

+ (void)showTextMessage:(NSString *)message
{
    [IMUIHelper showTextMessage:message inView:[UIApplication sharedApplication].keyWindow];
}

+ (void)showTextMessage:(NSString *)message inView:(UIView *)view
{
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.detailsLabelText = [message copy];
    [HUD hide:YES afterDelay:HUD_ANIMATION_DRURATION];
}

+ (void)showWaitingMessage:(NSString *)message
{
    [IMUIHelper showWaitingMessage:message inView:[UIApplication sharedApplication].keyWindow];
}

+ (void)showWaitingMessage:(NSString *)message inView:(UIView *)view
{
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    HUD.detailsLabelText = [message copy];
    [HUD show:YES];
}

+ (void)showWaitingMessage:(NSString *)message inView:(UIView *)view inBlock:(dispatch_block_t)block
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    HUD.detailsLabelText = [message copy];
    [HUD showAnimated:YES whileExecutingBlock:block completionBlock:^{
        [HUD removeFromSuperview];
    }];
}

#pragma mark Hide HUD Message

+ (void)hideWaitingMessage:(NSString *)message
{
    [IMUIHelper hideWaitingMessage:message inView:[UIApplication sharedApplication].keyWindow];
}

+ (void)hideWaitingMessage:(NSString *)message inView:(UIView *)view
{
    MBProgressHUD *HUD = [MBProgressHUD HUDForView:view];
    if (message) {
        HUD.detailsLabelText = [message copy];
        HUD.mode = MBProgressHUDModeText;
        [HUD hide:YES afterDelay:HUD_ANIMATION_DRURATION];
    }
    else {
        [HUD hide:YES];
    }
}

+ (void)hideWaitingMessageImmediatelyInView:(UIView *)view
{
    MBProgressHUD *HUD = [MBProgressHUD HUDForView:view];
    [HUD hide:YES];
}

+ (void)hideWaitingMessageImmediately
{
    MBProgressHUD *HUD = [MBProgressHUD HUDForView:[UIApplication sharedApplication].keyWindow];
    [HUD hide:YES];
}

#pragma mark Show Alert Message

+ (void)showAlertMessage:(NSString *)message
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil
                                       cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [av show];
}

#pragma mark Flat UI

+ (void)configAppearenceForNavigationBar:(UINavigationBar *)navigationBar
{
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:22.f],
                                          NSForegroundColorAttributeName : [UIColor whiteColor]};
    if (TTOSVersionIsAtLeast7()) {
        navigationBar.translucent = NO;
    }
    else {
        [navigationBar configureFlatNavigationBarWithColor:APP_MAIN_COLOR];
    }
}

+ (void)configFlatForBarButtonItem:(UIBarButtonItem *)item
{
    if (!TTOSVersionIsAtLeast7()) {
        [item setTitleTextAttributes:@{UITextAttributeFont : [UIFont systemFontOfSize:16.f],
                                       UITextAttributeTextColor : [UIColor whiteColor]}
                            forState:UIControlStateNormal];
        [item removeTitleShadow];
        [item configureFlatButtonWithColor:APP_MAIN_COLOR
                          highlightedColor:[UIColor clearColor]
                              cornerRadius:0.f];
    }
}

+ (UIBarButtonItem *)createButtonItemWithTitle:(NSString *)title target:(id)target selector:(SEL)selector
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title
                                                             style:UIBarButtonItemStylePlain
                                                            target:target
                                                            action:selector];
    [IMUIHelper configFlatForBarButtonItem:item];
    
    return item;
}

+ (UIBarButtonItem *)createButtonItemWithImage:(UIImage *)image target:(id)target selector:(SEL)selector
{
    UIButton *btn = [[UIButton alloc] init];
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [IMUIHelper configFlatForBarButtonItem:item];
    
    return item;
}

@end
