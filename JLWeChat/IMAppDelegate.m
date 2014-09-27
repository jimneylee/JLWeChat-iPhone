//
//  MMAppDelegate.m
//  JLWeChat
//
//  Created by jimneylee on 14-5-12.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMAppDelegate.h"
#import <AFNetworkReachabilityManager.h>
#import <UIImageView+AFNetworking.h>
#import <AVOSCloud/AVOSCloud.h>
#import "IMCache.h"

@implementation IMAppDelegate

#pragma mark - Private

- (void)configAppAppearance
{
    if (TTOSVersionIsAtLeast7()) {
        [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setBarTintColor:APP_MAIN_COLOR];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    else {
        [[UIBarButtonItem appearance] setTintColor:APP_MAIN_COLOR];
        [[UINavigationBar appearance] setTintColor:APP_MAIN_COLOR];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    }
    
    [[UITabBar appearance] setBackgroundColor:APP_MAIN_COLOR];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
}

- (void)configAppCapabilities
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // avos
    [AVOSCloud setApplicationId:@"t6lz5bvwdtn7jgdimwyeeme6f6jwphljcmmjl4zxa1s4vxb1"
                      clientKey:@"7vsub9e76ntqqmt3n5i3tml0m7q8bof63r89rc0q7wvawiml"];
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configAppAppearance];
    [self configAppCapabilities];
    //[AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    self.tabBarC = [[IMTabC alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.tabBarC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[IMDataBaseManager sharedManager] saveContext];
}

@end
