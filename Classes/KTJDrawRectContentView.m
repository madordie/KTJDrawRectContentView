//
//  KTJDrawRectContentLines.m
//  KTJDrawRect
//
//  Created by 孙继刚 on 16/4/16.
//  Copyright © 2016年 Madordie. All rights reserved.
//

#import "KTJDrawRectContentView.h"
//#import <POP.h>

@interface KTJDrawRectContentView ()

@property (nonatomic, assign) CGFloat multiple;

@end
@implementation KTJDrawRectContentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)setup {
    self.multiple = 1;
    self.selectIdx = NSNotFound;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];
}

- (void)contentElementFillVM:(KTJDrawRectContentViewModel *)viewModel {
    self.selectIdx = NSNotFound;
    if ([viewModel isKindOfClass:[KTJDrawRectContentViewModel class]]) {
        self.viewModel = viewModel;
    }
}
- (void)tapActionPoint:(CGPoint)touchPoint {
    if (self.viewModel.selectItemFrames) {
        [self.viewModel.selectItemFrames enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect frame = [obj CGRectValue];
            if (CGRectContainsPoint(frame, touchPoint)) {
                self.selectIdx = idx;
                *stop = YES;
            }
        }];
    } else {
        CGFloat speedX = self.bounds.size.width/self.viewModel.labels.count;
        self.selectIdx = touchPoint.x/speedX;
    }
}
- (void)tapAction:(UITapGestureRecognizer *)tap {
    CGPoint touchPoint = [tap locationInView:self];
    [self tapActionPoint:touchPoint];
}
- (void)panAction:(UIPanGestureRecognizer *)pan {
    CGPoint touchPoint = [pan locationInView:self];
    [self tapActionPoint:touchPoint];
}
#ifdef POP_POP_H
- (void)startAnimationWithDuration:(CFTimeInterval)duration {
    POPBasicAnimation *anim = [POPBasicAnimation animation];
    anim.duration = duration;
    
    POPAnimatableProperty * prop = [POPAnimatableProperty propertyWithName:@"content" initializer:^(POPMutableAnimatableProperty *prop) {
        [prop setReadBlock:^(id obj, CGFloat values[]) {
            values[0] = [obj multiple];
        }];
        [prop setWriteBlock:^(id obj, const CGFloat values[]) {
            [obj setMultiple:values[0]];
        }];
    }];
    anim.property = prop;
    anim.fromValue = @(0.0);
    anim.toValue = @(1.0);
    [self pop_addAnimation:anim forKey:@"contentAnim"];
}
#endif

#pragma mark -  setter/getter

- (void)setSelectIdx:(NSInteger)selectIdx {
    NSInteger oldValue = _selectIdx;
    _selectIdx = selectIdx;
    if (oldValue != selectIdx
        && [self.delegate respondsToSelector:@selector(contentView:selectIdx:)]
        && [self.delegate contentView:self selectIdx:selectIdx]) {
        if (_selectIdx != NSNotFound || _selectIdx != oldValue) {
            [self setNeedsDisplay];
        }
    }
}

- (void)setViewModel:(KTJDrawRectContentViewModel *)viewModel {
    _viewModel = viewModel;
    if (_viewModel) {
        [self setNeedsDisplay];
    }
}
- (void)setMultiple:(CGFloat)multiple {
    if (_multiple != multiple) {
        _multiple = multiple;
        [self setNeedsDisplayInRect:self.bounds];
    }
}

- (void)drawRect:(CGRect)rect {
    
    [self.viewModel.dottedLines enumerateObjectsUsingBlock:^(KTJDrawRectContentDottedLineModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self drawDottedLines:obj];
    }];
    
    [self.viewModel.rectangles enumerateObjectsUsingBlock:^(KTJDrawRectContentRectangleModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self drawRectangles:obj];
    }];

    [self.viewModel.lines enumerateObjectsUsingBlock:^(KTJDrawRectContentLineModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self drawPointAndLines:obj];
    }];
    
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.viewModel.labels enumerateObjectsUsingBlock:^(KTJDrawRectContentLabelModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self drawLabels:obj forContextRef:context idx:idx];
    }];
    
    if (self.selectIdx != NSNotFound
        && self.viewModel.rectangles.count == 0
        && self.viewModel.selectLines.count>self.selectIdx
        && self.selectIdx>=0) {
        
        [self drawRealLine:self.viewModel.selectLines[self.selectIdx]];
    }
}

