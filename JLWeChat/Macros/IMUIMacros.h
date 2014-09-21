//
//  IMUIMacros.h
//  JLIM4iPhone
//
//  Created by jimneylee on 14-5-19.
//  Copyright (c) 2014年 taocz. All rights reserved.
//

#ifndef JLIM4iPhone_IMUIMacros_h
#define JLIM4iPhone_IMUIMacros_h

#define APP_MAIN_COLOR RGBCOLOR(45.f, 184.f, 173.f)

// 搜索框激活时背景色
#define SEARCH_ACTIVE_BG_COLOR RGBCOLOR(201, 201, 206)
#define TABLEVIEW_GROUP_BG_COLOR RGBCOLOR(240, 239, 246)

// Cell布局
#define CELL_PADDING_10 10
#define CELL_PADDING_8 8
#define CELL_PADDING_6 6
#define CELL_PADDING_4 4
#define CELL_PADDING_2 2

#define LINE_COLOR RGBCOLOR(240, 240, 240)

// 消息页面Cell固定高度
#define MESSAGE_MAIN_ROW_HEIGHT 68.f

// 通讯录页面Cell固定高度
#define ADDRESS_BOOK_ROW_HEIGHT 55.f

// group头部高度
#define GROUP_SECTION_HEADER_HEIGHT 20.f

// 朋友圈回复tableview的width
#define COMMENT_LIST_VIEW_Width 250

#define GetUserDefaults(xx)   [[NSUserDefaults standardUserDefaults] objectForKey:xx]

// 拍照分享图片最多张数
#define PHOTO_PICK_MAX_COUNT 9

#endif
