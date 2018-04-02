//
//  UuusPieChartModel.h
//  UuusPieChartView
//
//  Created by 范炜佳 on 16/7/2016.
//  Copyright © 2016 com.uuus. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UuusPieChartItem;

@interface UuusPieChartModel : NSObject

@property (nonatomic, readonly) double value;
@property (nonatomic, readonly) double ratio;

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, copy)     NSArray<UuusPieChartItem *> *itemsArray;

@property (nonatomic, readonly, getter=isUpdated) BOOL updated;

+ (instancetype)modelWithItemsArray:(NSArray<UuusPieChartItem *> *)itemsArray;

@end
