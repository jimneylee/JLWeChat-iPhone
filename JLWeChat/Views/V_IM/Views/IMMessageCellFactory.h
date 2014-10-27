//
//  IMMessageCellFactory.h
//  JLWeChat
//
//  Created by jimneylee on 14-5-22.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMMessageCellFactory : NSObject

@end


@interface IMMessageBaseCell : UITableViewCell

- (BOOL)shouldUpdateCellWithObject:(id)object;

@end

@interface IMMessageTextCell : IMMessageBaseCell

+ (CGFloat)heightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

@end

@interface IMMessageImageCell : IMMessageBaseCell

+ (CGFloat)heightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

@end

@interface IMMessageAudioCell : IMMessageBaseCell

+ (CGFloat)heightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

@end