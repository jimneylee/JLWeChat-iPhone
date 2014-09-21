//
//  MKSearchDisplayController.h
//  JLIM4iPhone
//
//  Created by Lee jimney on 6/2/14.
//  Copyright (c) 2014 jimneylee. All rights reserved.
//

#import <UIKit/UIKit.h>

// 由于无法继承UISearchDisplayController，所以此处采用引入一个属性来实现封装
@interface IMSearchDisplayController : NSObject

@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;

- (instancetype)initWithSearchBar:(UISearchBar *)searchBar contentsController:(UIViewController *)viewController;

@end