- (void)drawPointAndLines:(KTJDrawRectContentLineModel *)lineModel {
    
    NSArray<NSValue *> *points = lineModel.toPoints;
    
    [points enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint fromPoint = [obj CGPointValue];
        fromPoint.x = lineModel.basePoint.x + fromPoint.x;
        fromPoint.y = lineModel.basePoint.y + fromPoint.y*self.multiple;
        
        {
            //// Oval Drawing   from point
            UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(fromPoint.x-lineModel.width, fromPoint.y-lineModel.width, lineModel.width*2, lineModel.width*2)];
            [lineModel.fillColor setStroke];
            ovalPath.lineWidth = lineModel.width;
            [ovalPath stroke];
        }
        
        if (idx+1 < points.count) {
            CGPoint toPoint = [points[idx+1] CGPointValue];
            toPoint.x = lineModel.basePoint.x + toPoint.x;
            toPoint.y = lineModel.basePoint.y + toPoint.y*self.multiple;
            
            //  避开半径 可以计算出来。。。  会增加动画的负担。。 4个平方 2个开方运算。
            {
                CGFloat m = fabs((fromPoint.y-toPoint.y)/(fromPoint.x-toPoint.x));
                CGFloat xx = lineModel.width/sqrtf(m*m+1);
                CGFloat yy = xx*m;
                xx *= toPoint.x>fromPoint.x?1:-1;
                yy *= toPoint.y>fromPoint.y?1:-1;
                fromPoint.x += xx;
                fromPoint.y += yy;
                toPoint.x -= xx;
                toPoint.y -= yy;
            }
            
            //// Bezier Drawing     from - to line
            UIBezierPath* bezierPath = [UIBezierPath bezierPath];
            [bezierPath moveToPoint: CGPointMake(fromPoint.x, fromPoint.y)];
            [bezierPath addLineToPoint: toPoint];
            bezierPath.miterLimit = 10;
            
            bezierPath.lineCapStyle = kCGLineCapSquare;
            
            [lineModel.fillColor setStroke];
            bezierPath.lineWidth = lineModel.width;
            [bezierPath stroke];
        }
        
//        {
//            //// Oval Drawing   from point center
//            UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(fromPoint.x-lineModel.width/4, fromPoint.y-lineModel.width/4, lineModel.width/2, lineModel.width/2)];
//            [[UIColor whiteColor] setStroke];
//            ovalPath.lineWidth = lineModel.width/2;
//            [ovalPath stroke];
//        }
    }];
}

- (void)drawRectangles:(KTJDrawRectContentRectangleModel *)rectangle {
    
    NSArray<NSValue *> *bounds = rectangle.toRectangleBounds;
    [bounds enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect frame = [obj CGRectValue];
        frame.origin.x = rectangle.baseBound.origin.x + frame.origin.x;
        frame.origin.y = rectangle.baseBound.origin.y + frame.origin.y;
        frame.size.height = rectangle.baseBound.size.height + frame.size.height*self.multiple;
        frame.size.width = rectangle.baseBound.size.width + frame.size.width;
        frame.origin.x -= frame.size.width/2;
        
        {
            //// Rectangle Drawing
            UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: frame];
            [self.selectIdx==idx?rectangle.selectColor:rectangle.fillColor setFill];
            [rectanglePath fill];
        }
    }];
}
- (CGRect)drawLabels:(KTJDrawRectContentLabelModel *)labelModel forContextRef:(CGContextRef)context idx:(NSInteger)idx {

    //// Label Drawing
    CGRect labelRect = labelModel.frame;
    {
        NSString* textContent = labelModel.text;
        NSMutableParagraphStyle* labelStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
        labelStyle.alignment = labelModel.textAlignment;
        
        NSDictionary* labelFontAttributes = @{NSFontAttributeName: labelModel.font, NSForegroundColorAttributeName: self.selectIdx==idx?labelModel.selectColor:labelModel.fillColor, NSParagraphStyleAttributeName: labelStyle};
        
        CGFloat labelTextHeight = [textContent boundingRectWithSize: CGSizeMake(labelRect.size.width, INFINITY)  options: NSStringDrawingUsesLineFragmentOrigin attributes: labelFontAttributes context: nil].size.height;
        CGContextSaveGState(context);
        //  auto show all.
        labelRect.size.height = labelTextHeight;
        
        CGContextClipToRect(context, labelRect);
        [textContent drawInRect: CGRectMake(CGRectGetMinX(labelRect), CGRectGetMinY(labelRect) + (CGRectGetHeight(labelRect) - labelTextHeight) / 2, CGRectGetWidth(labelRect), labelTextHeight) withAttributes: labelFontAttributes];
        CGContextRestoreGState(context);
    }
    return labelRect;
}

- (void)drawDottedLines:(KTJDrawRectContentDottedLineModel *)dottedLine {
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: dottedLine.fromPoint];
    [bezierPath addLineToPoint: dottedLine.toPoint];
    bezierPath.lineCapStyle = kCGLineCapSquare;
    
    [dottedLine.fillColor setStroke];
    bezierPath.lineWidth = dottedLine.width;
    CGFloat bezierPattern[] = {2, 2};
    [bezierPath setLineDash: bezierPattern count: 2 phase: 0];
    [bezierPath stroke];
}

- (void)drawRealLine:(KTJDrawRectContentRealLineModel *)realLineModel {
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: realLineModel.fromPoint];
    [bezierPath addLineToPoint: realLineModel.toPoint];
    bezierPath.lineCapStyle = kCGLineCapSquare;
    
    [realLineModel.fillColor setStroke];
    bezierPath.lineWidth = realLineModel.width;
    [bezierPath stroke];
}
@end

@implementation KTJDrawRectContentViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

@end

@implementation KTJDrawRectContentLineModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _width = 3;
        _fillColor = [UIColor blackColor];
        _basePoint = CGPointZero;
    }
    return self;
}

@end

@implementation KTJDrawRectContentRectangleModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fillColor = [UIColor grayColor];
        _baseBound = CGRectZero;
        _selectColor = [UIColor grayColor];
    }
    return self;
}

@end

@implementation KTJDrawRectContentLabelModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fillColor = [UIColor grayColor];
        _selectColor = [UIColor grayColor];
        _font = [UIFont systemFontOfSize:11];
        _textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

@end

@implementation KTJDrawRectContentDottedLineModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fillColor = [UIColor grayColor];
        _width = 0.5;
    }
    return self;
}

@end

@implementation KTJDrawRectContentRealLineModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fillColor = [UIColor grayColor];
        _width = 0.75;
    }
    return self;
}

@end