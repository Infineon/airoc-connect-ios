//
//  LCLineChartView.h
//
//
//  Created by Marcel Ruegenberg on 02.08.13.
//
//+Copyright (C) 2012 Marcel Ruegenberg
//+
//+Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//+
//+The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//+
//+THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

#import <UIKit/UIKit.h>

@class LCLineChartDataItem;
@class LCLineChartData;

typedef LCLineChartDataItem *(^LCLineChartDataGetter)(NSUInteger item);
typedef void(^LCLineChartSelectedItem)(LCLineChartData * data, NSUInteger item, CGPoint positionInChart);
typedef void(^LCLineChartDeselectedItem)(void);


@interface LCLineChartDataItem : NSObject

@property (readonly) double x; /// should be within the x range
@property (readonly) double y; /// should be within the y range
@property (readonly) NSString *xLabel; /// label to be shown on the x axis
@property (readonly) NSString *dataLabel; /// label to be shown directly at the data item

+ (LCLineChartDataItem *)dataItemWithX:(double)x y:(double)y xLabel:(NSString *)xLabel dataLabel:(NSString *)dataLabel;

@end



@interface LCLineChartData : NSObject

@property BOOL drawsDataPoints;
@property (strong) UIColor *color;
@property (copy) NSString *title;
@property NSUInteger itemCount;

@property double xMin;
@property double xMax;

@property (copy) LCLineChartDataGetter getData;

@end



@interface LCLineChartView : UIView

@property (copy) LCLineChartSelectedItem selectedItemCallback; /// Called whenever a data point is selected
@property (copy) LCLineChartDeselectedItem deselectedItemCallback; /// Called after a data point is deselected and before the next `selected` callback

@property (nonatomic, strong) NSArray *data; /// Array of `LineChartData` objects, one for each line.
@property float xAxisScaleValue;
@property double yMin;
@property double yMax;
@property double xMin;
@property (nonatomic) BOOL setXmin;
@property (strong) NSArray *ySteps; /// Array of step names (NSString). At each step, a scale line is shown.
@property NSUInteger xStepsCount; /// number of steps in x. At each x step, a vertical scale line is shown. if x < 2, nothing is done

@property BOOL smoothPlot; /// draw a smoothed Bezier plot? Default: NO
@property BOOL drawsDataPoints; /// Switch to turn off circles on data points. On by default.
@property BOOL drawsDataLines; /// Switch to turn off lines connecting data points. On by default.

@property (strong) UIFont *scaleFont; /// Font in which scale markings are drawn. Defaults to [UIFont systemFontOfSize:10].
@property (nonatomic,strong) UIColor *axisLabelColor;

- (void)showLegend:(BOOL)show animated:(BOOL)animated;
- (void)setDefaultValues ;
@end
