//
//  MKAddressBookC.h
//  IMModel
//
//  Created by jimneylee on 14-5-19.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMAddressBookViewModel.h"

/**
 *  通讯录主页面
 */

@interface IMAddressBookC : UITableViewController

@property (nonatomic, strong) IMAddressBookViewModel *viewModel;

@end
