//
//  IMEmotionMainView.m
//  JLWeChat
//
//  Created by jimney on 13-3-5.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "IMEmotionMainView.h"
#import "IMEmotionEntity.h"
#import "IMEmotionManager.h"

#define LEFT_MARGIN 16
#define TOP_MARGIN 20
#define ROW_COUNT 3
#define COLUMN_COUNT 7
#define ROW_SPACE 13 //(320 - LEFT_MARGIN * 2 - FACE_WIDTH * COLUMN_COUNT) / 6
#define COLUMN_SPACE 20
#define FACE_WIDTH 30
#define PAGE_CONTROL_HEIGHT 20

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - IMEmotionPageView
///////////////////////////////////////////////////////////////////////////////////////////////////

@interface IMEmotionPageView : UIView <NIPagingScrollViewPage>

@end

@implementation IMEmotionPageView
@synthesize pageIndex = _pageIndex;

- (void)setPageIndex:(NSInteger)pageIndex {
    _pageIndex = pageIndex;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - IMEmotionPageView
///////////////////////////////////////////////////////////////////////////////////////////////////

@interface IMEmotionMainView()<NIPagingScrollViewDataSource, NIPagingScrollViewDelegate>
@property (nonatomic, strong) NSArray* emotionArray;
@property (nonatomic, strong) NIPagingScrollView* scrollView;
@property (nonatomic, strong) UIPageControl* pageControl;
@property (nonatomic, strong) UIButton *sendBtn;
@end

@implementation IMEmotionMainView

//////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.emotionArray = [[IMEmotionManager sharedManager] emotionsArray];
        self.backgroundColor = RGBCOLOR(244, 244, 244);
        
        _scrollView = [[NIPagingScrollView alloc] initWithFrame:self.bounds];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delegate = self;
        _scrollView.dataSource = self;
        [self addSubview:_scrollView];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        [_pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
        _pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        [self addSubview:_pageControl];
        
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:[UIColor blueColor]];
        [_sendBtn addTarget:self action:@selector(sendAction)
           forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendBtn];
        
        [self.scrollView reloadData];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.pageControl.frame = CGRectMake(0.f, self.bounds.size.height - PAGE_CONTROL_HEIGHT * 3,
                                        self.bounds.size.width, PAGE_CONTROL_HEIGHT);
    self.sendBtn.frame = CGRectMake(0.f, 0.f, 60.f, 33.f);
    self.sendBtn.right = self.width;
    self.sendBtn.bottom = self.height;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)sendAction
{
    if (self.emotionDelegate && [self.emotionDelegate respondsToSelector:@selector(didEmotionViewSendAction)]) {
        [self.emotionDelegate didEmotionViewSendAction];
    }
}

