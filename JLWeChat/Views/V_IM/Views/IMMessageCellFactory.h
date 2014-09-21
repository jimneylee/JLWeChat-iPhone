//
//  MKMessageCellFactory.h
//  JLIM4iPhone
//
//  Created by jimneylee on 14-5-22.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMMessageCellFactory : NSObject

@end


@interface MKMessageBaseCell : UITableViewCell

- (BOOL)shouldUpdateCellWithObject:(id)object;

@end

@interface MKMessageTextCell : MKMessageBaseCell

+ (CGFloat)heightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

@end

@interface MKMessageImageCell : MKMessageBaseCell

+ (CGFloat)heightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

@end