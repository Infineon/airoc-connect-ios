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

#import "AccelerometerModel.h"
#import "BarometerModel.h"
#import "TemperatureModel.h"
#import "FindMeModel.h"
#import "BatteryServiceModel.h"



@interface SensorHubModel : NSObject

/*!
 *  @property accelerometer
 *
 *  @discussion model class for accelerometer
 *
 */
@property (nonatomic, strong) AccelerometerModel *accelerometer;

/*!
 *  @property barometer
 *
 *  @discussion model class for barometer
 *
 */

@property (nonatomic, strong) BarometerModel *barometer;

/*!
 *  @property temperatureSensor
 *
 *  @discussion model class for temperature sensor
 *
 */

@property (nonatomic, strong) TemperatureModel *temperatureSensor;

/*!
 *  @property findMeModel
 *
 *  @discussion model class for find me service
 *
 */

@property (nonatomic, strong) FindMeModel *findMeModel;

/*!
 *  @property batteryModel
 *
 *  @discussion model class for battery service
 *
 */
@property (nonatomic, strong) BatteryServiceModel *batteryModel;

/*!
 *  @method startDiscoverBarometerCharacteristicsWithHandler:
 *
 *  @discussion Method to start discover characteristics for barometer service
 *
 */
-(void) startDiscoverBarometerCharacteristicsWithHandler:(void (^) (BOOL success, NSError *error))handler;

/*!
 *  @method startDiscoverAccelerometerCharacteristicsWithHandler:
 *
 *  @discussion Method to start discover characteristics for acclerometer service
 *
 */
-(void) startDiscoverAccelerometerCharacteristicsWithHandler:(void (^) (BOOL success, NSError *error))handler;

/*!
 *  @method startDiscoverTemperatureCharacteristicsWithHandler:
 *
 *  @discussion Method to start discover characteristics for temperature service
 *
 */
-(void) startDiscoverTemperatureCharacteristicsWithHandler:(void (^) (BOOL success, NSError *error))handler;

/*!
 *  @method startDiscoverBatteryCharacteristicsWithHandler:
 *
 *  @discussion Method to start discover characteristics for battery service
 *
 */
-(void) startDiscoverBatteryCharacteristicsWithHandler:(void (^) (BOOL success, NSError *error))handler;

/*!
 *  @method startUpdateAccelerometerXYZValueswithHandler:
 *
 *  @discussion Method to start updating the accelerometer X,Y and Z coordinate values
 *
 */
-(void) startUpdateAccelerometerXYZValueswithHandler:(void (^) (BOOL success, NSError *error))handler;

/*!
 *  @method readValuesForAccelerometerCharacteristicsWithHandler:
 *
 *  @discussion Method to handle reading values for accelerometer characteristics
 *
 */

-(void) readValuesForAccelerometerCharacteristicsWithHandler:(void (^) (BOOL success, NSError *error))handler;

/*!
 *  @method startUpdateBarometerPressureValueWithHandler
 *
 *  @discussion Method to start updating barometer pressure value reading
 *
 */
-(void) startUpdateBarometerPressureValueWithHandler:(void (^) (BOOL success, NSError *error))handler;

/*!
 *  @method readValuesForBarometerCharacteristicsWithHandler:
 *
 *  @discussion Method to handle reading values for barometer characteristics
 *
 */
-(void) readValuesForBarometerCharacteristicsWithHandler:(void (^) (BOOL success, NSError *error))handler;

/*!
 *  @method startUpdateTemperatureValueCharacteristicWithHandler:
 *
 *  @discussion Method to start updating temperature reading
 *
 */
-(void) startUpdateTemperatureValueCharacteristicWithHandler:(void (^) (BOOL success, NSError *error))handler;

/*!
 *  @method readValuesForTemperatureCharacteristicsWithHandler:
 *
 *  @discussion Method to handle reading values for temperature characteristics
 *
 */
-(void) readValuesForTemperatureCharacteristicsWithHandler:(void (^) (BOOL success, NSError *error))handler;

/*!
 *  @method startDiscoverImmediateAlertCharacteristicsWithHandler:
 *
 *  @discussion Method to start discover characteristics for immediate alert service
 *
 */

-(void) startDiscoverImmediateAlertCharacteristicsWithHandler:(void (^) (BOOL success, NSError *error))handler;

/*!
 *  @method stopUpdate
 *
 *  @discussion Method to stop updation of values of different characteristics
 *
 */
-(void) stopUpdate;

@end
