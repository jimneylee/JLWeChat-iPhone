//
//  RCQuickReplyC.h
//  JLRubyChina
//
//  Created by Lee jimney on 12/12/13.
//  Copyright (c) 2013 jimneylee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, IMChatSendBarFunctionOptions) {
    IMChatSendBarFunctionOption_Voice   = 1 << 0,
    IMChatSendBarFunctionOption_Text    = 1 << 1,
    IMChatSendBarFunctionOption_Emotion = 1 << 2,
    IMChatSendBarFunctionOption_More    = 1 << 3,
    IMChatSendBarFunctionOption_All     = IMChatSendBarFunctionOption_Voice | IMChatSendBarFunctionOption_Text |
                                          IMChatSendBarFunctionOption_Emotion | IMChatSendBarFunctionOption_More
};

@protocol IMChatSendBarDelegate;

@interface IMChatSendBar : UIView

@property (nonatomic, weak) id<IMChatSendBarDelegate> delegate;
@property (nonatomic, copy) NSString *inputText;
@property (nonatomic, assign) IMChatSendBarFunctionOptions functionOptions;

- (id)initWithFunctionOptions:(IMChatSendBarFunctionOptions)options;

- (void)insertEmotionName:(NSString *)emotionName;
- (BOOL)makeTextViewBecomeFirstResponder;
- (BOOL)makeTextViewResignFirstResponder;
- (void)clearInputTextView;
- (void)makeSendEnable;
- (void)deleteLastCharTextView;

@end

@protocol IMChatSendBarDelegate <NSObject>

@optional

- (void)showVoiceView;
- (void)showEmtionView;
- (void)showShareMoreView;
- (void)showKeyboard;
- (void)sendPlainMessage:(NSString *)plainMessage;
- (void)didChangeHeight:(CGFloat)height;

@end