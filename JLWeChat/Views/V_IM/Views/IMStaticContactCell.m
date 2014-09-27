//
//  MKStaticContactCell.m
//  JLWeChat
//
//  Created by jimneylee on 14-5-22.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMStaticContactCell.h"
#import "JSCustomBadge.h"

#define NAME_FONT_SIZE [UIFont boldSystemFontOfSize:18.f]

#define HEAD_IAMGE_HEIGHT 35

typedef void (^ContactCompleteBlock)(BOOL complete);

@interface IMStaticContactCell()

@property (nonatomic, strong) JSCustomBadge *badgeView;
@property (nonatomic, strong) UIImageView *headView;

@end

@implementation IMStaticContactCell

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // head
        self.headView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, HEAD_IAMGE_HEIGHT, HEAD_IAMGE_HEIGHT)];
        self.headView.image = [UIImage imageNamed:@"icon_new_friends.png"];
        [self.contentView addSubview:self.headView];
        
        // badge
        self.badgeView = [[JSCustomBadge alloc] initWithFrame:CGRectZero];
        self.badgeView.badgeTextColor = [UIColor redColor];
        self.badgeView.hidden = YES;
        [self.contentView addSubview:self.badgeView];
        
        // name
        self.textLabel.font = NAME_FONT_SIZE;
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.highlightedTextColor = self.textLabel.textColor;
        
        // background color
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.badgeView.backgroundColor = [UIColor clearColor];

        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse
{
    [super prepareForReuse];
    // TODO: 按类型设置头像

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
    
    [self.badgeView sizeToFit];
    self.badgeView.center = CGPointMake(self.headView.right - CELL_PADDING_2,
                                        self.headView.top + CELL_PADDING_2);
    self.badgeView.right = self.contentView.width - CELL_PADDING_10 * 2;
    self.badgeView.centerY = self.contentView.height / 2;
    
    CGFloat textMaxWidth = self.contentView.width - self.headView.width - padding;
    
    // name
    self.textLabel.frame = CGRectMake(self.headView.right + padding, 0.f,
                                      textMaxWidth, self.textLabel.font.lineHeight);
    self.textLabel.centerY = self.contentView.height / 2;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdateCellWithObject:(id)object unsubscribedCountNum:(NSNumber *)unsubscribedCountNum
{
    if ([object isKindOfClass:[NSString class]]) {
        self.textLabel.text = object;
        
        if ([unsubscribedCountNum intValue] > 0) {
            self.badgeView.hidden = NO;
            self.badgeView.badgeText = unsubscribedCountNum.stringValue;
        }
        else {
            self.badgeView.hidden = YES;
        }
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
