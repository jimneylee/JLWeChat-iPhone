//
//  IMChatShareMoreView.m
//  JLWeChat
//
//  Created by Lee jimney on 5/24/14.
//  Copyright (c) 2014 jimneylee. All rights reserved.
//

#import "IMChatShareMoreView.h"

#define PAGE_MAX_COUNT 8
#define LAUNCHER_BUTTON_WIDTH 64
#define LAUNCHER_LABEL_HEIGHT 20

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - IMChatShareButtonView
///////////////////////////////////////////////////////////////////////////////////////////////////

@interface IMChatShareButtonView : NILauncherButtonView

@end

@implementation IMChatShareButtonView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
        
        [self.button setBackgroundImage:[UIImage imageNamed:@"sharemore_app_markbg"]
                               forState:UIControlStateNormal];
        [self.button setBackgroundImage:[UIImage imageNamed:@"sharemore_app_markbg_HL"]
                               forState:UIControlStateHighlighted];
        self.backgroundColor = [UIColor clearColor];
        self.button.backgroundColor = [UIColor clearColor];
        self.label.backgroundColor = [UIColor clearColor];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.label.font = [UIFont systemFontOfSize:12.f];
    self.label.textColor = [UIColor darkGrayColor];
    
//    CGFloat kSeperateSpace = 10.f;
//    self.label.top = self.label.top + kSeperateSpace;
    
    self.button.frame = CGRectMake(0.f, 0.f, LAUNCHER_BUTTON_WIDTH, LAUNCHER_BUTTON_WIDTH);
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - IMChatShareButtonObject
///////////////////////////////////////////////////////////////////////////////////////////////////

@interface IMChatShareButtonObject : NILauncherViewObject

@end

@implementation IMChatShareButtonObject

- (Class)buttonViewClass
{
    return [IMChatShareButtonView class];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - IMChatShareMoreView
///////////////////////////////////////////////////////////////////////////////////////////////////

@interface IMChatShareMoreView()<NILauncherViewModelDelegate, NILauncherDelegate>

@property (nonatomic, readwrite, retain) NILauncherViewModel* model;

@end

@implementation IMChatShareMoreView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSMutableArray *itemPages = [NSMutableArray arrayWithCapacity:2];
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:10];
        
        NILauncherViewObject *item = nil;
        item = [[IMChatShareButtonObject alloc] initWithTitle:@"照片"
                                                        image:[UIImage imageNamed:@"sharemore_pic"]];
        [items addObject:item];
        
        item = [[IMChatShareButtonObject alloc] initWithTitle:@"拍摄"
                                                        image:[UIImage imageNamed:@"sharemore_video"]];
        [items addObject:item];
#if 0
        item = [[IMChatShareButtonObject alloc] initWithTitle:@"位置"
                                                        image:[UIImage imageNamed:@"sharemore_location"]];
        [items addObject:item];
#endif
        [itemPages addObject:items];
        
        self.backgroundColor = RGBCOLOR(244, 244, 244);
        self.contentInsetForPages = UIEdgeInsetsMake(10.f, 0.f, 0.f, 0.f);
        self.buttonSize = CGSizeMake(LAUNCHER_BUTTON_WIDTH, LAUNCHER_BUTTON_WIDTH + LAUNCHER_LABEL_HEIGHT);
        self.numberOfRows = 2;
        self.numberOfColumns = 4;
        _model = [[NILauncherViewModel alloc] initWithArrayOfPages:itemPages delegate:self];
        self.dataSource = self.model;
        self.delegate = self;
        [self reloadData];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NILauncherViewModelDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)launcherViewModel:(NILauncherViewModel *)launcherViewModel
      configureButtonView:(UIView<NILauncherButtonView> *)buttonView
          forLauncherView:(NILauncherView *)launcherView
                pageIndex:(NSInteger)pageIndex
              buttonIndex:(NSInteger)buttonIndex
                   object:(id<NILauncherViewObject>)object
{

    NILauncherButtonView* launcherButtonView = (NILauncherButtonView *)buttonView;

}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NILauncherDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)launcherView:(NILauncherView *)launcherView
 didSelectItemOnPage:(NSInteger)page
             atIndex:(NSInteger)index
{
    NSInteger realIndex = PAGE_MAX_COUNT * page + index;
    switch (realIndex) {
        case 0:
        {
            // 图片
            if (self.shareMoreDelegate && [self.shareMoreDelegate respondsToSelector:@selector(didPickPhotoFromLibrary)]) {
                [self.shareMoreDelegate didPickPhotoFromLibrary];
            }
            break;
        }
        case 1:
        {
            // 拍照
            if (self.shareMoreDelegate && [self.shareMoreDelegate respondsToSelector:@selector(didPickPhotoFromCamera)]) {
                [self.shareMoreDelegate didPickPhotoFromCamera];
            }
            break;
        }
        default:
            break;
    }
}

@end