- (BOOL)checkIsLastPostionInPageWithRowIndex:(NSInteger)rowIndex columnIndex:(NSInteger)columnIndex
{
    if (ROW_COUNT - 1 == rowIndex && COLUMN_COUNT - 1 == columnIndex) {
        return YES;
    }
    return NO;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NIScrollViewDataSource
//////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView
{
    int numInPage = ROW_COUNT * COLUMN_COUNT;
	int pageNum = ceil((float)_emotionArray.count / numInPage);
	[_pageControl setNumberOfPages:pageNum];
	return pageNum;
}

- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex
{
	int row = ROW_COUNT;
	int column = COLUMN_COUNT;
	
    IMEmotionPageView *pageView = (IMEmotionPageView *)[pagingScrollView dequeueReusablePageWithIdentifier:@"IMEmotionPageView"];
	if (pageView == nil) {
		pageView = [[IMEmotionPageView alloc] initWithFrame:CGRectMake(0, 0, column * (FACE_WIDTH + ROW_SPACE),
                                                             row * (FACE_WIDTH + COLUMN_SPACE))];
		pageView.backgroundColor = [UIColor clearColor];
		
		UITapGestureRecognizer* gest = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(faceTaped:)];
		[pageView addGestureRecognizer:gest];
	}
    
    NSInteger previousPageTotalCount = 0;
    NSInteger postionIndex = 0;
    NSInteger previousDeleteBtnCount = 0;
    NSInteger emtionIndex = 0;
	for (int i = 0; i < row; i++) {
		for (int j = 0; j < column; j++) {
            // 最后一个添加删除按钮
            if ([self checkIsLastPostionInPageWithRowIndex:i columnIndex:j]) {
                break;
            }
            previousPageTotalCount = row * column * pageIndex;
            previousDeleteBtnCount = pageIndex;
            postionIndex = i * column + j;
            
            emtionIndex = previousPageTotalCount + postionIndex - previousDeleteBtnCount;

			UIImageView* imgView = (UIImageView*)[pageView viewWithTag:1000 + postionIndex];
			if (emtionIndex < _emotionArray.count) {
				IMEmotionEntity* entity = [_emotionArray objectAtIndex:emtionIndex];
                
				if (imgView == nil) {
					imgView = [[UIImageView alloc] initWithFrame:
                               CGRectMake(j * (FACE_WIDTH + ROW_SPACE) + LEFT_MARGIN,
                                          i * (FACE_WIDTH + COLUMN_SPACE) + TOP_MARGIN,
                                          FACE_WIDTH, FACE_WIDTH)];
					imgView.tag = 1000 + postionIndex;
					imgView.backgroundColor = [UIColor clearColor];
                    imgView.userInteractionEnabled = YES;
					[pageView addSubview:imgView];
				}
				imgView.image = [UIImage imageNamed:entity.imageName];
			}
			else {
				[imgView removeFromSuperview];
			}
		}
	}
    
    // 添加删除按钮
    UIButton *deleteBtn = (UIButton*)[pageView viewWithTag:2000 + pageIndex];
	if (!deleteBtn) {
        deleteBtn = [[UIButton alloc] initWithFrame:
                     CGRectMake((column - 1) * (FACE_WIDTH + ROW_SPACE) + LEFT_MARGIN,
                                (row - 1) * (FACE_WIDTH + COLUMN_SPACE) + TOP_MARGIN,
                                FACE_WIDTH, FACE_WIDTH)];
        [deleteBtn setImage:[UIImage imageNamed:@"DeleteEmoticonBtn"] forState:UIControlStateNormal];
        [deleteBtn setImage:[UIImage imageNamed:@"DeleteEmoticonBtnHL"] forState:UIControlStateHighlighted];
        [deleteBtn addTarget:self action:@selector(deleteAction)
            forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.tag = 2000 + pageIndex;
        [pageView addSubview:deleteBtn];
    }
	return pageView;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NIPagingScrollViewDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)pagingScrollViewDidChangePages:(NIPagingScrollView *)pagingScrollView
{
    self.pageControl.currentPage = pagingScrollView.centerPageIndex;
}

- (void)pageChanged:(id)sender
{
	[self.scrollView setCenterPageIndex:self.pageControl.currentPage];
}

- (void)deleteAction
{
    if (self.emotionDelegate && [self.emotionDelegate respondsToSelector:@selector(didEmotionViewDeleteAction)]) {
        [self.emotionDelegate didEmotionViewDeleteAction];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)faceTaped:(UIGestureRecognizer*)gest
{
	CGPoint point = [gest locationInView:_scrollView.centerPageView];
    
    int row = ROW_COUNT;
    int column = COLUMN_COUNT;
    
    // 选择表情区域需要往右上角移动半个space
    CGPoint offset = CGPointMake(ROW_SPACE / 2.f, COLUMN_SPACE / 2.f);
    CGRect effectRect = CGRectMake(LEFT_MARGIN - offset.x, TOP_MARGIN - offset.y,
                                   column * (FACE_WIDTH + ROW_SPACE), row * (FACE_WIDTH + COLUMN_SPACE));

    if (CGRectContainsPoint(effectRect, point)) {
        NSInteger currentRow = floor((point.y + offset.y - TOP_MARGIN) / (FACE_WIDTH + COLUMN_SPACE));
        NSInteger currentcolumn = floor((point.x + offset.x - LEFT_MARGIN) / (FACE_WIDTH + ROW_SPACE));
        
#ifdef DEBUG
        NSLog(@"row = %d, column = %d", currentRow, currentcolumn);
#endif
        if (![self checkIsLastPostionInPageWithRowIndex:currentRow columnIndex:currentcolumn]) {
            
            NSInteger previousPageTotalCount = row * column * _scrollView.centerPageIndex;
            NSInteger index = previousPageTotalCount + column * currentRow + currentcolumn;
            NSInteger previousDeleteBtnCount = _scrollView.centerPageIndex;
            NSInteger realIndex = index - previousDeleteBtnCount;
            
            if (realIndex < _emotionArray.count) {
                if ([self.emotionDelegate respondsToSelector:@selector(emotionSelectedWithName:)]) {
                    IMEmotionEntity *emtionEntity = [_emotionArray objectAtIndex:realIndex];
                    [self.emotionDelegate emotionSelectedWithName:[emtionEntity name]];
                }
            }
        }
    }
}

@end
