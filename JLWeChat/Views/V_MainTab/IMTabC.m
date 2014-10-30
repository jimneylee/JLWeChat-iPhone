//
//  IMTabC.m
//  JLWeChat
//
//  Created by jimneylee on 14-5-17.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMTabC.h"
#import "IMMainMessageC.h"
#import "IMContactsC.h"

@interface IMTabC ()

@end

@implementation IMTabC

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.viewControllers = [self generateViewContrllers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private
///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSArray *)generateViewContrllers
{
    Class NavClass = [UINavigationController class];
    
    IMMainMessageC *messageMainC = [[IMMainMessageC alloc] initWithStyle:UITableViewStylePlain];
    IMContactsC *contactsC = [[IMContactsC alloc] init];
    
    UINavigationController *messageMainNavC = [[NavClass alloc] initWithRootViewController:messageMainC];
    UINavigationController *contactsCNav = [[NavClass alloc] initWithRootViewController:contactsC];
    
    [IMUIHelper configAppearenceForNavigationBar:messageMainNavC.navigationBar];
    [IMUIHelper configAppearenceForNavigationBar:contactsCNav.navigationBar];
    
    if (TTOSVersionIsAtLeast7()) {
        messageMainNavC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"消息"
                                                                   image:[[UIImage imageNamed:@"tabbar_mainframe"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                           selectedImage:[[UIImage imageNamed:@"tabbar_mainframeHL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        contactsCNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"通讯录"
                                                                image:[[UIImage imageNamed:@"tabbar_contacts"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                        selectedImage:[[UIImage imageNamed:@"tabbar_contactsHL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        // custom background view for ios7+
        UIView *customBgView = [[UIView alloc] initWithFrame:self.tabBar.bounds];
        customBgView.backgroundColor = APP_MAIN_COLOR;
        [self.tabBar insertSubview:customBgView atIndex:0];
        self.tabBar.opaque = YES;
    }
    else {
        messageMainC.tabBarItem.title = @"消息";
        [messageMainNavC.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_mainframeHL"]
                                 withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_mainframe"]];
        
        contactsCNav.tabBarItem.title = @"通讯录";
        [contactsCNav.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_contactsHL"]
                              withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_contacts"]];
        
        [[UITabBar appearance] setBackgroundImage:[[UIImage imageNamed:@"tabbarBkg.png"]
                                                   stretchableImageWithLeftCapWidth:5.f topCapHeight:5.f]];
        [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage imageNamed:@"tabbarBkg.png"]
                                                           stretchableImageWithLeftCapWidth:5.f topCapHeight:5.f]];
    }
        
    RAC(messageMainNavC.tabBarItem, badgeValue) = [RACObserve(messageMainC.viewModel, totalUnreadMessagesNum)
                                                   map:^id(NSNumber *value) {
        if ([value intValue] > 0) {
            return [value stringValue];
        }
        else {
            return nil;
        }
    }];
    
    RAC(contactsCNav.tabBarItem, badgeValue) = [RACObserve(contactsC.viewModel, unsubscribedCountNum)
                                                map:^id(NSNumber *value) {
        if ([value intValue] > 0) {
            return [value stringValue];
        }
        else {
            return nil;
        }
    }];
    
    return @[messageMainNavC, contactsCNav];
}

@end
