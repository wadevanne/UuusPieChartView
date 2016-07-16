//
//  UuusPieChartItem.m
//  UuusPieChartView
//
//  Created by 范炜佳 on 16/7/2016.
//  Copyright © 2016 com.uuus. All rights reserved.
//

#import "UuusPieChartItem.h"

@implementation UuusPieChartItem

+ (instancetype)itemWithValue:(double)value
                        color:(UIColor *)color
                  description:(NSString *)description
{
    UuusPieChartItem *item = [[UuusPieChartItem alloc] init];
    item.value = value;
    item.angle = M_PI;
    item.color = color;
    item.textDescription = description;
    return item;
}

- (void)setValue:(double)value {
    NSAssert(value >= 0, @"Value should >= 0.");
    if (value != _value) {
        _value = value;
    }
}

- (void)setAngle:(double)angle {
    if (_angle - angle > M_PI) {
        _angle = UuusTwoPI;
    } else if (angle - _angle > M_PI) {
        _angle = 0.0;
    } else if (angle != _angle) {
        _angle = angle;
    }
}

- (void)setColor:(UIColor *)color {
    _color = color ? color : [UIColor colorWithRed:UuusRandomColorRGB
                                             green:UuusRandomColorRGB
                                              blue:UuusRandomColorRGB
                                             alpha:1.0];
}

@end
