//
//  MKContactCell.h
//  JLIM4iPhone
//
//  Created by jimneylee on 14-5-22.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIBadgeView.h"

@interface IMStaticContactCell : UITableViewCell

@property (nonatomic, strong) NIBadgeView *badgeView;

- (BOOL)shouldUpdateCellWithObject:(id)object unsubscribedCountNum:(NSNumber *)unsubscribedCountNum;

@end
