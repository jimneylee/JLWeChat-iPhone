//
//  FUIButton.h
//  FlatUI
//
//  Created by Jack Flintermann on 5/7/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FUIButton : UIButton

@property(nonatomic, strong) UIColor *buttonColor;
@property(nonatomic, strong) UIColor *shadowColor;
@property(nonatomic, assign) CGFloat shadowHeight;
@property(nonatomic, assign) CGFloat cornerRadius;

@end
