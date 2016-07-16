//
//  UuusPieChartView.m
//  UuusPieChartView
//
//  Created by 范炜佳 on 16/7/2016.
//  Copyright © 2016 com.uuus. All rights reserved.
//

#define UuusPieChartOuterRadius CGRectGetWidth(self.bounds) / 2.0
#define UuusPieChartInnerRadius CGRectGetWidth(self.bounds) / 166.0 * 33.0
#define UuusCenterPoint         CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)) // middle X Y
#define UuusPieChartRingsRadius self.innerRadius + (self.outerRadius - self.innerRadius) / 2.0

const static double kWidthOfSeparateLine = 3.0;
const static double kRadiusOfHandlesImage = 13.0;

#import "UuusPieChartView.h"
#import "UuusPieChartModel.h"
#import "UuusPieChartItem.h"

@interface UuusPieChartView ()

// Radius of pie chart path.
@property (nonatomic) double ringsRadius;

// View model.
@property (nonatomic, strong) UuusPieChartModel *model;

// Pie chart layer container.
@property (nonatomic, strong) CALayer *layerContainer;

// True means update layer with animations.
@property (nonatomic) BOOL updateAnimated;

@property (nonatomic, strong) NSArray<UIImageView *> *handlesImageViewArray;

// Value -1 means not sure touches index.
@property (nonatomic) long touchesIndex;

@property (nonatomic, strong) NSMutableArray *touchesIndexesArray;

@end

@implementation UuusPieChartView

#pragma mark - Life Circle

- (instancetype)initWithFrame:(CGRect)frame
                        model:(UuusPieChartModel *)model
                     animated:(BOOL)animated
{
    if (self = [super initWithFrame:frame]) {
        self.outerRadius = 0.0;
        self.innerRadius = 0.0;
        self.handlesImage = nil;
        self.widthOfSeparateLine = 0.0;
        self.colorOfSeparateLine = nil;
        
        [self updateWithModel:model animated:animated];
        [self.model addObserver:self forKeyPath:@"updated" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)updateWithModel:(UuusPieChartModel *)model
               animated:(BOOL)animated {
    self.model = model;
    self.updateAnimated = animated;
    [self drawPieChart];
}

#pragma mark - Public Interface

- (void)setOuterRadius:(double)outerRadius {
    _outerRadius = outerRadius ? outerRadius : UuusPieChartOuterRadius;
    self.ringsRadius = UuusPieChartRingsRadius;
}

- (void)setInnerRadius:(double)innerRadius {
    _innerRadius = innerRadius ? innerRadius : UuusPieChartInnerRadius;
    self.ringsRadius = UuusPieChartRingsRadius;
}

- (void)setHandlesImage:(UIImage *)handlesImage {
    _handlesImage = handlesImage ? handlesImage : [UIImage imageNamed:@"Pie_Chart_Pan"];
}

- (void)setWidthOfSeparateLine:(double)widthOfSeparateLine {
    _widthOfSeparateLine = widthOfSeparateLine ? widthOfSeparateLine : kWidthOfSeparateLine;
}

- (void)setColorOfSeparateLine:(UIColor *)colorOfSeparateLine {
    _colorOfSeparateLine = colorOfSeparateLine ? colorOfSeparateLine : [UIColor whiteColor];
}

#pragma mark - UI Actions

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    self.touchesIndex = -1;
    if (!self.touchesIndexesArray) {
        self.touchesIndexesArray = [NSMutableArray array];
    } else {
        [self.touchesIndexesArray removeAllObjects];
    }
    
    // Append the nearest handles Image against touch point.
    double minimumRadius = kRadiusOfHandlesImage * 1.69;
    for (long i = 0; i < self.handlesImageViewArray.count; ++i) {
        CGPoint center = [self.handlesImageViewArray[i] center];
        double radius = hypot(point.x - center.x, point.y - center.y);
        if (radius <= minimumRadius) {
            if (radius < minimumRadius) {
                minimumRadius = radius;
                [self.touchesIndexesArray removeAllObjects];
            }
            [self.touchesIndexesArray addObject:@(i)];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self movesHandlesWithTouches:touches];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self movesHandlesWithTouches:touches];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self movesHandlesWithTouches:touches];
}

#pragma mark - Notification Handle

- (void)movesHandlesWithTouches:(NSSet<UITouch *> *)touches {
    if (self.touchesIndexesArray.count) {
        CGPoint newCenter = [self newHandlesCenterWithTouches:touches];
        [self confirmMovesHandlesTagWithPoint:newCenter];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *, id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"updated"] && [object isKindOfClass:[UuusPieChartModel class]]) {
        BOOL updated = [[change valueForKey:@"new"] boolValue];
        if (updated) {
            [self drawPieChart];
            if (self.returnUpdatedDataBlock) {
                self.returnUpdatedDataBlock(self.model);
            }
        }
    }
}

