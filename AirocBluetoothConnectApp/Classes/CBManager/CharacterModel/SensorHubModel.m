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

#import "SensorHubModel.h"
#import "Constants.h"

/*!
 *  @class SensorHubModel
 *
 *  @discussion Class to handle and co-ordinate all the sevices associated with sensor hub
 *
 */

@interface SensorHubModel () <cbCharacteristicManagerDelegate>
{
    NSArray *servicesArray;
    
    void(^accelerometerCharactristicDiscoverHandler)(BOOL success, NSError *error);
    void(^barometerCharactristicDiscoverHandler)(BOOL success, NSError *error);
    void(^temperatureCharactristicDiscoverHandler)(BOOL success, NSError *error);
    
    void (^accelerometerXYZcharacteristicHandler)(BOOL success, NSError *error);
    void (^accelerometerCharacteristicsHandler)(BOOL success, NSError *error);
    
    void (^barometerPressureValueUpdationHandler)(BOOL success, NSError *error);
    void (^barometerCharacteristicsHandler)(BOOL success, NSError *error);
    
    void (^temperatureValueUpdationHandler)(BOOL success, NSError *error);
    void (^temperatureCharacteristicsHandler)(BOOL success, NSError *error);

    void (^immedieteAlertCharacteristicsDiscoverHandler)(BOOL success, NSError *error);
    void (^batteryServiceCharacteristicsDiscoverHandler)(BOOL success, NSError *error);

}

@end



@implementation SensorHubModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[CyCBManager sharedManager] setCbCharacteristicDelegate:self];
        servicesArray = [[CyCBManager sharedManager] foundServices];
        
        _accelerometer = [[AccelerometerModel alloc] init];
        _barometer = [[BarometerModel alloc] init];
        _temperatureSensor = [[TemperatureModel alloc] init];
        _findMeModel = [[FindMeModel alloc] init];
    }
    return self;
}

#pragma mark - Discover service characteristics

/*!
 *  @method startDiscoverBarometerCharacteristicsWithHandler:
 *
 *  @discussion Method to start discover characteristics for barometer service
 *
 */

-(void) startDiscoverBarometerCharacteristicsWithHandler:(void (^) (BOOL success, NSError *error))handler
{
    barometerCharactristicDiscoverHandler = handler;
    
    for (CBService *service in servicesArray)
    {
        if ([service.UUID isEqual:BAROMETER_SERVICE_UUID])
        {
            [[[CyCBManager sharedManager] myPeripheral] discoverCharacteristics:nil forService:service];
            break;
        }
    }

}

/*!
 *  @method startDiscoverAccelerometerCharacteristicsWithHandler:
 *
 *  @discussion Method to start discover characteristics for acclerometer service
 *
 */
-(void) startDiscoverAccelerometerCharacteristicsWithHandler:(void (^) (BOOL success, NSError *error))handler
{
    accelerometerCharactristicDiscoverHandler = handler;
    
    for (CBService *service in servicesArray)
    {
        if ([service.UUID isEqual:ACCELEROMETER_SERVICE_UUID])
        {
            [[[CyCBManager sharedManager] myPeripheral] discoverCharacteristics:nil forService:service];
            break;
        }
    }
}

/*!
 *  @method startDiscoverTemperatureCharacteristicsWithHandler:
 *
 *  @discussion Method to start discover characteristics for temperature service
 *
 */
-(void) startDiscoverTemperatureCharacteristicsWithHandler:(void (^) (BOOL success, NSError *error))handler
{
    temperatureCharactristicDiscoverHandler = handler;
    
    for (CBService *service in servicesArray)
    {
        if ([service.UUID isEqual:ANALOG_TEMPERATURE_SERVICE_UUID])
        {
            [[[CyCBManager sharedManager] myPeripheral] discoverCharacteristics:nil forService:service];
            break;
        }
    }

}

/*!
 *  @method startDiscoverImmediateAlertCharacteristicsWithHandler:
 *
 *  @discussion Method to start discover characteristics for immediate alert service
 *
 */

