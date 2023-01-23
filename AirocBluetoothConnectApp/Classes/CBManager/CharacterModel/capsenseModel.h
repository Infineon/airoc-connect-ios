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

#import <Foundation/Foundation.h>
#import "CyCBManager.h"


@interface capsenseModel : NSObject

/*!
 *  @property proximityValue
 *
 *  @discussion Value for proximity
 *
 */
@property (nonatomic) float proximityValue;

/*!
 *  @property capsenseSliderValue
 *
 *  @discussion The value received when the user moves finger on the peripheral
 *
 */
@property (nonatomic) float capsenseSliderValue;

/*!
 *  @property capsenseButtonCount
 *
 *  @discussion The number of capsense buttons
 *
 */
@property (nonatomic) float capsenseButtonCount;

/*!
 *  @property capsenseButtonStatus1
 *
 *  @discussion 8bit flag that shows the status of the first 8 capsense buttons
 *
 */

@property (nonatomic) uint8_t capsenseButtonStatus1;

/*!
 *  @property capsenseButtonStatus2
 *
 *  @discussion 8bit flag that shows the status of the last 8 capsense buttons
 *
 */

@property (nonatomic) uint8_t capsenseButtonStatus2;

/*!
 *  @method startDiscoverCharacteristicWithUUID: completionHandler
 *
 *  @discussion Discovers characteristics of the CapSense service
 */
-(void)startDiscoverCharacteristicWithUUID:(CBUUID *)UUID completionHandler:(void (^) (BOOL success,CBService *service, NSError *error))handler;

/*!
 *  @method updateCharacteristicWithHandler:
 *
 *  @discussion Start notification/indication for the CapSense characteristic
 */
-(void)updateCharacteristicWithHandler:(void (^) (BOOL success, NSError *error))handler;

/*!
 *  @method stopUpdate
 *
 *  @discussion stop notifications or indications for the value of a specified characteristic.
 */
-(void)stopUpdate;

@end
