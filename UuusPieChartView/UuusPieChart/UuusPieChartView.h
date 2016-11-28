//
//  UuusPieChartView.h
//  UuusPieChartView
//
//  Created by 范炜佳 on 16/7/2016.
//  Copyright © 2016 com.uuus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UuusPieChartModel;
typedef void(^UuusPieChartReturnUpdatedDataBlock)(UuusPieChartModel *model);

@interface UuusPieChartView : UIView

// nil or zero means default value
@property (nonatomic) double outerRadius;
@property (nonatomic) double innerRadius;
@property (nonatomic) double widthOfSeparateLine;

// nil means default value
@property (nonatomic, strong) UIImage *handlesImage;
@property (nonatomic, strong) UIColor *colorOfSeparateLine;

// return updated datas
@property (nonatomic, strong) UuusPieChartReturnUpdatedDataBlock returnUpdatedDataBlock;

- (instancetype)initWithFrame:(CGRect)frame
                        model:(UuusPieChartModel *)model
                     animated:(BOOL)animated;

- (void)updateWithModel:(UuusPieChartModel *)model
               animated:(BOOL)animated;

@end
