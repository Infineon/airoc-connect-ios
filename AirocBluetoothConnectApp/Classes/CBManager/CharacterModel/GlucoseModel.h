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


@interface GlucoseModel : NSObject



/*!
 *  @property glucoseRecords
 *
 *  @discussion The glucose data records received from the kit
 *
 */

@property (nonatomic, retain) NSMutableArray *glucoseRecords;


/*!
 *  @property recordNameArray
 *
 *  @discussion Array of the name of records 
 *
 */

@property (strong, nonatomic) NSMutableArray *recordNameArray;

/*!
 *  @property contextInfoArray
 *
 *  @discussion Array of glucose measurement context data
 *
 */

@property (strong, nonatomic) NSMutableArray *contextInfoArray;

/*!
 *  @method startDiscoverChar:
 *
 *  @discussion Discovers the specified characteristics of a service.
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

/*!
 *  @method writeRACPCharacteristicWithValueString:
 *
 *  @discussion Write specified value to the RACP characteristic.
 */

-(void) writeRACPCharacteristicWithValueString:(NSString *)Value;

/*!
 *  @method getGlucoseData:
 *
 *  @discussion Parse the glucose measurement characteristic value.
 */

-(NSMutableDictionary *) getGlucoseData:(NSData *)characteristicValue;

/*!
 *  @method getGlucoseContextInfoFromData:
 *
 *  @discussion Method to parse the value from the glucose measurement context characteristic
 *
 */

-(NSMutableDictionary *) getGlucoseContextInfoFromData:(NSData *) characteristicValue;

/*!
 *  @method setCharacteristicUpdates:
 *
 *  @discussion Sets notifications or indications for glucose characteristics.
 */
-(void) setCharacteristicUpdates;

/*!
 *  @method removePreviousRecords
 *
 *  @discussion clear all the records received.
 */

-(void) removePreviousRecords;

@end
