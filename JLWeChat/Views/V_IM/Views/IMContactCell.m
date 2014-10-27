//
//  IMContactCell.m
//  JLWeChat
//
//  Created by jimneylee on 14-5-22.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMContactCell.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "Util.h"
#import "IMManager.h"
#import <ReactiveCocoa/UITableViewCell+RACSignalSupport.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIImageView+AFNetworking.h"

#define NAME_FONT_SIZE [UIFont boldSystemFontOfSize:18.f]

#define HEAD_IAMGE_HEIGHT 35

typedef void (^ContactCompleteBlock)(BOOL complete);

@interface IMContactCell() <XMPPStreamDelegate>

@property (nonatomic, strong) UIImageView *headView;
@property (nonatomic, strong) XMPPUserCoreDataStorageObject* contact;
@property (nonatomic, strong) RACSignal* loadImageSignal;
@property (nonatomic, strong) ContactCompleteBlock completeBlock;

@end

@implementation IMContactCell

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // head
        self.headView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, HEAD_IAMGE_HEIGHT, HEAD_IAMGE_HEIGHT)];
        self.headView.image = [UIImage imageNamed:@"head_s.png"];
        [self.contentView addSubview:self.headView];
        
        // name
        self.textLabel.font = NAME_FONT_SIZE;
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.highlightedTextColor = self.textLabel.textColor;
        
        // background color
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse
{
    [super prepareForReuse];
    self.headView.image = [UIImage imageNamed:@"head_s.png"];
}

- (RACSignal*)loadImageSignal
{
    if (_loadImageSignal == nil) {
        @weakify(self);
        _loadImageSignal = [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            @strongify(self);
            [[IMManager sharedManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
            NSData *photoData = [[[IMManager sharedManager] xmppvCardAvatarModule]
                                 photoDataForJID:self.contact.jid];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                @strongify(self);
                if (photoData != nil) {
                    self.headView.image = [UIImage imageWithData:photoData];
                }
            });
            
            if (photoData == nil) {
                self.completeBlock = ^(BOOL complete) {
                    if (complete) {
                        [subscriber sendNext:nil];
                        [subscriber sendCompleted];
                    }
                    else {
                        [subscriber sendError:nil];
                    }
                };
            }
            return [RACDisposable disposableWithBlock:^{
                [[IMManager sharedManager].xmppStream removeDelegate:self];
            }];
        }] takeUntil:self.rac_prepareForReuseSignal] replayLazily];
    }
    return _loadImageSignal;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat contentViewMarin = CELL_PADDING_10;
    CGFloat padding = CELL_PADDING_8;
    
    self.contentView.frame = CGRectMake(contentViewMarin, contentViewMarin,
                                        self.width - contentViewMarin * 2,
                                        self.height - contentViewMarin * 2);
    
    self.headView.left = 0.f;
    self.headView.top = 0.f;
    
    CGFloat textMaxWidth = self.contentView.width - self.headView.width - padding;
    
    // name
    self.textLabel.frame = CGRectMake(self.headView.right + padding, 0.f,
                                      textMaxWidth, self.textLabel.font.lineHeight);
    self.textLabel.centerY = self.contentView.height / 2;
    
#if 0
    if (self.contact.photo) {
        self.headView.image = self.contact.photo;
    }
    else {
        RACSignal * signal = [self loadImageSignal];
        [signal subscribeNext:^(id x) {
            //
        }];
    }
#endif
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdateCellWithObject:(id)object
{
    if ([object isKindOfClass:[XMPPUserCoreDataStorageObject class]]) {
        XMPPUserCoreDataStorageObject* o = (XMPPUserCoreDataStorageObject*)object;
        self.contact = o;
        self.textLabel.text = o.displayName;
        
        [self.headView setImageWithURL:nil//[NSURL URLWithString:HEAD_IMAGE(o.jid.user)]
                      placeholderImage:[UIImage imageNamed:@"head_s.png"]];
    }
    return YES;
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
    
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(ctx, CGRectMake(0, rect.size.height - 0.5f, rect.size.width, 0.5f));
	
	CGContextSetStrokeColorWithColor(ctx, [LINE_COLOR CGColor]);
	CGContextBeginPath(ctx);
	CGContextMoveToPoint(ctx, CELL_PADDING_10, rect.size.height - 0.5f);
	CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height - 0.5f);
	CGContextDrawPath(ctx, kCGPathStroke);
}

#pragma mark XMPPStreamDelegate

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    if([self.contact.jid isEqualToJID:iq.from]) {
        if (self.contact.photo) {
            self.headView.image = self.contact.photo;
        }
        else {
            self.headView.image = [UIImage imageNamed:@"head_s.png"];
        }
        if (self.completeBlock) {
            self.completeBlock(YES);
        }
        return YES;
    }
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error
{
    NSLog(@"%@", error);
    if (self.completeBlock) {
        self.completeBlock(NO);
    }
}

@end
