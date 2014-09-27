//
//  RCQuickReplyC.m
//  JLRubyChina
//
//  Created by Lee jimney on 12/12/13.
//  Copyright (c) 2013 jimneylee. All rights reserved.
//

#import "IMChatSendBar.h"
#import "HPGrowingTextView.h"
#import <AFNetworkReachabilityManager.h>
#import "IMUIHelper.h"
#import "IMEmotionManager.h"

#define CHAT_INPUT_BAR_SIZE CGSizeMake([UIScreen mainScreen].bounds.size.width, TT_TOOLBAR_HEIGHT)
#define TEXT_NEXT_LINE @"\n"

#define BUTTON_TAG_VOICE 1000
#define BUTTON_TAG_KEYBOARD 1001
#define BUTTON_TAG_EMOTION 1002

#define VOICE_ENABLE 0

@interface IMChatSendBar ()<HPGrowingTextViewDelegate>

@property (nonatomic, strong) HPGrowingTextView *textView;
@property (nonatomic, strong) UIImageView *textViewBgImageView;
@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, strong) UIButton *voiceKeyboardBtn;
@property (nonatomic, strong) UIButton *emotionKeyboardBtn;
@property (nonatomic, strong) UIButton *moreBtn;

@property (nonatomic, assign) BOOL isSendKeyTapped;
@property (nonatomic, assign) BOOL sendEnable;
@property (nonatomic, assign) NSRange nextlineRange;
@property (nonatomic, copy)   NSString *inputMessage;
@property (nonatomic, assign) CGFloat lastViewHeight;
@property (nonatomic, assign) NSRange cusorRange;

@end

@implementation IMChatSendBar

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIView

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFunctionOptions:(MKChatSendBarFunctionOptions)options;
{
    self = [super initWithFrame:CGRectMake(0, 0, CHAT_INPUT_BAR_SIZE.width, CHAT_INPUT_BAR_SIZE.height)];
    if (self) {
        self.functionOptions = options;

        // view
        [self addSubview:self.voiceKeyboardBtn];
        [self addSubview:self.textView];
        [self addSubview:self.textViewBgImageView];
        [self addSubview:self.emotionKeyboardBtn];
        [self addSubview:self.moreBtn];
        [self addSubview:self.recordBtn];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        self.isSendKeyTapped = NO;
        self.sendEnable = YES;
        self.recordBtn.hidden = YES;
        self.lastViewHeight = self.height;
        self.cusorRange = NSMakeRange(0, 0);
        
        [self customLayoutSubviews];
    }
    
    return self;
}

