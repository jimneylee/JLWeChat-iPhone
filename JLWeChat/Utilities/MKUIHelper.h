//
//  MKUIHelper.h
//  JLIM4iPhone
//
//  Created by jimneylee on 14-5-20.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIViewAdditions.h"
#import <MBProgressHUD.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define HUD_ANIMATION_DRURATION (0.8f)
#define HUD_LOADING_MESSAGE @"努力加载中..."
#define HUD_LOAD_FAILDMESSAGE @"加载失败！"

@interface MKUIHelper : NSObject

+ (void)showWaitingMessage:(NSString *)message inView:(UIView *)view;
+ (void)hideWaitingMessage:(NSString *)message inView:(UIView *)view;
+ (void)showTextMessage:(NSString *)message inView:(UIView *)view;

+ (void)showWaitingMessage:(NSString *)message inView:(UIView *)view inBlock:(dispatch_block_t)block;

+ (void)showWaitingMessage:(NSString *)message;
+ (void)hideWaitingMessage:(NSString *)message;
+ (void)showTextMessage:(NSString *)message;

+ (void)configAppearenceForNavigationBar:(UINavigationBar *)navigationBar;
+ (UIImage *)stretchableImageNamed:(NSString *)imageName;

+ (UIImage *)getImageFromAsset:(ALAsset *)asset;
@end
