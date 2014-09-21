//
//  MKTabC.m
//  JLIM4iPhone
//
//  Created by jimneylee on 14-5-17.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMTabC.h"
#import "IMMessageC.h"
#import "IMAddressBookC.h"

@interface IMTabC ()

@end

@implementation IMTabC

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

#pragma mark - Private
- (NSArray *)generateViewContrllers
{
    Class NavClass = [UINavigationController class];
    
    IMMessageC *messageMainC = [[IMMessageC alloc] initWithStyle:UITableViewStylePlain];
    IMAddressBookC *addressBookC = [[IMAddressBookC alloc] init];
    
    UINavigationController *nav1 = [[NavClass alloc] initWithRootViewController:messageMainC];
    UINavigationController *nav2 = [[NavClass alloc] initWithRootViewController:addressBookC];
    
    [MKUIHelper configAppearenceForNavigationBar:nav1.navigationBar];
    [MKUIHelper configAppearenceForNavigationBar:nav2.navigationBar];
    
    NSArray *titles = @[@"消息", @"通讯录"];
    NSArray *navArray = @[nav1, nav2];
    UINavigationController *nav = nil;
    NSString *normalImageName = nil;
    NSString *selectedImageName = nil;
    
    if (TTOSVersionIsAtLeast7()) {
        for (int i = 0; i < navArray.count; i++) {
            nav = navArray[i];
            normalImageName = [NSString stringWithFormat:@"icon_tab%d", i+1];
            selectedImageName = [NSString stringWithFormat:@"icon_tab%dh", i+1];
            nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:titles[i]
                                                           image:[[UIImage imageNamed:normalImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                   selectedImage:[[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        }
    }
    else {
        for (int i = 0; i < navArray.count; i++) {
            nav = navArray[i];
            normalImageName = [NSString stringWithFormat:@"icon_tab%d", i+1];
            selectedImageName = [NSString stringWithFormat:@"icon_tab%dh", i+1];
            [nav.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:selectedImageName]
                          withFinishedUnselectedImage:[UIImage imageNamed:normalImageName]];
        }
        [[UITabBar appearance] setBackgroundImage:[[UIImage imageNamed:@"tabbar_bg.png"]
                                                   stretchableImageWithLeftCapWidth:10.f topCapHeight:10.f]];
        [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage imageNamed:@"tabbar_bg.png"]
                                                           stretchableImageWithLeftCapWidth:10.f topCapHeight:10.f]];
        
        NSDictionary *normalState = @{UITextAttributeTextColor : [UIColor grayColor]};
        NSDictionary *selectedState = @{UITextAttributeTextColor : APP_MAIN_COLOR};
        
        [[UITabBarItem appearance] setTitleTextAttributes:normalState forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:selectedState forState:UIControlStateHighlighted];
    }
        
    RAC(nav1.tabBarItem, badgeValue) = [RACObserve(messageMainC.viewModel, totalUnreadMessagesNum) map:^id(NSNumber *value) {
        if ([value intValue] > 0) {
            return [value stringValue];
        }
        else {
            return nil;
        }
    }];
    
    RAC(nav2.tabBarItem, badgeValue) = [RACObserve(addressBookC.viewModel, unsubscribedCountNum) map:^id(NSNumber *value) {
        if ([value intValue] > 0) {
            return [value stringValue];
        }
        else {
            return nil;
        }
    }];
    
    return @[nav1, nav2];
}

@end