- (void)customLayoutSubviews
{
    
    // layout
    CGFloat kViewWidth = CHAT_INPUT_BAR_SIZE.width;
    CGFloat kViewHeight = CHAT_INPUT_BAR_SIZE.height;
    
    CGFloat kBtnWidth = 35.f;
    CGFloat KBtnHeight = 35.f;
    CGFloat kBtnTopMargin = (kViewHeight - KBtnHeight) / 2;
    
    CGFloat kTextViewWidth = kViewWidth;
    
    CGFloat kTextViewBgMargin = 2.f;
    CGFloat kTextViewMinHeight = 35.f;
    CGFloat kTextViewMaxHeight = SCREEN_SIZE.height - TT_KEYBOARD_HEIGHT
    - (TT_STATUSBAR_HEITH + TT_TOOLBAR_HEIGHT) - TT_TOOLBAR_HEIGHT * 3;// 粗略估算
    
    if (self.functionOptions & MKChatSendBarFunctionOption_Voice) {
        kTextViewWidth = kTextViewWidth - kBtnWidth;
        self.voiceKeyboardBtn.frame = CGRectMake(0.f, kBtnTopMargin, kBtnWidth, KBtnHeight);
    }
    else {
        self.voiceKeyboardBtn.frame = CGRectZero;
    }
    
    if (self.functionOptions & MKChatSendBarFunctionOption_Emotion) {
        kTextViewWidth = kTextViewWidth - kBtnWidth;
        self.emotionKeyboardBtn.frame = CGRectMake(0.f, kBtnTopMargin, kBtnWidth, KBtnHeight);
    }
    else {
        self.emotionKeyboardBtn.frame = CGRectZero;
    }
    
    if (self.functionOptions & MKChatSendBarFunctionOption_More) {
        kTextViewWidth = kTextViewWidth - kBtnWidth;
        self.moreBtn.frame = CGRectMake(0.f, kBtnTopMargin, kBtnWidth, KBtnHeight);
    }
    else {
        self.moreBtn.frame = CGRectZero;
    }
    
    if (self.functionOptions & MKChatSendBarFunctionOption_Text) {
        self.textViewBgImageView.frame = CGRectMake(self.voiceKeyboardBtn.right, kTextViewBgMargin,
                                                    kTextViewWidth, kViewHeight - kTextViewBgMargin * 2);
        self.textView.frame = CGRectMake(self.voiceKeyboardBtn.right, kBtnTopMargin,
                                         kTextViewWidth, kTextViewMinHeight);
        self.textView.minHeight = kTextViewMinHeight;
        self.textView.maxHeight = kTextViewMaxHeight;
    }
    else {
        self.textViewBgImageView.frame = CGRectZero;
        self.textView.frame = CGRectZero;
    }
    
    self.textViewBgImageView.left = self.voiceKeyboardBtn.right;
    self.textView.left = self.voiceKeyboardBtn.right;
    self.emotionKeyboardBtn.left = self.textViewBgImageView.right;
    self.moreBtn.left = self.emotionKeyboardBtn.right;
    self.recordBtn.frame = self.textView.frame;
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
    
    UIColor *borderLineColor = RGBCOLOR(180, 180, 180);

    // 背景
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(ctx, RGBCOLOR(244, 244, 244).CGColor);
	CGContextFillRect(ctx, CGRectMake(0.5f, rect.size.height - 0.5f,
                                      rect.size.width, rect.size.height - 1.f));
	
	CGContextSetStrokeColorWithColor(ctx, [borderLineColor CGColor]);
	CGContextBeginPath(ctx);
    
    CGContextSetLineWidth(ctx, 0.5f);

    // 顶部线条
    CGContextMoveToPoint(ctx, 0.f, 0.5f);
	CGContextAddLineToPoint(ctx, rect.size.width, 0.5f);
    
    // 底部线条
	CGContextMoveToPoint(ctx, 0.f, rect.size.height - 0.5f);
	CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height - 0.5f);
	CGContextDrawPath(ctx, kCGPathStroke);
}

#pragma mark - Button Action

- (void)recordVoiceAction
{

}

- (void)switchVoiceWithKeyboard
{
    if (BUTTON_TAG_VOICE == self.voiceKeyboardBtn.tag) {
        // switch to voice input
        if (self.delegate && [self.delegate respondsToSelector:@selector(showVoice)]) {
            [self.delegate showVoice];
        }
        
        self.lastViewHeight = self.height;//use to voice
        self.recordBtn.hidden = NO;
        self.textView.hidden = YES;
        [self.textView resignFirstResponder];
        self.voiceKeyboardBtn.tag = BUTTON_TAG_KEYBOARD;
        [self.voiceKeyboardBtn setImage:[UIImage imageNamed:@"ToolViewKeyboard.png"]
                                 forState:UIControlStateNormal];
        [self.voiceKeyboardBtn setImage:[UIImage imageNamed:@"ToolViewKeyboardHL.png"]
                                 forState:UIControlStateHighlighted];
    }
    else {
        // switch to keyboard input
        if (self.delegate && [self.delegate respondsToSelector:@selector(showKeyboard)]) {
            [self.delegate showKeyboard];
        }
        
        self.textView.hidden = NO;
        self.recordBtn.hidden = YES;
        self.height = self.lastViewHeight;//use to voice
        
        [self.textView becomeFirstResponder];
        self.voiceKeyboardBtn.tag = BUTTON_TAG_VOICE;
        [self.voiceKeyboardBtn setImage:[UIImage imageNamed:@"ToolViewInputVoice.png"]
                               forState:UIControlStateNormal];
        [self.voiceKeyboardBtn setImage:[UIImage imageNamed:@"ToolViewInputVoiceHL.png"]
                               forState:UIControlStateHighlighted];

    }
}

