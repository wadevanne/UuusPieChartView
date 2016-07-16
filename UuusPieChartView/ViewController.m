//
//  ViewController.m
//  UuusPieChartView
//
//  Created by 范炜佳 on 16/7/2016.
//  Copyright © 2016 com.uuus. All rights reserved.
//

#import "ViewController.h"
#import "UuusPieChartView.h"
#import "UuusPieChartItem.h"
#import "UuusPieChartModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UuusPieChartItem *redItem = [UuusPieChartItem itemWithValue:10 color:[UIColor redColor] description:nil];
    UuusPieChartItem *orangeItem = [UuusPieChartItem itemWithValue:20 color:[UIColor orangeColor] description:nil];
    UuusPieChartItem *brownItem = [UuusPieChartItem itemWithValue:30 color:[UIColor brownColor] description:nil];
    UuusPieChartItem *greenItem = [UuusPieChartItem itemWithValue:40 color:[UIColor greenColor] description:nil];
    
    UuusPieChartModel *model = [UuusPieChartModel modelWithItemsArray:@[redItem, orangeItem, brownItem, greenItem]];
    [model addObserver:self forKeyPath:@"updated" options:NSKeyValueObservingOptionNew context:nil];
    UuusPieChartView *pieChartView = [[UuusPieChartView alloc] initWithFrame:CGRectMake(69.0, 169.0, 229.0, 229.0) model:model animated:YES];
    [self.view addSubview:pieChartView];
    
    
    CGFloat x = CGRectGetMinX(pieChartView.frame) / 2.0;
    CGFloat y = 49.0;
    CGFloat width = (CGRectGetWidth(self.view.frame) - CGRectGetMinX(pieChartView.frame) * 1.5) / 2;
    CGFloat height = 49.0;
    for (long i = 0; i < model.count / 2 + model.count % 2; ++i) {
        for (long j = 0; j < 2; ++j) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x + j * (width + x), y + i * height, width, height)];
            label.tag = j + i * 2;
            label.text = [NSString stringWithFormat:@"%f", model.itemsArray[label.tag].proportion];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = model.itemsArray[label.tag].color;
            [self.view addSubview:label];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *, id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"updated"] && [object isKindOfClass:[UuusPieChartModel class]]) {
        UuusPieChartModel *model = object;
        for (id obj in self.view.subviews) {
            if ([obj isKindOfClass:[UILabel class]]) {
                UILabel *label = obj;
                label.text = [NSString stringWithFormat:@"%f", model.itemsArray[label.tag].proportion];
            }
        }
    }
}

@end