-(void) startDiscoverImmediateAlertCharacteristicsWithHandler:(void (^) (BOOL success, NSError *error))handler
{
    immedieteAlertCharacteristicsDiscoverHandler = handler;
    
    for (CBService *service in servicesArray)
    {
        if ([service.UUID isEqual:IMMEDIATE_ALERT_SERVICE_UUID])
        {
            [[[CyCBManager sharedManager] myPeripheral] discoverCharacteristics:nil forService:service];
            break;
        }
    }
}

/*!
 *  @method startDiscoverBatteryCharacteristicsWithHandler:
 *
 *  @discussion Method to start discover characteristics for battery service
 *
 */
-(void) startDiscoverBatteryCharacteristicsWithHandler:(void (^) (BOOL success, NSError *error))handler
{
    batteryServiceCharacteristicsDiscoverHandler = handler;
    
    for (CBService *service in servicesArray)
    {
        if ([service.UUID isEqual:BATTERY_LEVEL_SERVICE_UUID])
        {
            [[[CyCBManager sharedManager] myPeripheral] discoverCharacteristics:nil forService:service];
            break;
        }
    }
}


#pragma mark - Handling service characteristics

/*!
 *  @method startUpdateAccelerometerXYZValueswithHandler:
 *
 *  @discussion Method to start updating the accelerometer X,Y and Z coordinate values
 *
 */
-(void) startUpdateAccelerometerXYZValueswithHandler:(void (^) (BOOL success, NSError *error))handler
{
    accelerometerXYZcharacteristicHandler = handler;
    [_accelerometer updateXYZCharacteristics];
}

/*!
 *  @method readValuesForAccelerometerCharacteristicsWithHandler:
 *
 *  @discussion Method to handle reading values for accelerometer characteristics
 *
 */

-(void) readValuesForAccelerometerCharacteristicsWithHandler:(void (^) (BOOL success, NSError *error))handler
{
    accelerometerCharacteristicsHandler = handler;
    [_accelerometer readAccelerometerCharacteristics];
}

/*!
 *  @method startUpdateBarometerPressureValueWithHandler
 *
 *  @discussion Method to start updating barometer pressure value reading
 *
 */

-(void) startUpdateBarometerPressureValueWithHandler:(void (^) (BOOL success, NSError *error))handler
{
    barometerPressureValueUpdationHandler = handler;
    [_barometer updateValueForPressure];
}


/*!
 *  @method readValuesForBarometerCharacteristicsWithHandler:
 *
 *  @discussion Method to handle reading values for barometer characteristics
 *
 */

-(void) readValuesForBarometerCharacteristicsWithHandler:(void (^) (BOOL success, NSError *error))handler
{
    barometerCharacteristicsHandler = handler;
    [_barometer readValueForCharacteristics];
}


/*!
 *  @method startUpdateTemperatureValueCharacteristicWithHandler:
 *
 *  @discussion Method to start updating temperature reading
 *
 */

-(void) startUpdateTemperatureValueCharacteristicWithHandler:(void (^) (BOOL success, NSError *error))handler
{
    temperatureValueUpdationHandler = handler;
    [_temperatureSensor updateValueForTemperature];
}


/*!
 *  @method readValuesForTemperatureCharacteristicsWithHandler:
 *
 *  @discussion Method to handle reading values for temperature characteristics
 *
 */

-(void) readValuesForTemperatureCharacteristicsWithHandler:(void (^) (BOOL success, NSError *error))handler
{
    temperatureCharacteristicsHandler = handler;
    [_temperatureSensor readValueForTemperatureCharacteristics];
}

/*!
 *  @method stopUpdate
 *
 *  @discussion Method to stop updation of values of different characteristics
 *
 */

-(void) stopUpdate
{
    accelerometerXYZcharacteristicHandler = nil;
    [_accelerometer stopUpdate];
    
    barometerPressureValueUpdationHandler = nil;
    [_barometer stopUpdate];
    
    temperatureValueUpdationHandler = nil;
    [_temperatureSensor stopUpdate];
    
}



#pragma mark - CBCharacteristicManagerDelegate

