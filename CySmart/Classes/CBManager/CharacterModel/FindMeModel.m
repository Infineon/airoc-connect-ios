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

#import "FindMeModel.h"

/*!
 *  @class FindMeModel
 *
 *  @discussion Class to handle the link loss, immediete alert and transmission power related operations
 *
 */

@interface FindMeModel ()<cbCharacteristicManagerDelegate>
{
    void(^cbCharacteristicDiscoverHandler)(CBService *foundService,BOOL success, NSError *error);
    void(^cbTransmissionPowerCharacteristicHandler)(BOOL success, NSError *error);
    void(^cbLinkLossCharacteristicHandler)(BOOL success, NSError *error);
    void(^cbImmedieteAlertCharacteristicHandler)(BOOL success, NSError *error);
    
    CBCharacteristic *transmissionPowerCharacteristic;
    CBCharacteristic *linkLossCharacteristic;
}

@end


@implementation FindMeModel

/*!
 *  @method startDiscoverCharacteristicsForService: withCompletionHandler:
 *
 *  @discussion Discovers the characteristics of a specified service..
 */

-(void)startDiscoverCharacteristicsForService:(CBService *)service withCompletionHandler:(void (^) (CBService *foundService,BOOL success, NSError *error))handler
{
    cbCharacteristicDiscoverHandler = handler;
    
    [[CyCBManager sharedManager] setCbCharacteristicDelegate:self];
    [[[CyCBManager sharedManager] myPeripheral] discoverCharacteristics:nil forService:service];;
}

/*!
 *  @method updateProximityCharacteristicWithHandler:WithHandler
 *
 *  @discussion Read value from transmission power characteristic.
 */

-(void)updateProximityCharacteristicWithHandler:(void (^) (BOOL success, NSError *error))handler
{
    cbTransmissionPowerCharacteristicHandler = handler;
    [self logFindMeDataWithService:transmissionPowerCharacteristic.service characteristic:transmissionPowerCharacteristic data:READ_REQUEST];
    [[[CyCBManager sharedManager] myPeripheral] readValueForCharacteristic:transmissionPowerCharacteristic];
}

/*!
 *  @method updateLinkLossCharacteristicValue:WithHandler
 *
 *  @discussion Write value to link loss characteristic.
 */

-(void)updateLinkLossCharacteristicValue:(enum alertOptions)option WithHandler:(void (^) (BOOL success, NSError *error))handler
{
    cbLinkLossCharacteristicHandler = handler;
    
    uint8_t val = option; // The value which you want to write.
    NSData* valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
    
    [self logFindMeDataWithService:linkLossCharacteristic.service characteristic:linkLossCharacteristic data:[NSString stringWithFormat:@"%@%@ %@",WRITE_REQUEST,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:valData]]];
    [[[CyCBManager sharedManager] myPeripheral] writeValue:valData forCharacteristic:linkLossCharacteristic type:CBCharacteristicWriteWithResponse];
}

/*!
 *  @method updateImmedieteALertCharacteristicValue:WithHandler
 *
 *  @discussion Write value to a immediete alert characteristic.
 */

-(void)updateImmedieteALertCharacteristicValue:(enum alertOptions)option withHandler:(void (^) (BOOL success, NSError *error))handler
{
    cbImmedieteAlertCharacteristicHandler = handler;

    uint8_t val = option; // The value which you want to write.
    NSData* valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
    
    [[[CyCBManager sharedManager] myPeripheral] writeValue:valData forCharacteristic:_immediateAlertCharacteristic type:CBCharacteristicWriteWithoutResponse];
    [self logFindMeDataWithService:_immediateAlertCharacteristic.service characteristic:_immediateAlertCharacteristic data:[NSString stringWithFormat:@"%@%@ %@",WRITE_REQUEST,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:valData]]];
    
    cbImmedieteAlertCharacteristicHandler(YES,nil);
}

/*!
 *  @method stopUpdate
 *
 *  @discussion Stop notifications or indications for the value of a specified characteristic.
 */

-(void)stopUpdate
{
    cbTransmissionPowerCharacteristicHandler = nil;
    cbLinkLossCharacteristicHandler = nil;
    cbImmedieteAlertCharacteristicHandler = nil;
}


#pragma mark - CBCharacteristicManagerDelegate

