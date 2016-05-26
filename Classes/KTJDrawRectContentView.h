//
//  KTJDrawRectContentLines.h
//  KTJDrawRect
//
//  Created by 孙继刚 on 16/4/16.
//  Copyright © 2016年 Madordie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KTJDrawRectContentViewModel;
@protocol KTJDrawRectContentViewDelegate;
@interface KTJDrawRectContentView : UIView

/**
 *  选中的下标
 */
@property (nonatomic, assign) NSInteger selectIdx;

/**
 *  格式化完成的数据源
 */
@property (nonatomic, strong) KTJDrawRectContentViewModel *viewModel;

@property (nonatomic, weak) id<KTJDrawRectContentViewDelegate> delegate;

/**
 *  填充数据源
 *
 *  @param viewModel 格式化过的数据源
 */
- (void)contentElementFillVM:(KTJDrawRectContentViewModel *)viewModel;

@end

@protocol KTJDrawRectContentViewDelegate <NSObject>
/**
 *  选中某个数据源
 *
 *  @param contentView contentView
 *  @param selectidx   选中下标 NSNotFound为取消
 *
 *  @return 是否能成功操作
 */
- (BOOL)contentView:(KTJDrawRectContentView *)contentView selectIdx:(NSInteger)selectidx;

@end


@class KTJDrawRectContentLineModel, KTJDrawRectContentRectangleModel;
@class KTJDrawRectContentLabelModel, KTJDrawRectContentDottedLineModel;
@class KTJDrawRectContentRealLineModel;
@interface KTJDrawRectContentViewModel : NSObject

#pragma mark - 数据源

@property (nonatomic, copy) NSArray<KTJDrawRectContentLineModel *> *lines;

@property (nonatomic, copy) NSArray<KTJDrawRectContentRectangleModel *> *rectangles;

@property (nonatomic, copy) NSArray<KTJDrawRectContentLabelModel *> *labels;

@property (nonatomic, copy) NSArray<KTJDrawRectContentDottedLineModel *> *dottedLines;

@property (nonatomic, copy) NSArray<KTJDrawRectContentRealLineModel *> *selectLines;

@property (nonatomic, copy) NSArray<NSValue *> *selectItemFrames;

@end

@interface KTJDrawRectContentLineModel : NSObject

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic, assign) CGPoint basePoint;
@property (nonatomic, copy) NSArray<NSValue *> *toPoints;

@end

@interface KTJDrawRectContentRectangleModel : NSObject

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *selectColor;

@property (nonatomic, assign) CGRect baseBound;
@property (nonatomic, copy) NSArray<NSValue *> *toRectangleBounds;

@end

@interface KTJDrawRectContentLabelModel : NSObject

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *selectColor;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, assign) NSTextAlignment textAlignment;

@property (nonatomic, copy) NSString *text;

@property (nonatomic, assign) CGRect frame;

@end

@interface KTJDrawRectContentDottedLineModel : NSObject

@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGPoint fromPoint;

@property (nonatomic, assign) CGPoint toPoint;

@end

@interface KTJDrawRectContentRealLineModel : NSObject

@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGPoint fromPoint;

@property (nonatomic, assign) CGPoint toPoint;

@end