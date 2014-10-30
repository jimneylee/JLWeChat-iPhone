//
//  IMContactCell.h
//  JLWeChat
//
//  Created by jimneylee on 14-5-22.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMStaticContactCell : UITableViewCell

- (BOOL)shouldUpdateCellWithObject:(id)object unsubscribedCountNum:(NSNumber *)unsubscribedCountNum;

@end
