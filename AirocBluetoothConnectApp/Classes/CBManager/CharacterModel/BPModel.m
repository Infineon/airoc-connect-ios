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

#import "BPModel.h"
#import "CyCBManager.h"
#import "Constants.h"

/*!
 *  @class BPModel
 *
 *  @discussion Class to handle the blood pressure service related operations
 *
 */

@interface BPModel ()<cbCharacteristicManagerDelegate>
{
    void(^cbCharacteristicHandler)(BOOL success, NSError *error);
    void(^cbcharacteristicDiscoverHandler)(BOOL success, NSError *error);
    
    CBCharacteristic *bpCharacteristic;
}

@end

@implementation BPModel

/*!
 *  @method startDiscoverChar:
 *
 *  @discussion Discovers the specified characteristics of a service..
 */

-(void)startDiscoverChar:(void (^) (BOOL success, NSError *error))handler
{
    cbcharacteristicDiscoverHandler = handler;
    
    [[CyCBManager sharedManager] setCbCharacteristicDelegate:self];
    [[[CyCBManager sharedManager] myPeripheral] discoverCharacteristics:nil forService:[[CyCBManager sharedManager] myService]];
}

/*!
 *  @method updateCharacteristicWithHandler:
 *
 *  @discussion Sets notifications or indications for the value of a specified characteristic.
 */
-(void)updateCharacteristicWithHandler:(void (^) (BOOL success, NSError *error))handler
{
    cbCharacteristicHandler = handler;
    
    if (bpCharacteristic)
    {
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:BP_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:BP_MEASUREMENT_CHARACTERISTIC_UUID] descriptor:nil operation:START_NOTIFY];
        
        [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:YES forCharacteristic:bpCharacteristic];
    }
}

/*!
 *  @method stopUpdate
 *
 *  @discussion Stop notifications or indications for the value of a specified characteristic.
 */

-(void)stopUpdate
{
    cbCharacteristicHandler = nil;
    
    if (bpCharacteristic)
    {
        if (bpCharacteristic.isNotifying)
        {
            [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:NO forCharacteristic:bpCharacteristic];
            
            [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:BP_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:BP_MEASUREMENT_CHARACTERISTIC_UUID] descriptor:nil operation:STOP_NOTIFY];
        }
    }
}

#pragma mark - characteristicManager delegate

/*!
 *  @method peripheral: didDiscoverCharacteristicsForService: error:
 *
 *  @discussion Method invoked when characteristics are discovered for a service
 *
 */

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:BP_SERVICE_UUID])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            // Checking for required characteristic
            if ([aChar.UUID isEqual:BP_MEASUREMENT_CHARACTERISTIC_UUID])
            {
                bpCharacteristic = aChar;
                cbcharacteristicDiscoverHandler(YES,nil);
            }
        }
    }
}

/*!
 *  @method peripheral: didUpdateValueForCharacteristic: error:
 *
 *  @discussion Method invoked when the characteristic value changes
 *
 */

-(void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:BP_MEASUREMENT_CHARACTERISTIC_UUID])
    {
        if (error == nil)
        {
            [self getBloodPressureDataFromChar:characteristic];
            if(cbCharacteristicHandler){
                cbCharacteristicHandler(YES,nil);
            }
        }
        else
        {
            if(cbCharacteristicHandler){
                cbCharacteristicHandler(NO,error);
            }
        }
    }
}


/*!
 *  @method getBloodPressureDataFromChar:
 *
 *  @discussion   Instance method to get the blood pressure value
 *
 */
-(void) getBloodPressureDataFromChar:(CBCharacteristic *)characteristic
{
    NSData *data = [characteristic value];
    const uint8_t *reportData = (uint8_t *)[data bytes];
    
    // Checking the flag
    
    if (!(reportData[0] & 0x00))
    {
        // BP details in units of mmHg
        _bloodPressureUnitString = BLOOD_PRESSURE_UNIT_mmHg;
        
    }
    else
    {
        //BP details in units of kPa
        _bloodPressureUnitString = BLOOD_PRESSURE_UNIT_kPa;
    }
    
     int16_t systolicData = (int16_t) CFSwapInt16LittleToHost(*(int16_t *) &reportData[1]);
    _systolicPressureValue = [Utilities convertSFLOATFromData:systolicData];
    
    int16_t diastolicData = (int16_t) CFSwapInt16LittleToHost(*(int16_t *) &reportData[3]);
    _diastolicPressureValue = [Utilities convertSFLOATFromData:diastolicData];
    
    if (cbCharacteristicHandler != nil) {
        cbCharacteristicHandler(YES,nil);
    }
    
     [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",NOTIFY_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:data]]];
}

@end
