//
//  MKUIHelper.m
//  JLIM4iPhone
//
//  Created by jimneylee on 14-5-20.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "MKUIHelper.h"

@implementation MKUIHelper

+ (void)showWaitingMessage:(NSString *)message inView:(UIView *)view
{
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    HUD.detailsLabelText = [message copy];
    [HUD show:YES];
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

+ (void)showTextMessage:(NSString *)message inView:(UIView *)view
{
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.detailsLabelText = [message copy];
    [HUD hide:YES afterDelay:HUD_ANIMATION_DRURATION];
}

+ (void)showWaitingMessage:(NSString *)message inView:(UIView *)view inBlock:(dispatch_block_t)block
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    HUD.detailsLabelText = [message copy];
    [HUD showAnimated:YES whileExecutingBlock:block completionBlock:^{
        [HUD removeFromSuperview];
    }];
}

+ (void)showWaitingMessage:(NSString *)message
{
    [MKUIHelper showWaitingMessage:message inView:[UIApplication sharedApplication].keyWindow];
}
+ (void)hideWaitingMessage:(NSString *)message
{
    [MKUIHelper hideWaitingMessage:message inView:[UIApplication sharedApplication].keyWindow];
}
+ (void)showTextMessage:(NSString *)message
{
    [MKUIHelper showTextMessage:message inView:[UIApplication sharedApplication].keyWindow];
}

/////////////////////////////////////////////////////////////////////////
+ (void)configAppearenceForNavigationBar:(UINavigationBar *)navigationBar
{
    navigationBar.translucent = NO;
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:22.f],
                                          NSForegroundColorAttributeName : [UIColor whiteColor]};
}

+ (UIImage *)stretchableImageNamed:(NSString *)imageName{
    UIImage *image = [UIImage imageNamed:imageName];
    return [image stretchableImageWithLeftCapWidth:image.size.width/2
                                      topCapHeight:image.size.height/2];
}

+ (UIImage *)getImageFromAsset:(ALAsset *)asset
{
    if (asset) {
        UIImage* image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
        return image;
    }
    return nil;
}

@end
