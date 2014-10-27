//
//  IMSimpleLoginC.h
//  IMModel
//
//  Created by jimneylee on 14-5-19.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMSimpleLoginC : UIViewController

@property (nonatomic,strong) IBOutlet UITextField *userIDField;
@property (nonatomic,strong) IBOutlet UITextField *passwordField;

- (IBAction)loginAction:(id)sender;
- (IBAction)registerAction:(id)sender;

@end
