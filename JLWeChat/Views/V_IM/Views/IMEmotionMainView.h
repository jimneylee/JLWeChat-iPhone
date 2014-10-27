//
//  IMEmotionMainView.h
//  MeiKeiMeiShi
//
//  Created by jimney on 13-3-5.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "NimbusPagingScrollView.h"

@protocol IMEmotionDelegate;

@interface IMEmotionMainView : UIView

@property (nonatomic, weak) id<IMEmotionDelegate> emotionDelegate;

@end

@protocol IMEmotionDelegate <NSObject>

@optional
- (void)emotionSelectedWithName:(NSString*)name;
- (void)didEmotionViewDeleteAction;
- (void)didEmotionViewSendAction;
@end