#pragma mark - Private Method

- (void)drawPieChart {
    // Reset layer container.
    if (self.layerContainer) {
        [self.layerContainer removeFromSuperlayer];
    }
    self.layerContainer = [CALayer layer];
    [self.layer addSublayer:self.layerContainer];
    
    // Draw things into layer container.
    [self drawColorfulPieLayer];
    if (!self.updateAnimated) {
        [self drawSeparateLineAndHandlesImage];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self drawSeparateLineAndHandlesImage];
        });
        self.updateAnimated = NO;
    }
}

- (void)drawColorfulPieLayer {
    double startAngle = 0.0;
    for (long i = 0; i < self.model.count; ++i) {
        UuusPieChartItem *item = self.model.itemsArray[i];
        if (i > 0) {
            UuusPieChartItem *preItem = self.model.itemsArray[i - 1];
            startAngle = preItem.angle;
        }
        CAShapeLayer *pieLayer = [self drawPieShapeLayerWithBorderWidth:(self.outerRadius - self.innerRadius) borderColor:item.color startAngle:startAngle endAngle:item.angle];
        [self.layerContainer addSublayer:pieLayer];
        
        // Animations
        if (self.updateAnimated) {
            CAShapeLayer *maskLayer = [self drawPieShapeLayerWithBorderWidth:(self.outerRadius - self.innerRadius) borderColor:[UIColor blackColor] startAngle:startAngle endAngle:item.angle];
            pieLayer.mask = maskLayer;
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.duration = 1.0;
            animation.fromValue = @0;
            animation.toValue = @1;
            animation.delegate = self;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [maskLayer addAnimation:animation forKey:@"circleAnimation"];
        }
    }
}

// Anti-clockwise
- (CAShapeLayer *)drawPieShapeLayerWithBorderWidth:(double)borderWidth
                                       borderColor:(UIColor *)borderColor
                                        startAngle:(double)startAngle
                                          endAngle:(double)endAngle
{
    // Transform - Anti-clockwise.
    startAngle = UuusTwoPI - startAngle;
    endAngle   = UuusTwoPI - endAngle;

    // Rotate 90 degrees - 12 o'clock.
    startAngle = -M_PI_2 + startAngle;
    endAngle   = -M_PI_2 + endAngle;

    CAShapeLayer *pie = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath
                          bezierPathWithArcCenter:UuusCenterPoint
                          radius:self.ringsRadius
                          startAngle:startAngle
                          endAngle:endAngle
                          clockwise:NO];
    pie.fillColor = [UIColor clearColor].CGColor;
    pie.strokeColor = borderColor.CGColor;
    pie.strokeStart = 0;
    pie.strokeEnd = 1;
    pie.lineWidth = borderWidth;
    pie.path = path.CGPath;
    return pie;
}

- (void)drawSeparateLineAndHandlesImage {
    // Separate Lines
    for (long i = 0; i < self.model.count; ++i) {
        UuusPieChartItem *item = self.model.itemsArray[i];
        double startAngle = 0.0;
        double endAngle = 0.0;
        if (i != self.model.count - 1) {
            if (i > 0) {
                UuusPieChartItem *preItem = self.model.itemsArray[i - 1];
                startAngle = preItem.angle;
            }
            endAngle = item.angle;
        }
        // Transform and rotate.
        startAngle = UuusTwoPI - M_PI_2 - startAngle;
        endAngle   = UuusTwoPI - M_PI_2 - endAngle;

        CAShapeLayer *separateLineLayer = [CAShapeLayer layer];
        separateLineLayer.strokeColor = self.colorOfSeparateLine.CGColor;
        CGMutablePathRef pathRef = CGPathCreateMutable();
        UIBezierPath *path = [UIBezierPath
                              bezierPathWithArcCenter:UuusCenterPoint
                              radius:self.outerRadius
                              startAngle:startAngle
                              endAngle:endAngle
                              clockwise:NO];
        CGPathMoveToPoint(pathRef, NULL, path.currentPoint.x, path.currentPoint.y);
        path = [UIBezierPath bezierPathWithArcCenter:UuusCenterPoint
                                              radius:self.innerRadius
                                          startAngle:startAngle
                                            endAngle:endAngle
                                           clockwise:NO];
        CGPathAddLineToPoint(pathRef, NULL, path.currentPoint.x, path.currentPoint.y);
        separateLineLayer.path = pathRef;
        CGPathRelease(pathRef);
        separateLineLayer.lineWidth = self.widthOfSeparateLine;
        separateLineLayer.lineCap = @"square";
        [self.layerContainer addSublayer:separateLineLayer];
    }
    
    // Handles Images
    if (!self.handlesImageViewArray) {
        NSMutableArray *tempHandles = [NSMutableArray array];
        for (long i = 0; i < self.model.count - 1; ++i) {
            UIImageView *handlesImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kRadiusOfHandlesImage * 2.0, kRadiusOfHandlesImage * 2.0)];
            handlesImageView.image = self.handlesImage;
            handlesImageView.tag = i;
            handlesImageView.userInteractionEnabled = YES;
            [self addSubview:handlesImageView];
            [tempHandles addObject:handlesImageView];
        }
        self.handlesImageViewArray = [tempHandles copy];
    } else {
        for (UIImageView *obj in self.handlesImageViewArray) {
            [self bringSubviewToFront:obj];
        }
    }
    // Update handles image's center.
    [self.handlesImageViewArray enumerateObjectsUsingBlock:^(UIImageView *obj, NSUInteger idx, BOOL *stop) {
        UuusPieChartItem *item = self.model.itemsArray[idx];
        double startAngle = 0.0;
        double endAngle = item.angle;
        if (idx) {
            UuusPieChartItem *preItem = self.model.itemsArray[idx - 1];
            startAngle = preItem.angle;
        }
        // Transform and rotate.
        startAngle = UuusTwoPI - M_PI_2 - startAngle;
        endAngle   = UuusTwoPI - M_PI_2 - endAngle;

        UIBezierPath *path = [UIBezierPath
                              bezierPathWithArcCenter:UuusCenterPoint
                              radius:self.ringsRadius
                              startAngle:startAngle
                              endAngle:endAngle
                              clockwise:NO];
        obj.center = path.currentPoint;
    }];
}