/*!
 *  @method peripheral: didDiscoverCharacteristicsForService: error:
 *
 *  @discussion Method invoked when characteristics are discovered for a service
 *
 */

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:ACCELEROMETER_SERVICE_UUID])
    {
        [_accelerometer getCharacteristicsForAccelerometerService:service];
        accelerometerCharactristicDiscoverHandler(YES,nil);
    }
    else if ([service.UUID isEqual:BAROMETER_SERVICE_UUID])
    {
        [_barometer getCharacteristicsForBarometerService:service];
        barometerCharactristicDiscoverHandler(YES,nil);
    }
    else if ([service.UUID isEqual:ANALOG_TEMPERATURE_SERVICE_UUID])
    {
        [_temperatureSensor getCharacteristicsForTemperatureService:service];
        temperatureCharactristicDiscoverHandler(YES,nil);
    }
    else if ([service.UUID isEqual:IMMEDIATE_ALERT_SERVICE_UUID])
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            if ([characteristic.UUID isEqual:ALERT_CHARACTERISTIC_UUID])
            {
                _findMeModel.immediateAlertCharacteristic = characteristic;
                immedieteAlertCharacteristicsDiscoverHandler(YES,nil);
            }
        }
        
        immedieteAlertCharacteristicsDiscoverHandler(NO,error);
    }
    else if ([service.UUID isEqual:BATTERY_LEVEL_SERVICE_UUID])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            // Checking for the required characteristic
            if ([aChar.UUID isEqual:BATTERY_LEVEL_CHARACTERISTIC_UUID])
            {
                _batteryModel.batteryCharacterisic = aChar;
                batteryServiceCharacteristicsDiscoverHandler(YES,nil);
            }
            
        }
    }
}

/*!
 *  @method peripheral: didUpdateValueForCharacteristic: error:
 *
 *  @discussion Method invoked when the characteristic value changes or indicated
 *
 */

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.service.UUID isEqual:ACCELEROMETER_SERVICE_UUID])
    {
        if ([characteristic.UUID isEqual:ACCELEROMETER_READING_X_CHARACTERISTIC_UUID] || [characteristic.UUID isEqual:ACCELEROMETER_READING_Y_CHARACTERISTIC_UUID] || [characteristic.UUID isEqual:ACCELEROMETER_READING_Z_CHARACTERISTIC_UUID])
        {
            [_accelerometer getXYZValuesWithCharacteristic:characteristic];
            accelerometerXYZcharacteristicHandler(YES,nil);
        }
        else
        {
            [_accelerometer getValuesForAcclerometerCharacteristics:characteristic];
            
            if (accelerometerCharacteristicsHandler != nil) {
                accelerometerCharacteristicsHandler(YES,nil);
            }
        }
    }
    else if ([characteristic.service.UUID isEqual:BAROMETER_SERVICE_UUID])
    {
        
        if ([characteristic.UUID isEqual:BAROMETER_READING_CHARACTERISTIC_UUID])
        {
            [_barometer getValuesForBarometerCharacteristics:characteristic];
            barometerPressureValueUpdationHandler(YES,nil);
        }
        else
        {
            [_barometer getValuesForBarometerCharacteristics:characteristic];
            
            if (barometerCharacteristicsHandler != nil) {
                barometerCharacteristicsHandler(YES,nil);
            }
        }
    }
    else if ([characteristic.service.UUID isEqual:ANALOG_TEMPERATURE_SERVICE_UUID])
    {
        if ([characteristic.UUID isEqual:TEMPERATURE_READING_CHARACTERISTIC_UUID])
        {
            [_temperatureSensor getValuesForTemperatureCharacteristics:characteristic];
            temperatureValueUpdationHandler(YES,nil);
        }
        else
        {
            [_temperatureSensor getValuesForTemperatureCharacteristics:characteristic];
            
            if (temperatureCharacteristicsHandler != nil) {
                temperatureCharacteristicsHandler(YES,nil);
            }
        }
    }
    else if([characteristic.service.UUID isEqual:BATTERY_LEVEL_SERVICE_UUID])
    {
        if ([characteristic.UUID isEqual:BATTERY_LEVEL_CHARACTERISTIC_UUID])
        {
            [_batteryModel handleBatteryCharacteristicValueWithChar:characteristic];
        }
    }
}


@end
