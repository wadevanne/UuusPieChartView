//
//  UuusPieChartModel.m
//  UuusPieChartView
//
//  Created by 范炜佳 on 16/7/2016.
//  Copyright © 2016 com.uuus. All rights reserved.
//

//#define NSLogU(...) NSLog(__VA_ARGS__)
#define NSLogU(...)

#import "UuusPieChartModel.h"
#import "UuusPieChartItem.h"

@interface UuusPieChartModel ()
@property (nonatomic) BOOL updated;
@end

@implementation UuusPieChartModel

+ (instancetype)modelWithItemsArray:(NSArray<UuusPieChartItem *> *)itemsArray {
    UuusPieChartModel *model = [[UuusPieChartModel alloc] init];
    model.itemsArray = itemsArray;
    return model;
}

- (double)value {
    double returnValue = 0.0;
    for (UuusPieChartItem *item in self.itemsArray) {
        returnValue += item.value;
    }
    return returnValue;
}

- (double)ratio { return 1.0; }

- (NSUInteger)count {
    return self.itemsArray.count;
}

- (void)setItemsArray:(NSArray<UuusPieChartItem *> *)itemsArray {
    _itemsArray = itemsArray;
    
    double previous = 0.0;
    double interval = 0.0;
    
    // initialize item's ratio and angle
    for (UuusPieChartItem *item in _itemsArray) {
        previous = interval;
        interval += item.value;
        
        item.ratio = (interval - previous) / self.value;
        item.angle = interval / self.value * UuusTwoPI;
        
        [item addObserver:self
               forKeyPath:@"angle"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *, id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"angle"] && [object isKindOfClass:[UuusPieChartItem class]]) {
        NSUInteger idx = [_itemsArray indexOfObject:object];
        double angle = [[change valueForKey:@"new"] doubleValue];
        
        // check lower index if (idx > 0)
        if (idx > 0) {
            UuusPieChartItem *item = _itemsArray[idx - 1];
            if (angle < item.angle) item.angle = angle;
        }
        // check higher index if (idx < self.count - 1)
        if (idx < self.count - 1) {
            UuusPieChartItem *item = _itemsArray[idx + 1];
            if (angle > item.angle) item.angle = angle;
        }
        
        double preRatio = 0.0;
        double preValue = 0.0;
        
        // update item's ratio and angle
        for (UuusPieChartItem *item in self.itemsArray) {
            double angleRatio = item.angle / UuusTwoPI;
            
            item.ratio = angleRatio - preRatio;
            item.value = angleRatio * self.value - preValue;
            
            preRatio = angleRatio;
            preValue = angleRatio * self.value;
            
            NSLogU(@"item[%d].value = %f", [self.itemsArray indexOfObject:item], item.value);
        }
        self.updated = YES;
    }
}

@end
