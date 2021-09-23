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


@interface AccelerometerModel : NSObject


/*!
 *  @property xValue
 *
 *  @discussion The accelerometer X coordinate value
 *
 */

@property(nonatomic) float xValue;

/*!
 *  @property yValue
 *
 *  @discussion The accelerometer Y coordinate value
 *
 */
@property(nonatomic) float yValue;

/*!
 *  @property zValue
 *
 *  @discussion The accelerometer Z coordinate value
 *
 */
@property(nonatomic) float zValue;

/*!
 *  @property scanIntervalString
 *
 *  @discussion The accelerometer sensor scan intervel
 *
 */

@property (strong,nonatomic) NSString *scanIntervalString;

/*!
 *  @property filterTypeConfigurationString
 *
 *  @discussion The accelerometer sensor filterType
 *
 */
@property (strong,nonatomic) NSString *filterTypeConfigurationString;

/*!
 *  @property sensorTypeString
 *
 *  @discussion The accelerometer sensor type
 *
 */

@property (strong,nonatomic) NSString *sensorTypeString;

/*!
 *  @method stopUpdate
 *
 *  @discussion Method to stop update
 *
 */

-(void) stopUpdate;

/*!
 *  @method writeValueForAccelerometerSensorScanInterval:
 *
 *  @discussion Method to write value for accelerometer SensorScanInterval
 *
 */
-(void) writeValueForAccelerometerSensorScanInterval:(int) newScanInterval;

/*!
 *  @method writeValueForAccelerometerFilterconfiguration:
 *
 *  @discussion Method to write value for accelerometer filter configuration
 *
 */

-(void) writeValueForAccelerometerFilterConfiguration:(int) filterconfiguration;

/*!
 *  @method getCharacteristicsForAccelerometerService
 *
 *  @discussion Method to get the characteristics for accelerometer service
 *
 */

-(void) getCharacteristicsForAccelerometerService:(CBService *) service;

/*!
 *  @method updateXYZCharacteristics
 *
 *  @discussion Method to set notify for accelerometer X,Y and Z values
 *
 */
-(void) updateXYZCharacteristics;

/*!
 *  @method getXYZValuesWithCharacteristic:
 *
 *  @discussion Method to get the accelerometer X,Y and Z values
 *
 */

-(void) getXYZValuesWithCharacteristic:(CBCharacteristic *)characteristic;

/*!
 *  @method readAccelerometerCharacteristics
 *
 *  @discussion Method to read values for different accelerometer characteristics
 *
 */
-(void) readAccelerometerCharacteristics;

/*!
 *  @method getValuesForAcclerometerCharacteristics:
 *
 *  @discussion Method to parse values for different accelerometer characteristics
 *
 */
-(void) getValuesForAcclerometerCharacteristics:(CBCharacteristic *)characteristic;


@end
