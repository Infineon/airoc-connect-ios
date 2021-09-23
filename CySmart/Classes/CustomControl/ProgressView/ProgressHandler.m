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

#import "ProgressHandler.h"
#import "MBProgressHUD.h"
#import <unistd.h>


#define SCREENSHOT_MODE 0

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 847.20
#endif

/*!
 *  @class ProgressHandler
 *
 *  @discussion Class to handle the progress indicator
 *
 */
@interface ProgressHandler () <MBProgressHUDDelegate> {
    
    MBProgressHUD *ProgressView;
}
@end

@implementation ProgressHandler

+ (id)sharedInstance {
    static ProgressHandler *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init])
    {
        ProgressView = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    }
    return self;
}

/*!
 *  @method showWithDetailsLabel: Detail:
 *
 *  @discussion Method to add present the progress view
 *
 */
- (void)showWithTitle:(NSString *)title detail:(NSString *)detail {
    
    [[UIApplication sharedApplication].keyWindow addSubview:ProgressView];
    ProgressView.delegate = self;
    ProgressView.labelText =title;
    ProgressView.detailsLabelText = detail;
    ProgressView.square = YES;
    
    [ProgressView show:YES];
}

/*!
 *  @method hideProgressView
 *
 *  @discussion Method to hide progress view
 *
 */
-(void)hideProgressView
{
    [ProgressView hide:YES];
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [ProgressView removeFromSuperview];

}


@end
