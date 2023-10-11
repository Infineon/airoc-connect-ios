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

#import "AccelerometerModel.h"
#import "Constants.h"

/*!
 *  @class AccelerometerModel
 *
 *  @discussion Class to handle the accelerometer service related operations
 *
 */

@interface AccelerometerModel ()
{
    NSMutableArray *XYZCharacteristicsArray;
    CBCharacteristic *scanIntervalCharacteristic, *sensorTypecharacteristic, *dataAccumulationCharacteristic;
}

@end


@implementation AccelerometerModel

- (instancetype)init
{
    self = [super init];
    if (self) {

        XYZCharacteristicsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

/*!
 *  @method writeValueForAccelerometerSensorScanInterval:
 *
 *  @discussion Method to write value for accelerometer SensorScanInterval
 *
 */
-(void) writeValueForAccelerometerSensorScanInterval:(int) newScanInterval
{
    uint8_t val = (uint8_t)newScanInterval; // The value which you want to write.
    NSData  *valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
    [[[CyCBManager sharedManager] myPeripheral] writeValue:valData forCharacteristic:scanIntervalCharacteristic type:CBCharacteristicWriteWithoutResponse];

    [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:ACCELEROMETER_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:scanIntervalCharacteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",WRITE_REQUEST,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:valData]]];
}

/*!
 *  @method writeValueForAccelerometerFilterconfiguration:
 *
 *  @discussion Method to write value for accelerometer filter configuration
 *
 */

-(void) writeValueForAccelerometerFilterConfiguration:(int) filterconfiguration
{
    uint8_t val = (uint8_t)filterconfiguration; // The value which you want to write.
    NSData  *valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
    [[[CyCBManager sharedManager] myPeripheral] writeValue:valData forCharacteristic:dataAccumulationCharacteristic type:CBCharacteristicWriteWithoutResponse];

    [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:ACCELEROMETER_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:dataAccumulationCharacteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",WRITE_REQUEST,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:valData]]];
}

/*!
 *  @method stopUpdate
 *
 *  @discussion Method to stop update
 *
 */

-(void)stopUpdate
{
    [self updateCharacteristicsNotificationStatus:NO];
}

/*!
 *  @method getCharacteristicsForAccelerometerService
 *
 *  @discussion Method to get the characteristics for accelerometer service
 *
 */

-(void) getCharacteristicsForAccelerometerService:(CBService *) service
{
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        if ([characteristic.UUID isEqual:ACCELEROMETER_READING_X_CHARACTERISTIC_UUID])
        {
            [XYZCharacteristicsArray addObject:characteristic];
        }
        else if ([characteristic.UUID isEqual:ACCELEROMETER_READING_Y_CHARACTERISTIC_UUID])
        {
            [XYZCharacteristicsArray addObject:characteristic];
        }
        else if ([characteristic.UUID isEqual:ACCELEROMETER_READING_Z_CHARACTERISTIC_UUID])
        {
            [XYZCharacteristicsArray addObject:characteristic];
        }
        else if ([characteristic.UUID isEqual:ACCELEROMETER_SENSOR_SCAN_INTERVAL_CHARACTERISTIC_UUID])
        {
            scanIntervalCharacteristic = characteristic;
        }
        else if ([characteristic.UUID isEqual:ACCELEROMETER_DATA_ACCUMULATION_CHARACTERISTIC_UUID])
        {
            dataAccumulationCharacteristic = characteristic;
        }
        else if ([characteristic.UUID isEqual:ACCELEROMETER_ANALOG_SENSOR_CHARACTERISTIC_UUID])
        {
            sensorTypecharacteristic = characteristic;
        }
    }

}

/*!
 *  @method updateXYZCharacteristics
 *
 *  @discussion Method to set notify for accelerometer X,Y and Z values
 *
 */

-(void) updateXYZCharacteristics
{
    [self updateCharacteristicsNotificationStatus:YES];
}

/*!
 *  @method updateCharacteristicsNotificationStatus:
 *
 *  @discussion Method to update the notification status of x,y and z characteristics
 *
 */
-(void) updateCharacteristicsNotificationStatus:(BOOL)status
{
    if ([XYZCharacteristicsArray count] > 0)
    {
        for (CBCharacteristic *characteristic in XYZCharacteristicsArray)
        {
            [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:status forCharacteristic:characteristic];

            if (status)
            {
                [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:ACCELEROMETER_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:START_NOTIFY];
            }
            else
            {
                 [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:ACCELEROMETER_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:STOP_NOTIFY];
            }
        }
    }
}



/*!
 *  @method readAccelerometerCharacteristics
 *
 *  @discussion Method to read values for different accelerometer characteristics
 *
 */

-(void) readAccelerometerCharacteristics
{

    if (scanIntervalCharacteristic != nil)
    {
        [[[CyCBManager sharedManager] myPeripheral] readValueForCharacteristic:scanIntervalCharacteristic];

        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:ACCELEROMETER_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:scanIntervalCharacteristic.UUID] descriptor:nil operation:READ_REQUEST];
    }

    if (dataAccumulationCharacteristic != nil)
    {
        [[[CyCBManager sharedManager] myPeripheral] readValueForCharacteristic:dataAccumulationCharacteristic];

        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:ACCELEROMETER_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:dataAccumulationCharacteristic.UUID] descriptor:nil operation:READ_REQUEST];
    }

    if (sensorTypecharacteristic != nil)
    {
        [[[CyCBManager sharedManager] myPeripheral] readValueForCharacteristic:sensorTypecharacteristic];

        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:ACCELEROMETER_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:sensorTypecharacteristic.UUID] descriptor:nil operation:READ_REQUEST];
    }
}