/*!
 *  @method peripheral: didDiscoverCharacteristicsForService: error:
 *
 *  @discussion Method invoked when characteristics are discovered for a service
 *
 */

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:TRANSMISSION_POWER_SERVICE]|[service.UUID isEqual:LINK_LOSS_SERVICE_UUID] | [service.UUID isEqual:IMMEDIATE_ALERT_SERVICE_UUID])
    {
        
        /* Read the Tx Power Level characteristic which represents the current transmit power level of a physical layer from the characteristic .
         */
        if ([service.UUID isEqual:TRANSMISSION_POWER_SERVICE])
        {
            for (CBCharacteristic *aChar in service.characteristics)
            {
                if ([aChar.UUID isEqual:TRANSMISSION_POWER_LEVEL_UUID])
                {
                    transmissionPowerCharacteristic = aChar;
                    _isTransmissionPowerPresent = YES;
                }
            }
        }
        
        /*
         Read the Alert Level from characteristic, which is used to expose the current link loss alert level that is used to determine how the device alerts when the link is lost.
         */
        
        if ([service.UUID isEqual:LINK_LOSS_SERVICE_UUID])
        {
            for (CBCharacteristic *aChar in service.characteristics)
            {
                if ([aChar.UUID isEqual:ALERT_CHARACTERISTIC_UUID])
                {
                    linkLossCharacteristic = aChar;
                    _isLinkLossServicePresent = YES;
                }
            }
        }
        
        /* Read the  Alert Level from characteristic, which is a control point that allows a peer to command this device to alert to a given leve
         */
        
        if ([service.UUID isEqual:IMMEDIATE_ALERT_SERVICE_UUID])
        {
            for (CBCharacteristic *aChar in service.characteristics)
            {
                if ([aChar.UUID isEqual:ALERT_CHARACTERISTIC_UUID])
                {
                    _immediateAlertCharacteristic = aChar;
                    _isImmediateAlertServicePresent = YES;
                }
            }
        }

        if (_isImmediateAlertServicePresent || _isLinkLossServicePresent || _isTransmissionPowerPresent)
        {
            cbCharacteristicDiscoverHandler(service,YES,nil);
        }
        else
        {
            cbCharacteristicDiscoverHandler(service, NO,error);
        }
        
    }
    else
        cbCharacteristicDiscoverHandler(service,NO,error);
}

/*!
 *  @method peripheral: didUpdateValueForCharacteristic: error:
 *
 *  @discussion Method invoked when the characteristic value changes
 *
 */

-(void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:transmissionPowerCharacteristic.UUID])
    {
        NSData *data = [characteristic value];
        SInt8 *dataPointer = (SInt8 *)[data bytes];
        
        _transmissionPowerValue = dataPointer[0];
        
        // Data logging
        [self logFindMeDataWithService:transmissionPowerCharacteristic.service characteristic:transmissionPowerCharacteristic data:[NSString stringWithFormat:@"%@%@ %@",READ_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:data]]];
        
        if (cbTransmissionPowerCharacteristicHandler != nil)
        {
            cbTransmissionPowerCharacteristicHandler(YES,nil);
        }
        
        [self logFindMeDataWithService:transmissionPowerCharacteristic.service characteristic:transmissionPowerCharacteristic data:READ_REQUEST];
        
        [[[CyCBManager sharedManager] myPeripheral] readValueForCharacteristic:transmissionPowerCharacteristic];

    }
    else if ([characteristic.UUID isEqual:_immediateAlertCharacteristic.UUID])
    {
        
    }
    else
    {
        if (cbTransmissionPowerCharacteristicHandler != nil)
        {
            cbTransmissionPowerCharacteristicHandler(NO,nil);
        }
    }
}

/*!
 *  @method peripheral: didWriteValueForCharacteristic: error:
 *
 *  @discussion Method invoked when write value to the device with response
 *
 */

-(void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:linkLossCharacteristic.UUID])
    {
        if (error == nil)
        {
            [self logFindMeDataWithService:linkLossCharacteristic.service characteristic:linkLossCharacteristic data:[NSString stringWithFormat:@"%@- %@",WRITE_REQUEST_STATUS,WRITE_SUCCESS]];
            cbLinkLossCharacteristicHandler(YES,nil);
            
        }
        else
        {
            [self logFindMeDataWithService:linkLossCharacteristic.service characteristic:linkLossCharacteristic data:[NSString stringWithFormat:@"%@- %@%@",WRITE_REQUEST_STATUS,WRITE_ERROR,[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
            cbLinkLossCharacteristicHandler(NO,error);
            
        }
    }
}

/*!
 *  @method logFindMeDataWithService: characteristic: data:
 *
 *  @discussion Method to log details of various operations
 *
 */
-(void) logFindMeDataWithService:(CBService *)service characteristic:(CBCharacteristic *)characteristic data:(NSString *)dataString
{
    [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:dataString];
}


@end
