/*
 * Copyright 2014-2022, Cypress Semiconductor Corporation (an Infineon company) or
 * an affiliate of Cypress Semiconductor Corporation.  All rights reserved.
 *
 * This software, including source code, documentation and related
 * materials ("Software") is owned by Cypress Semiconductor Corporation
 * or one of its affiliates ("Cypress") and is protected by and subject to
 * worldwide patent protection (United States and foreign),
 * United States copyright laws and international treaty provisions.
 * Therefore, you may use this Software only as provided in the license
 * agreement accompanying the software package from which you
 * obtained this Software ("EULA").
 * If no EULA applies, Cypress hereby grants you a personal, non-exclusive,
 * non-transferable license to copy, modify, and compile the Software
 * source code solely for use in connection with Cypress's
 * integrated circuit products.  Any reproduction, modification, translation,
 * compilation, or representation of this Software except as specified
 * above is prohibited without the express written permission of Cypress.
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, NONINFRINGEMENT, IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Cypress
 * reserves the right to make changes to the Software without notice. Cypress
 * does not assume any liability arising out of the application or use of the
 * Software or any product or circuit described in the Software. Cypress does
 * not authorize its products for use in any products where a malfunction or
 * failure of the Cypress product may reasonably be expected to result in
 * significant property damage, injury or death ("High Risk Product"). By
 * including Cypress's product in a High Risk Product, the manufacturer
 * of such system or application assumes all risk of such use and in doing
 * so agrees to indemnify Cypress against all liability.
 */

#import "MyLineChart.h"
#import "Constants.h"

#define Y_AXIS_POINT_COUNT      10
#define AXIS_LABEL_WIDTH        90
#define AXIS_LABEL_HEIGHT       20
#define GRAPH_TITLE_WIDTH       150

#define PAUSE_BUTTON_WIDTH      80
#define PAUSE_BUTTON_HEIGHT     30



#define PAUSE       @"PAUSE"
#define RESUME      @"RESUME"
#define SHARE       @"SHARE"

#define FONT        @"Roboto-Regular"


/*!
 *  @class MyLineChart
 *
 *  @discussion Class to handle graph related tasks
 *
 */
@interface MyLineChart()
{
    NSInteger widthOffset;
    UIScrollView *bgScrollView;
    BOOL isPauseState;
    UILabel *xLabel, *yLabel;
}

@end

@implementation MyLineChart
@synthesize chartTitle;
@synthesize shareButton;
@synthesize pauseButton;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        chartTitle = @"";
        [self initLineGraph:self.bounds];
        widthOffset = 1 ;
    }
    return self;
}

/*!
 *  @method onPauseTouched:
 *
 *  @discussion Method to handle the pause button click event
 *
 */
-(void)onPauseTouched:(id)sender
{
    UIButton *pButton = (UIButton*)sender;
    
    if(pButton.selected)
    {
        isPauseState = NO;
    }
    else
    {
        isPauseState = YES;
    }
        
    pButton.selected = !pButton.selected;
    
}

/*!
 *  @method initLineGraph:
 *
 *  @discussion Method initialize graph view with given frame
 *
 */
