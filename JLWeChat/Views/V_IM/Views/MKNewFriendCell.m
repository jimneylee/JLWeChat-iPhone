//
//  MKContactCell.m
//  MeiKeMeiShi
//
//  Created by jimneylee on 14-5-22.
//  Copyright (c) 2014年 john. All rights reserved.
//

#import "MKNewFriendCell.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "Util.h"
#import "MKIMManager.h"
#import "MKNewFriendManagedObject.h"

#define NAME_FONT_SIZE [UIFont boldSystemFontOfSize:18.f]

#define HEAD_IAMGE_HEIGHT 35

@interface MKNewFriendCell() <XMPPStreamDelegate>

@property (nonatomic, strong) UIImageView *headView;
@property (nonatomic, strong) MKNewFriendManagedObject* user;
@property (nonatomic, strong) RACSignal* loadImageSignal;

@end

@implementation MKNewFriendCell

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
        
        self.actionBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 60.f, 25.f)];
        self.actionBtn.backgroundColor = APP_MAIN_COLOR;
        [self.actionBtn.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
//        [self.actionBtn addTarget:self action:@selector(tapBtnAction)
//                 forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.actionBtn];
        self.accessoryView = self.actionBtn;
        
        // name
        self.textLabel.font = NAME_FONT_SIZE;
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.highlightedTextColor = self.textLabel.textColor;
        
        // background color
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
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

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat contentViewMarin = CELL_PADDING_10;
    CGFloat padding = CELL_PADDING_6;
    
    self.contentView.frame = CGRectMake(contentViewMarin, contentViewMarin,
                                        self.width - contentViewMarin * 2,
                                        self.height - contentViewMarin * 2);
    
    self.headView.left = 0.f;
    self.headView.top = 0.f;
    
    CGFloat textMaxWidth = self.contentView.width - self.headView.width - padding;
    
    // name
    self.textLabel.frame = CGRectMake(self.headView.right + padding, self.headView.top,
                                      textMaxWidth, self.textLabel.font.lineHeight);
    self.detailTextLabel.frame = CGRectMake(self.textLabel.left, self.textLabel.bottom,
                                            textMaxWidth, self.detailTextLabel.font.lineHeight);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdateCellWithObject:(id)object
{
#if 0
    if ([object isKindOfClass:[XMPPUserCoreDataStorageObject class]]) {
        XMPPUserCoreDataStorageObject* o = (XMPPUserCoreDataStorageObject*)object;
        self.contact = o;
        self.textLabel.text = o.displayName;
        self.detailTextLabel.text = @"等待验证";
    }
#else
    //if ([object isKindOfClass:[MKNewFriendManagedObject class]])
    {
        MKNewFriendManagedObject* o = (MKNewFriendManagedObject*)object;
        self.user = o;
        self.textLabel.text = o.nickname;
        
        if ([o.typeNum intValue] == MKNewFriendSubscribeType_SubscribeFromOther) {
            self.detailTextLabel.text = @"请求添加你为朋友";
            [self.actionBtn setTitle:@"接受" forState:UIControlStateNormal];
            self.actionBtn.backgroundColor = APP_MAIN_COLOR;
            self.actionBtn.enabled = YES;
        }
        else if ([o.typeNum intValue] == MKNewFriendSubscribeType_HasAddedSubscribeFromOther) {
            self.detailTextLabel.text = @"请求添加你为朋友";
            [self.actionBtn setTitle:@"已添加" forState:UIControlStateNormal];
            self.actionBtn.backgroundColor = [UIColor lightGrayColor];
            self.actionBtn.enabled = NO;
        }
        if ([o.typeNum intValue] == MKNewFriendSubscribeType_HasAddedSubscribeFromMe) {
            self.detailTextLabel.text = @"已发出邀请为朋友";
            [self.actionBtn setTitle:@"已邀请" forState:UIControlStateNormal];
            self.actionBtn.backgroundColor = [UIColor lightGrayColor];
            self.actionBtn.enabled = NO;
        }
        else if ([o.typeNum intValue] == MKNewFriendSubscribeType_HasAddedSubscribeFromMe) {
            self.detailTextLabel.text = @"已发出邀请为朋友";
            [self.actionBtn setTitle:@"已添加" forState:UIControlStateNormal];
            self.actionBtn.backgroundColor = [UIColor lightGrayColor];
            self.actionBtn.enabled = NO;
        }
    }
#endif
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

//- (void)tapBtnAction
//{
//    if (self.user.subscribeType == MKNewFriendSubscribeType_SubscribeFromOthers) {
//        [self acceptPresenceSubscriptionRequestFrom:[XMPPJID jidWithString:self.user.bareJidStr]];
//    }
//}
//
//- (void)acceptPresenceSubscriptionRequestFrom:(XMPPJID *)jid
//{
//	// Send presence response
//	//
//	// <presence to="bareJID" type="subscribed"/>
//	
//	XMPPPresence *presence = [XMPPPresence presenceWithType:@"subscribed" to:[jid bareJID]];
//	[[MKIMManager sharedManager].xmppStream sendElement:presence];
//	
//	// Add optionally add user to our roster
//    [[MKIMManager sharedManager].xmppRoster addUser:jid withNickname:self.user.nickname];
//}

@end
