//
//  JLFirstViewController.h
//  JLWeChat
//
//  Created by jimneylee on 14-5-17.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMMainMessageViewModel.h"

/**
 * 消息主界面
 */
@interface IMMainMessageC : UITableViewController

@property (nonatomic, strong) IMMainMessageViewModel *viewModel;

@end
