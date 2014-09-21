//
//  MKContactCell.h
//  MeiKeMeiShi
//
//  Created by jimneylee on 14-5-22.
//  Copyright (c) 2014年 john. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  新的朋友cell
 */
@interface MKNewFriendCell : UITableViewCell

@property (nonatomic, strong) UIButton *actionBtn;

- (BOOL)shouldUpdateCellWithObject:(id)object;

@end