/*!
 *  @method getXYZValuesWithCharacteristic:
 *
 *  @discussion Method to get the accelerometer X,Y and Z values
 *
 */


-(void) getXYZValuesWithCharacteristic:(CBCharacteristic *)characteristic
{
    NSData *data = [characteristic value];
    const uint8_t *reportData = (uint8_t *)[data bytes];

    if ([characteristic.UUID isEqual:ACCELEROMETER_READING_X_CHARACTERISTIC_UUID])
    {
        _xValue = CFSwapInt16LittleToHost(*(uint16_t *) &reportData[0]);
    }
    else if ([characteristic.UUID isEqual:ACCELEROMETER_READING_Y_CHARACTERISTIC_UUID])
    {
        _yValue = CFSwapInt16LittleToHost(*(uint16_t *) &reportData[0]);
    }
    else if ([characteristic.UUID isEqual:ACCELEROMETER_READING_Z_CHARACTERISTIC_UUID])
    {
        _zValue = CFSwapInt16LittleToHost(*(uint16_t *) &reportData[0]);
    }

    [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",NOTIFY_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:data]]];
}

/*!
 *  @method getValuesForAcclerometerCharacteristics:
 *
 *  @discussion Method to parse values for different accelerometer characteristics
 *
 */
-(void) getValuesForAcclerometerCharacteristics:(CBCharacteristic *)characteristic
{
    NSData *data = [characteristic value];
    const uint8_t *reportData = (uint8_t *)[data bytes];

    if ([characteristic.UUID isEqual:ACCELEROMETER_SENSOR_SCAN_INTERVAL_CHARACTERISTIC_UUID])
    {
        _scanIntervalString = [NSString stringWithFormat:@"%d",reportData[0]];
    }
    else if ([characteristic.UUID isEqual:ACCELEROMETER_DATA_ACCUMULATION_CHARACTERISTIC_UUID])
    {
        _filterTypeConfigurationString = [NSString stringWithFormat:@"%d",reportData[0]];
    }
    else if ([characteristic.UUID isEqual:ACCELEROMETER_ANALOG_SENSOR_CHARACTERISTIC_UUID])
    {
        _sensorTypeString = [NSString stringWithFormat:@"%d",reportData[0]];
    }

    [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",READ_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:data]]];

}




@end
