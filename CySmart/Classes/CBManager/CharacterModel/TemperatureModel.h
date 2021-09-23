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

#import <Foundation/Foundation.h>
#import "CyCBManager.h"


@interface TemperatureModel : NSObject

/*!
 *  @property sensorTypeString
 *
 *  @discussion The temperature sensor type
 *
 */


@property (strong,nonatomic) NSString *sensorTypeString;

/*!
 *  @property sensorScanIntervalString
 *
 *  @discussion The temperature sensor interval
 *
 */

@property (strong,nonatomic) NSString *sensorScanIntervalString;

/*!
 *  @property temperatureValueString
 *
 *  @discussion The temperature value
 *
 */

@property (strong,nonatomic) NSString *temperatureValueString;

/*!
 *  @method stopUpdate
 *
 *  @discussion Method to stop update
 *
 */

-(void) stopUpdate;

/*!
 *  @method getCharacteristicsForTemperatureService:
 *
 *  @discussion Method to get characteristics for temperature service
 *
 */

-(void) getCharacteristicsForTemperatureService:(CBService *) service;

/*!
 *  @method getValuesForTemperatureCharacteristics:
 *
 *  @discussion Method to get values for temperature characteristics
 *
 */
-(void) getValuesForTemperatureCharacteristics:(CBCharacteristic *) characteristic;

/*!
 *  @method updateValueForTemperature
 *
 *  @discussion Method to set notification for temperature value
 *
 */
-(void) updateValueForTemperature;

/*!
 *  @method readValueFortemperatureCharacteristics
 *
 *  @discussion Method to read values for temperature sensor scan interval and sensor type
 *
 */
-(void) readValueForTemperatureCharacteristics;

@end