-(void)initLineGraph:(CGRect)bounds
{
    /* configuring adding pause/resume button */
    
    pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, bounds.size.height - PAUSE_BUTTON_HEIGHT, bounds.size.width/2, PAUSE_BUTTON_HEIGHT)];
    [pauseButton setTitle:PAUSE forState:UIControlStateNormal];
    [pauseButton setTitle:RESUME forState:UIControlStateSelected];
    [pauseButton setBackgroundColor:BLUE_COLOR];
    [pauseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [pauseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [pauseButton addTarget:self action:@selector(onPauseTouched:) forControlEvents:UIControlEventTouchUpInside];
    pauseButton.layer.cornerRadius = 10;
    [self addSubview:pauseButton];
    
    /*  configuring share button for graph */
    
    shareButton = [[UIButton alloc] initWithFrame:CGRectMake( bounds.size.width/2, bounds.size.height - PAUSE_BUTTON_HEIGHT, bounds.size.width/2, PAUSE_BUTTON_HEIGHT)];
    [shareButton setTitle:SHARE forState:UIControlStateNormal];
    [shareButton setBackgroundColor:BLUE_COLOR];
    [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(onShareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    shareButton.layer.cornerRadius = 10;
    [self addSubview:shareButton];
    
    bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height- PAUSE_BUTTON_HEIGHT)];
    bgScrollView.contentSize =bgScrollView.frame.size;
    
    _chartView = [[LCLineChartView alloc] initWithFrame:CGRectMake(20, 20, bgScrollView.frame.size.width-40, bgScrollView.frame.size.height-20)];
    _chartView.yMin = 0;
    _chartView.yMax = -100;
    _chartView.xAxisScaleValue = 1.0;
    _chartView.axisLabelColor = [UIColor blueColor];

    xLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.size.width-AXIS_LABEL_WIDTH,bounds.size.height-PAUSE_BUTTON_HEIGHT- AXIS_LABEL_HEIGHT, AXIS_LABEL_WIDTH, AXIS_LABEL_HEIGHT)];
    xLabel.font = [UIFont fontWithName:FONT size:10];
    xLabel.backgroundColor = [UIColor clearColor];
    
    yLabel = [[UILabel alloc] initWithFrame:CGRectMake(-58, (_chartView.frame.size.height/2)-40, AXIS_LABEL_WIDTH+40, AXIS_LABEL_HEIGHT)];
    yLabel.font = [UIFont fontWithName:FONT size:10];
    yLabel.backgroundColor = [UIColor clearColor];
    [yLabel setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    
    _graphTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.bounds.size.width/2.0)-(GRAPH_TITLE_WIDTH/2.0) , 1, GRAPH_TITLE_WIDTH, AXIS_LABEL_HEIGHT-3)];
    _graphTitleLabel.font = [UIFont fontWithName:FONT size:10];
    _graphTitleLabel.backgroundColor = [UIColor whiteColor];
    _graphTitleLabel.textAlignment = NSTextAlignmentCenter;
    
    [_chartView addSubview:yLabel];
    
    [bgScrollView addSubview:_chartView];
    [self addSubview:bgScrollView];
    [self addSubview:xLabel];
    [self addSubview:_graphTitleLabel];

    [self setBackgroundColor:[UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:0.7]];

}

/*!
 *  @method onShareButtonClicked:
 *
 *  @discussion Method to handle the share buttton click event
 *
 */
-(void)onShareButtonClicked:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(shareScreen:)])
    {
        [_delegate shareScreen:sender];
    }
}


/*!
 *  @method addXLabel: yLabel:
 *
 *  @discussion Method to add axis label name
 *
 */
-(void) addXLabel:(NSString *)xLabelText yLabel:(NSString *)yLabelText
{
    xLabel.text = xLabelText;
    yLabel.text = yLabelText;
}

/*!
 *  @method setXaxisScaleWithValue
 *
 *  @discussion Method to set X axis scale
 *
 */
-(void) setXaxisScaleWithValue:(float)scale
{
    _chartView.xAxisScaleValue = scale;
}

/*!
 *  @method updateLineGraph: Y:
 *
 *  @discussion Method to update the values in the graph
 *
 */
