//
//  JLFirstViewController.h
//  JLIM4iPhone
//
//  Created by jimneylee on 14-5-17.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMMessageViewModel.h"

/**
 * 消息主界面
 */

@interface IMMessageC : UITableViewController

@property (nonatomic, strong) IMMessageViewModel *viewModel;

@end