- (void)switchEmotionWithKeyboard
{
    if (BUTTON_TAG_EMOTION == self.emotionKeyboardBtn.tag) {
        
        // switch to emotion input
        if (self.delegate && [self.delegate respondsToSelector:@selector(showEmtionView)]) {
            [self.delegate showEmtionView];

        }
        
        self.textView.hidden = NO;
        self.recordBtn.hidden = YES;
        self.height = self.lastViewHeight;
        self.cusorRange = self.textView.internalTextView.selectedRange;
        [self.textView resignFirstResponder];
        
        self.emotionKeyboardBtn.tag = BUTTON_TAG_KEYBOARD;
        [self.emotionKeyboardBtn setImage:[UIImage imageNamed:@"ToolViewKeyboard.png"]
                                 forState:UIControlStateNormal];
        [self.emotionKeyboardBtn setImage:[UIImage imageNamed:@"ToolViewKeyboardHL.png"]
                                 forState:UIControlStateHighlighted];
    }
    else {
        // switch to keyboard input
        if (self.delegate && [self.delegate respondsToSelector:@selector(showKeyboard)]) {
            [self.delegate showKeyboard];
        }
        
        [self.textView becomeFirstResponder];

        self.emotionKeyboardBtn.tag = BUTTON_TAG_EMOTION;
        [self.emotionKeyboardBtn setImage:[UIImage imageNamed:@"ToolViewEmotion.png"]
                                 forState:UIControlStateNormal];
        [self.emotionKeyboardBtn setImage:[UIImage imageNamed:@"ToolViewEmotionHL.png"]
                                 forState:UIControlStateHighlighted];
    }
}

- (void)showMoreAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(showShareMoreView)]) {
        [self.delegate showShareMoreView];
    }
    
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }

    if (BUTTON_TAG_KEYBOARD == self.emotionKeyboardBtn.tag) {
        self.emotionKeyboardBtn.tag = BUTTON_TAG_EMOTION;
        [self.emotionKeyboardBtn setImage:[UIImage imageNamed:@"ToolViewEmotion.png"]
                                 forState:UIControlStateNormal];
        [self.emotionKeyboardBtn setImage:[UIImage imageNamed:@"ToolViewEmotionHL.png"]
                                 forState:UIControlStateHighlighted];
    }
}

#pragma mark - Private

- (BOOL)checkInputTextValid:(NSString *)intputText
{
    if (intputText.length > 0 && ![intputText isEqualToString:TEXT_NEXT_LINE]) {
        return YES;
    }
    return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollToBottomAnimated:(BOOL)animated
{
    [self.textView.internalTextView scrollRectToVisible:
     CGRectMake(0.f,
                self.textView.internalTextView.contentSize.height - self.textView.internalTextView.height,
                self.textView.internalTextView.width,
                self.textView.internalTextView.height)
                                               animated:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (NSString *)inputText
{
    return self.textView.text;
}

- (void)setInputText:(NSString *)text
{
    self.textView.text = text;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)insertEmotionName:(NSString *)emotionName
{
    if (self.cusorRange.location > self.textView.text.length) {
        self.textView.text = [NSString stringWithFormat:@"%@%@", self.textView.text, emotionName];
    }
    else {
        NSMutableString *text = [NSMutableString stringWithString:self.textView.text];
        [text insertString:emotionName atIndex:self.cusorRange.location];
        self.textView.text = text;
    }
    
    self.cusorRange = NSMakeRange(self.cusorRange.location + emotionName.length,
                                  self.cusorRange.length + emotionName.length);
    
    if (self.textView.internalTextView.contentSize.height > self.textView.maxHeight) {
        [self scrollToBottomAnimated:YES];
    }
}

- (void)deleteLastCharTextView
{
    if (self.textView.text.length > 0) {
        NSRange range = NSMakeRange(self.textView.text.length - 1, 1);
        BOOL success =
        [[IMEmotionManager sharedManager] deleteEmotionInTextView:self.textView.internalTextView
                                                          atRange:range];
        if (success) {
            
        }
        else {
            self.textView.text = [self.textView.text substringToIndex:self.textView.text.length - 1];
        }
        [self.textView refreshHeight];
    }
}

- (BOOL)makeTextViewBecomeFirstResponder
{
    if (!self.textView.isFirstResponder) {
        [self.textView becomeFirstResponder];
        return YES;
    }
    return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)makeTextViewResignFirstResponder
{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
        return YES;
    }
    return NO;
}

- (void)clearInputTextView
{
    self.textView.text = @"";
}

- (void)makeSendEnable
{
    self.sendEnable = YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - HPGrowingTextViewDelegate

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
    if (BUTTON_TAG_KEYBOARD == self.emotionKeyboardBtn.tag) {
        self.emotionKeyboardBtn.tag = BUTTON_TAG_EMOTION;
        [self.emotionKeyboardBtn setImage:[UIImage imageNamed:@"ToolViewEmotion.png"]
                                 forState:UIControlStateNormal];
        [self.emotionKeyboardBtn setImage:[UIImage imageNamed:@"ToolViewEmotionHL.png"]
                                 forState:UIControlStateHighlighted];
    }
    // TODO: voice
    
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // 由于底层点击发送会使键盘消失，故此处处理，不在growingTextViewShouldReturn中处理
	if ([text isEqualToString:TEXT_NEXT_LINE]) {
        self.nextlineRange = range;
        
        if (self.sendEnable) {
            if ([AFNetworkReachabilityManager sharedManager].isReachable)
            {
                if ([self checkInputTextValid:growingTextView.text]) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(sendPlainMessage:)]) {
                        [self.delegate sendPlainMessage:self.textView.text];
                        // 不可重复发送，直到接收到成功或者失败回调信息
                        self.sendEnable = NO;
                    }
                }
            }
            else {
                [IMUIHelper showTextMessage:@"网络不可用，无法发送"
                                     inView:[UIApplication sharedApplication].keyWindow];
            }
        }
        return NO;
	}
    
    // 删除字符
    if (0 == text.length) {
        BOOL success =
        [[IMEmotionManager sharedManager] deleteEmotionInTextView:growingTextView.internalTextView
                                                          atRange:range];
        if (success) {
            [growingTextView refreshHeight];
            return NO;
        }
    }
    
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.frame = r;
    
    self.lastViewHeight = self.height;//use to voice
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeHeight:)]) {
        [self.delegate didChangeHeight:height];
    }
    if (self.textView.internalTextView.contentSize.height > self.textView.maxHeight) {
        [self scrollToBottomAnimated:YES];
    }
}