-(void)updateLineGraph:(NSMutableArray *)xValues Y:(NSMutableArray *)yValues
{
    if(isPauseState)
    {
        return;
    }
    LCLineChartData *dataTwo = [LCLineChartData new];
    dataTwo.xMin = [[xValues objectAtIndex:0] floatValue];
    dataTwo.xMax = [[xValues objectAtIndex:0] floatValue];
    dataTwo.title = chartTitle;
    dataTwo.color = [UIColor darkGrayColor];
    dataTwo.itemCount = [xValues count];
    
    for(NSString *axisVal in xValues)
    {
        if([axisVal floatValue] < dataTwo.xMin)
        {
            dataTwo.xMin = [axisVal floatValue];
        }
        if([axisVal floatValue] > dataTwo.xMax)
        {
            dataTwo.xMax = [axisVal floatValue];
        }
    }
    
    if (_chartView.setXmin) {
        _chartView.xMin = [[xValues objectAtIndex:0] floatValue];
    }
    
    dataTwo.getData = ^(NSUInteger item) {
        float x = [xValues[item] floatValue];
        float y = [yValues[item] floatValue];//powf(2, x / 7);
        NSString *label1 = [NSString stringWithFormat:@"%@", xValues[item]];
        NSString *label2 = [NSString stringWithFormat:@"%@", yValues[item]];
        return [LCLineChartDataItem dataItemWithX:x y:y xLabel:label1 dataLabel:label2];
    };
    
        
    // "Y" Axis Handling
    
    for(NSString *axisVal in yValues)
    {
        if([axisVal floatValue] < _chartView.yMin)
        {
            _chartView.yMin = [axisVal floatValue];
        }
        if([axisVal floatValue] > _chartView.yMax)
        {
            _chartView.yMax = [axisVal floatValue];
        }
    }
    
    
    float valDiff = _chartView.yMax  - _chartView.yMin ;
    valDiff = valDiff / Y_AXIS_POINT_COUNT;
    NSMutableArray *yAxisPlots = [NSMutableArray new];
    
    if (_chartView.yMin >= 0.0)
    {
        for(int index = 1 ; index <= Y_AXIS_POINT_COUNT ;index++)
        {
            [yAxisPlots addObject:[NSString stringWithFormat:@"%0.2f",valDiff*index]];
        }
    }
    else
    {
        if (_chartView.yMax < 0)
        {
            if (yValues.count == 1)
            {
                valDiff = -1 * _chartView.yMin;
            }
            
            for(int index = 1 ; index <= Y_AXIS_POINT_COUNT ;index++)
            {
                [yAxisPlots addObject:[NSString stringWithFormat:@"%0.2f",_chartView.yMin + (index - 1) *( valDiff)]];
            }
        }
        else
        {
            float valDiff = _chartView.yMax  - _chartView.yMin ;
            valDiff = valDiff /( Y_AXIS_POINT_COUNT - 1);

            if (yValues.count == 1)
            {
                valDiff = -1 * _chartView.yMin;
            }
            
            for(int index = 1 ; index <= Y_AXIS_POINT_COUNT ;index++)
            {
                [yAxisPlots addObject:[NSString stringWithFormat:@"%0.2f",_chartView.yMin + (index - 1) * valDiff]];
            }
        }
    }
   
    _chartView.ySteps = yAxisPlots;
    
    if ([xValues count]>Y_AXIS_POINT_COUNT)
    {
        int widthCounter = (int) [xValues count]/Y_AXIS_POINT_COUNT ;
        if(widthCounter > widthOffset)
        {
            widthOffset = widthCounter + 1 ;
            [self updateFrameSize:widthOffset];
        }
        else if(widthOffset==widthCounter)
        {
            widthOffset++;
            [self updateFrameSize:widthOffset];
           
        }
        
    }
    _chartView.data =  @[dataTwo];
    _chartView.xStepsCount = [xValues count];
}

/*!
 *  @method updateFrameSize:
 *
 *  @discussion Method to handle the frame size of graph
 *
 */
-(void)updateFrameSize:(NSInteger)multiplier {
    CGRect currentFrame =_chartView.frame ;
    currentFrame.size.width = self.frame.size.width * multiplier;
    _chartView.frame = currentFrame;
    bgScrollView.contentSize = currentFrame.size;
    float contentOffset = bgScrollView.contentSize.width - self.viewForFirstBaselineLayout.frame.size.width;
    if (contentOffset > 0) {
        [bgScrollView setContentOffset:CGPointMake(contentOffset+30, 0.0) animated:NO];
    }
}

@end
