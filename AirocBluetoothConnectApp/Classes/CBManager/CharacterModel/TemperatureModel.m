/*
 * Copyright 2014-2023, Cypress Semiconductor Corporation (an Infineon company) or
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

#import "TemperatureModel.h"
#import "Constants.h"

/*!
 *  @class TemperatureModel
 *
 *  @discussion Class to handle the temperature service related operations
 *
 */

@interface TemperatureModel ()
{
    CBCharacteristic *sensorTypeCharacteristic, *sensorScanintervalCharacteristic, *temperatureReadCharacteristic;

}
@end


@implementation TemperatureModel

/*!
 *  @method stopUpdate
 *
 *  @discussion Method to stop update
 *
 */

-(void) stopUpdate
{
    if (temperatureReadCharacteristic != nil)
    {
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:ANALOG_TEMPERATURE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:temperatureReadCharacteristic.UUID] descriptor:nil operation:STOP_NOTIFY];

        [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:NO forCharacteristic:temperatureReadCharacteristic];
    }
}

/*!
 *  @method writeValueForTemperatureSensorScanInterval:
 *
 *  @discussion Method to write value for temperature scan interval
 *
 */

-(void) writeValueForTemperatureSensorScanInterval:(int) newScanInterval
{
    uint8_t val = newScanInterval; // The value which you want to write.
    NSData  *valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
    [[[CyCBManager sharedManager] myPeripheral] writeValue:valData forCharacteristic:sensorScanintervalCharacteristic type:CBCharacteristicWriteWithoutResponse];

    [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:sensorScanintervalCharacteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:sensorScanintervalCharacteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",WRITE_REQUEST,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:valData]]];
}

/*!
 *  @method getCharacteristicsForTemperatureService:
 *
 *  @discussion Method to get characteristics for temperature service
 *
 */

-(void) getCharacteristicsForTemperatureService:(CBService *) service
{
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        if ([characteristic.UUID isEqual:TEMPERATURE_ANALOG_SENSOR_CHARACTERISTIC_UUID])
        {
            sensorTypeCharacteristic = characteristic;
        }
        else if([characteristic.UUID isEqual:TEMPERATURE_SENSOR_SCAN_INTERVAL_CHARACTERISTIC_UUID])
        {
            sensorScanintervalCharacteristic = characteristic;
        }
        else if([characteristic.UUID isEqual:TEMPERATURE_READING_CHARACTERISTIC_UUID])
        {
            temperatureReadCharacteristic = characteristic;
        }
    }

}

/*!
 *  @method getValuesForTemperatureCharacteristics:
 *
 *  @discussion Method to get values for temperature characteristics
 *
 */

-(void) getValuesForTemperatureCharacteristics:(CBCharacteristic *) characteristic
{
    NSData *dataValue = characteristic.value;
    const uint8_t *reportData = (uint8_t *)[dataValue bytes];

    if ([characteristic.UUID isEqual:TEMPERATURE_ANALOG_SENSOR_CHARACTERISTIC_UUID])
    {
        _sensorTypeString = [NSString stringWithFormat:@"%d",reportData[0]];

        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",READ_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:dataValue]]];

    }
    else if ([characteristic.UUID isEqual:TEMPERATURE_SENSOR_SCAN_INTERVAL_CHARACTERISTIC_UUID])
    {
        _sensorScanIntervalString = [NSString stringWithFormat:@"%d",reportData[0]];

        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",READ_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:dataValue]]];

    }
    else if ([characteristic.UUID isEqual:TEMPERATURE_READING_CHARACTERISTIC_UUID])
    {
        double tempValue = CFSwapInt32LittleToHost(*(uint32_t *) &reportData[0]);
        _temperatureValueString = [NSString stringWithFormat:@"%f",tempValue];

        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",NOTIFY_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:dataValue]]];

    }
}

/*!
 *  @method updateValueForTemperature
 *
 *  @discussion Method to set notification for temperature value
 *
 */
-(void) updateValueForTemperature
{
    if (temperatureReadCharacteristic != nil)
    {
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:temperatureReadCharacteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:temperatureReadCharacteristic.UUID] descriptor:nil operation:START_NOTIFY];

        [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:YES forCharacteristic:temperatureReadCharacteristic];
    }
}

/*!
 *  @method readValueFortemperatureCharacteristics
 *
 *  @discussion Method to read values for temperature sensor scan interval and sensor type
 *
 */
-(void) readValueForTemperatureCharacteristics
{
    if (sensorScanintervalCharacteristic != nil)
    {
        [[[CyCBManager sharedManager] myPeripheral] readValueForCharacteristic:sensorScanintervalCharacteristic];

        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:sensorScanintervalCharacteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:sensorScanintervalCharacteristic.UUID] descriptor:nil operation:READ_REQUEST];
    }

    if (sensorTypeCharacteristic != nil)
    {
        [[[CyCBManager sharedManager] myPeripheral] readValueForCharacteristic:sensorTypeCharacteristic];

        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:sensorTypeCharacteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:sensorTypeCharacteristic.UUID] descriptor:nil operation:READ_REQUEST];
    }

}


@end