- (CGPoint)newHandlesCenterWithTouches:(NSSet<UITouch *> *)touches {
    CGPoint newCenter;
    CGPoint center = UuusCenterPoint;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    double radius = hypot(point.x - center.x, point.y - center.y);
    double radiusScale = self.ringsRadius / radius;
    newCenter.x = (point.x - center.x) * radiusScale + center.x;
    newCenter.y = center.y - (center.y - point.y) * radiusScale;
    return newCenter;
}

- (void)confirmMovesHandlesTagWithPoint:(CGPoint)point {
    double angle = [self angleWithPoint:point];
    
#warning bug here (fixed)
    // Prevent from doing selections with touchesIndex every time.
    if (self.touchesIndex == -1) {
        // FirstObject
        long i = [[self.touchesIndexesArray firstObject] longValue];
        // More than one touches index selected.
        if (self.touchesIndexesArray.count > 1) {
            CGPoint firstPoint = [self.handlesImageViewArray[i] center];
            double firstAngle = [self angleWithPoint:firstPoint];
            if (firstAngle == angle) {
                return;
            } else if (firstAngle < angle) {
                i = [[self.touchesIndexesArray lastObject] intValue];
            }
#warning bug here (fixed)
            // 判断是否是原点重叠（是则否认此前i的值）（第一个逆时针原点0度)||(第二个逆时针原点2Pi度）
            // 不想翻译 不想逼逼
            if (![self.model.itemsArray[i] angle] || [self.model.itemsArray[i] angle] == UuusTwoPI) {
                // Separated by clockwise (if means anti-clockwise).
                if (angle < M_PI) {
                    for (long j = 0; j < self.model.itemsArray.count; ++j) {
                        if ([self.model.itemsArray[j] proportion] > 0) {
                            if (j > 0) {
                                i = j - 1;
                            }
                            break;
                        }
                    }
                } else {
                    for (long j = self.model.itemsArray.count - 1; j > -1; --j) {
                        if ([self.model.itemsArray[j] proportion] > 0) {
                            if (j < self.model.itemsArray.count - 1) {
                                i = j;
                            }
                            break;
                        }
                    }
                }
            }
        }
        self.touchesIndex = i;
    }
    UuusPieChartItem *item = self.model.itemsArray[self.touchesIndex];
    item.angle = angle;
}

- (double)angleWithPoint:(CGPoint)point {
    double angle;
    CGPoint origin = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - self.ringsRadius);
    double radius = hypot(point.x - origin.x, point.y - origin.y);
#warning bug here (fixed)
#pragma mark bug asin(x) (-1 <= x <= 1) else return NAN
    // Here: (0 <= x <= 1)
    double radian = ((radius / 2.0) / self.ringsRadius) > 1.0 ?
    1.0 : ((radius / 2.0) / self.ringsRadius);
    angle = 2.0 * asin(radian);
    if (point.x >= origin.x) {
        angle = UuusTwoPI - angle;
    }
    return angle;
}

@end