#pragma mark UI

- (HPGrowingTextView *)textView
{
    if (!_textView) {
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        _textView = [[HPGrowingTextView alloc] initWithFrame:CGRectZero];
        _textView.isScrollable = NO;
        _textView.contentInset = edgeInsets;
        _textView.internalTextView.scrollIndicatorInsets = edgeInsets;
        _textView.internalTextView.enablesReturnKeyAutomatically = YES;
        
        _textView.animateHeightChange = YES;
        _textView.animationDuration = 0.2f;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.font = [UIFont systemFontOfSize:15.0f];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _textView.delegate = self;
    }
    return _textView;
}

- (UIImageView *)textViewBgImageView
{
    if (!_textViewBgImageView) {
        UIImage *textViewBgImage = [UIImage imageNamed:@"SendTextViewBkg.png"];
        _textViewBgImageView = [[UIImageView alloc] initWithImage:
                                [textViewBgImage stretchableImageWithLeftCapWidth:textViewBgImage.size.width / 2
                                                                     topCapHeight:textViewBgImage.size.height / 2]];
        _textViewBgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _textViewBgImageView;
}

- (UIButton *)voiceKeyboardBtn
{
    if (!_voiceKeyboardBtn) {
        _voiceKeyboardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_voiceKeyboardBtn setImage:[UIImage imageNamed:@"ToolViewInputVoice.png"] forState:UIControlStateNormal];
        [_voiceKeyboardBtn setImage:[UIImage imageNamed:@"ToolViewInputVoiceHL.png"] forState:UIControlStateHighlighted];
        [_voiceKeyboardBtn addTarget:self action:@selector(switchVoiceWithKeyboard) forControlEvents:UIControlEventTouchUpInside];
        _voiceKeyboardBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        _voiceKeyboardBtn.tag = BUTTON_TAG_VOICE;
        self.voiceKeyboardBtn = _voiceKeyboardBtn;
    }
    return _voiceKeyboardBtn;
}

- (UIButton *)emotionKeyboardBtn
{
    if (!_emotionKeyboardBtn) {
        _emotionKeyboardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emotionKeyboardBtn setImage:[UIImage imageNamed:@"ToolViewEmotion.png"] forState:UIControlStateNormal];
        [_emotionKeyboardBtn setImage:[UIImage imageNamed:@"ToolViewEmotionHL.png"] forState:UIControlStateHighlighted];
        [_emotionKeyboardBtn addTarget:self action:@selector(switchEmotionWithKeyboard) forControlEvents:UIControlEventTouchUpInside];
        _emotionKeyboardBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        _emotionKeyboardBtn.tag = BUTTON_TAG_EMOTION;
    }
    return _emotionKeyboardBtn;
}

- (UIButton *)moreBtn
{
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreBtn setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black.png"] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black.png"] forState:UIControlStateHighlighted];
        [_moreBtn addTarget:self action:@selector(showMoreAction) forControlEvents:UIControlEventTouchUpInside];
        _moreBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    }
    return _moreBtn;
}

- (UIButton *)recordBtn
{
    if (!_recordBtn) {
        _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordBtn.backgroundColor = RGBCOLOR(230, 230, 230);
        [_recordBtn addTarget:self action:@selector(recordVoiceAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordBtn;
}

@end
