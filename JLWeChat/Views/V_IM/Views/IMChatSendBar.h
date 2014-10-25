//
//  RCQuickReplyC.h
//  JLRubyChina
//
//  Created by Lee jimney on 12/12/13.
//  Copyright (c) 2013 jimneylee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, MKChatSendBarFunctionOptions) {
    MKChatSendBarFunctionOption_Voice   = 1 << 0,
    MKChatSendBarFunctionOption_Text    = 1 << 1,
    MKChatSendBarFunctionOption_Emotion = 1 << 2,
    MKChatSendBarFunctionOption_More    = 1 << 3,
    MKChatSendBarFunctionOption_All     = MKChatSendBarFunctionOption_Voice | MKChatSendBarFunctionOption_Text |
                                          MKChatSendBarFunctionOption_Emotion | MKChatSendBarFunctionOption_More
};

@protocol MKChatSendBarDelegate;

@interface IMChatSendBar : UIView

@property (nonatomic, weak) id<MKChatSendBarDelegate> delegate;
@property (nonatomic, copy) NSString *inputText;
@property (nonatomic, assign) MKChatSendBarFunctionOptions functionOptions;

- (id)initWithFunctionOptions:(MKChatSendBarFunctionOptions)options;

- (void)insertEmotionName:(NSString *)emotionName;
- (BOOL)makeTextViewBecomeFirstResponder;
- (BOOL)makeTextViewResignFirstResponder;
- (void)clearInputTextView;
- (void)makeSendEnable;
- (void)deleteLastCharTextView;

@end

@protocol MKChatSendBarDelegate <NSObject>

@optional

- (void)showVoiceView;
- (void)showEmtionView;
- (void)showShareMoreView;
- (void)showKeyboard;
- (void)sendPlainMessage:(NSString *)plainMessage;
- (void)didChangeHeight:(CGFloat)height;

@end