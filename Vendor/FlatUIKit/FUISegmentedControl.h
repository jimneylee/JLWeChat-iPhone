//
//  FUISegmentedControl.h
//  FlatUIKitExample
//
//  Created by Alex Medearis on 5/17/13.
//
//

#import <UIKit/UIKit.h>

@interface FUISegmentedControl : UISegmentedControl

@property(nonatomic, strong) UIColor *selectedColor;
@property(nonatomic, strong) UIColor *deselectedColor;
@property(nonatomic, strong) UIColor *dividerColor;
@property(nonatomic, readwrite) CGFloat cornerRadius;
@property(nonatomic, strong) UIFont *selectedFont;
@property(nonatomic, strong) UIFont *deselectedFont;
@property(nonatomic, strong) UIColor *selectedFontColor;
@property(nonatomic, strong) UIColor *deselectedFontColor;



@end
