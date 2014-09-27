//
//  MKSearchChatContactCell.m
//  JLWeChat
//
//  Created by jimneylee on 14-5-22.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMSearchChatContactCell.h"
#import "XMPPMessageArchiving_Contact_CoreDataObject.h"
#import "XMPPMessageArchiving_Contact_CoreDataObject+RecentContact.h"
#import "NSDate+IM.h"
#import "IMManager.h"
#import "IMChatMessageEntityFactory.h"
#import "UIImageView+AFNetworking.h"

#define NAME_FONT_SIZE [UIFont systemFontOfSize:20.f]
#define MESSAGE_FONT_SIZE [UIFont systemFontOfSize:14.f]

#define HEAD_IAMGE_HEIGHT 35

@interface IMSearchChatContactCell()

@property (nonatomic, strong) UIImageView *headView;

@property (nonatomic, strong) XMPPMessageArchiving_Contact_CoreDataObject* contact;

@end

@implementation IMSearchChatContactCell

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
        
        // message
        self.detailTextLabel.font = MESSAGE_FONT_SIZE;
        self.detailTextLabel.textColor = [UIColor darkGrayColor];
        self.detailTextLabel.highlightedTextColor = self.detailTextLabel.textColor;
        
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
    CGFloat nameWidth = (textMaxWidth * 2 ) / 3;
    
    // name
    self.textLabel.frame = CGRectMake(self.headView.right + padding, self.headView.top,
                                      nameWidth, self.textLabel.font.lineHeight);
    
    // message
    self.detailTextLabel.frame = CGRectMake(self.textLabel.left, self.textLabel.bottom,
                                            textMaxWidth, self.detailTextLabel.font.lineHeight);
    
    // head data
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        NSData *photoData = [[[IMManager sharedManager] xmppvCardAvatarModule]
                             photoDataForJID:self.contact.bareJid];
        if (photoData != nil)
            self.headView.image = [UIImage imageWithData:photoData];
        else
            self.headView.image = [UIImage imageNamed:@"head_s.png"];
    });
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdateCellWithObject:(id)object
{
    if ([object isKindOfClass:[XMPPMessageArchiving_Contact_CoreDataObject class]]) {
        XMPPMessageArchiving_Contact_CoreDataObject* o = (XMPPMessageArchiving_Contact_CoreDataObject*)object;
        self.contact = o;
        self.textLabel.text = o.bareJid.user;
        self.detailTextLabel.text = o.chatRecord;
        [self.headView setImageWithURL:nil//[NSURL URLWithString:HEAD_IMAGE(o.bareJid.user)]
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

@end
