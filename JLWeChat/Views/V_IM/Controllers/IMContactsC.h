//
//  IMContactsC.h
//  IMModel
//
//  Created by jimneylee on 14-5-19.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMContactsViewModel.h"

/**
 *  通讯录主页面
 */
@interface IMContactsC : UITableViewController

@property (nonatomic, strong) IMContactsViewModel *viewModel;

@end
