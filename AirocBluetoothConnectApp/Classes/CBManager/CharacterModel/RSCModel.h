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

@interface RSCModel : NSObject

/*!
 *  @property InstantaneousSpeed
 *
 *  @discussion Speed at a particular moment, Unit is in m/s with a resolution of 1/256 s.
    Converted to km/hr  ( m/s *3.6)
 *
 */
@property(nonatomic ,assign )float InstantaneousSpeed;

/*!
 *  @property InstantaneousCadence
 *
 *  @discussion  Unit is in 1/minute (or RPM) with a resolutions of 1 1/min (or 1 RPM)
 *
 */
@property(nonatomic ,assign )float InstantaneousCadence;

/*!
 *  @property InstantaneousStrideLength
 *
 *  @discussion   Unit is in meter with a resolution of 1/100 m (or centimeter).
 *
 */
@property(nonatomic ,assign )float InstantaneousStrideLength;

/*!
 *  @property TotalDistance
 *
 *  @discussion   Unit is in meter with a resolution of 1/10 m (or decimeter).
 *
 */
@property(nonatomic ,assign )float TotalDistance;

/*!
 *  @property IsWalking
 *
 *  @discussion   Walking or Running Status .
 *
 */
@property(nonatomic ,assign )BOOL  IsWalking;

/*!
 *  @method startDiscoverChar:
 *
 *  @discussion Discovers the specified characteristics of a service..
 */

-(void)startDiscoverChar:(void (^) (BOOL success, NSError *error))handler;

/*!
 *  @method updateCharacteristicWithHandler:
 *
 *  @discussion Sets notifications or indications for the value of a specified characteristic.
 */

-(void)updateCharacteristicWithHandler:(void (^) (BOOL success, NSError *error))handler;

/*!
 *  @method stopUpdate
 *
 *  @discussion Stop notifications or indications for the value of a specified characteristic.
 */

-(void)stopUpdate;

@end
