/*
 * (c) 2014-2020, Cypress Semiconductor Corporation or a subsidiary of 
 * Cypress Semiconductor Corporation.  All rights reserved.
 * 
 * This software, including source code, documentation and related 
 * materials ("Software"),  is owned by Cypress Semiconductor Corporation 
 * or one of its subsidiaries ("Cypress") and is protected by and subject to 
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

#import <UIKit/UIKit.h>
#import "LineChart.h"
#import "KLCPopup.h"


@protocol lineChartDelegate <NSObject>

-(void)shareScreen:(id)sender;

@end

@interface MyLineChart : UIView

/*!
 *  @property chartTitle
 *
 *  @discussion chart title name
 *
 */
@property (nonatomic,retain)NSString *chartTitle;

/*!
 *  @property chartView
 *
 *  @discussion view that contain chart
 *
 */
@property(nonatomic,strong) LCLineChartView *chartView;

@property(strong,nonatomic)id<lineChartDelegate> delegate;

/*!
 *  @property pauseButton
 *
 *  @discussion Button to handle the pause/resume sate of chart
 *
 */
@property (strong,nonatomic) UIButton *pauseButton;

/*!
 *  @property shareButton
 *
 *  @discussion Button to handle share while the graph is present
 *
 */
@property (strong,nonatomic) UIButton *shareButton;

/*!
 *  @property graphTitleLabel
 *
 *  @discussion Label to add the graph title
 *
 */
@property (strong, nonatomic) UILabel *graphTitleLabel;

/*!
 *  @method addXLabel: yLabel:
 *
 *  @discussion Method to add axis label name
 *
 */
-(void) addXLabel:(NSString *)xLabelText yLabel:(NSString *)yLabelText;

/*!
 *  @method updateLineGraph: Y:
 *
 *  @discussion Method to update the values in the graph
 *
 */

-(void) updateLineGraph:(NSMutableArray *)xValues Y:(NSMutableArray *)yValues;

/*!
 *  @method setXaxisScaleWithValue
 *
 *  @discussion Method to set X axis scale
 *
 */
-(void) setXaxisScaleWithValue:(float)scale;


@end
