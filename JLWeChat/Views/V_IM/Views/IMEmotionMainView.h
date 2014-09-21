//
//  MKEmotionMainView.h
//  MeiKeiMeiShi
//
//  Created by jimney on 13-3-5.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "NimbusPagingScrollView.h"

@protocol MKEmotionDelegate;

@interface IMEmotionMainView : UIView

@property (nonatomic, weak) id<MKEmotionDelegate> emotionDelegate;

@end

@protocol MKEmotionDelegate <NSObject>

@optional
- (void)emotionSelectedWithName:(NSString*)name;
- (void)didEmotionViewDeleteAction;
- (void)didEmotionViewSendAction;
@end

