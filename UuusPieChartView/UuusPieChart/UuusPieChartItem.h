//
//  UuusPieChartItem.h
//  UuusPieChartView
//
//  Created by 范炜佳 on 16/7/2016.
//  Copyright © 2016 com.uuus. All rights reserved.
//

#define UuusRandomColorRGB (arc4random() % 256) / 255.0

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

const static double UuusTwoPI = 2.0 * M_PI;

@interface UuusPieChartItem : NSObject

// Updated automatically.
@property (nonatomic) double value;
@property (nonatomic) double proportion;

/**
 *  Anti-clockwise 12 o'clock.
 */
@property (nonatomic) double angle;

// Nil means random color.
@property (nonatomic, strong) UIColor *color;

// Custom description
@property (nonatomic, copy) NSString *textDescription;

+ (instancetype)itemWithValue:(double)value
                        color:(UIColor *)color
                  description:(NSString *)description;

@end
