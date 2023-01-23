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

#import "HRMModel.h"
#import "CyCBManager.h"

#define MAX_NUM_RR_INTERVALS 3 // Display up to 3 RR intervals

/*!
 *  @class HRMModel
 *
 *  @discussion Class to handle the heart rate measurement service related operations
 *
 */

@interface HRMModel()<cbCharacteristicManagerDelegate>
{
    void (^cbCharacteristicUpdateHandler)(BOOL success, NSError *error);
    void (^cbCharacteristicDiscoveryHandler)(BOOL success, NSError *error);
}

@end


@implementation HRMModel

@synthesize bpmValue;
@synthesize sensorLocation;
@synthesize sensorContact;
@synthesize RRinterval;
@synthesize energyExpended;

/*!
 *  @method discoverCharacteristicsWithHandler:
 *
 *  @discussion Discovers characteristics of the service
 */
-(void)discoverCharacteristicsWithHandler:(void (^) (BOOL success, NSError *error))handler {
    cbCharacteristicDiscoveryHandler = handler;
    [[CyCBManager sharedManager] setCbCharacteristicDelegate:self];
    [[[CyCBManager sharedManager] myPeripheral] discoverCharacteristics:nil forService:[[CyCBManager sharedManager] myService]];
}

/*!
 *  @method setCharacteristicUpdateHandler:
 *
 *  @discussion Sets notifications or indications for the value of a specified characteristic.
 */
-(void)setCharacteristicUpdateHandler:(void (^) (BOOL success, NSError *error))handler {
    cbCharacteristicUpdateHandler = handler;
}

/*!
 *  @method stopUpdate
 *
 *  @discussion Stop notifications or indications for the value of a specified characteristic.
 */
-(void)stopUpdate {
    cbCharacteristicUpdateHandler = nil;
    if ([[[CyCBManager sharedManager] myService].UUID isEqual:HRM_HEART_RATE_SERVICE_UUID]) {
        for (CBCharacteristic *aChar in [[CyCBManager sharedManager] myService].characteristics) {
            if ([aChar.UUID isEqual:HRM_CHARACTERISTIC_UUID]) {
                if (aChar.isNotifying) {
                    [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:NO  forCharacteristic:aChar];
                    [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:HRM_HEART_RATE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:HRM_CHARACTERISTIC_UUID] descriptor:nil operation:STOP_NOTIFY];
                }
                cbCharacteristicDiscoveryHandler(YES,nil);
                break;
            }
        }
    }
}


#pragma mark - CBCharecteristicManger

/*!
 *  @method peripheral: didDiscoverCharacteristicsForService: error:
 *
 *  @discussion Method invoked when characteristics are discovered for a service
 *
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if ([service.UUID isEqual:HRM_HEART_RATE_SERVICE_UUID]) {
        for (CBCharacteristic *aChar in service.characteristics) {
            if ([aChar.UUID isEqual:HRM_CHARACTERISTIC_UUID]) {
                [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:YES forCharacteristic:aChar];
                [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:HRM_HEART_RATE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:HRM_CHARACTERISTIC_UUID] descriptor:nil operation:START_NOTIFY];
                
                cbCharacteristicDiscoveryHandler(YES,nil);
            } else if([aChar.UUID isEqual:HRM_BODY_LOCATION_CHARACTERISTIC_UUID]) {
                [[[CyCBManager sharedManager] myPeripheral] readValueForCharacteristic:aChar];
                [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:HRM_HEART_RATE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:HRM_BODY_LOCATION_CHARACTERISTIC_UUID] descriptor:nil operation:READ_REQUEST];
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
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if(error == nil) {
        if ([characteristic.UUID isEqual:HRM_CHARACTERISTIC_UUID]) {
            [self getHRMDataFromCharacteristic:characteristic error:error];
        } else if ([characteristic.UUID isEqual:HRM_BODY_LOCATION_CHARACTERISTIC_UUID]) {
            [self getBodyLocationFromCharacteristic:characteristic];
        }
        cbCharacteristicUpdateHandler(YES, nil);
    } else {
        cbCharacteristicUpdateHandler(NO, error);
    }
}

/*!
 *  @method getHRMDataFromCharacteristic:error
 *
 *  @discussion Get BPM, Sensor Contact Status, Energy Expended and RR Interval
 *
 */
- (void) getHRMDataFromCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.heart_rate_measurement.xml //
    
    NSData *data = [characteristic value];
    const uint8_t *bytes = [data bytes];
    
    NSUInteger offset = 1;// One byte for Flags field
    
    // Bits Per Minute (BPM)
    if ((bytes[0] & 0x01) == 0) { // BPM as uint8
        self.bpmValue = bytes[1];
        offset = offset + 1;
    }
    else { // BPM as uint16
        self.bpmValue = CFSwapInt16LittleToHost(*(uint16_t *)(&bytes[1]));
        offset =  offset + 2;
    }
    
    // Sensor Contact Status
    if ((bytes[0] & 0x06) == 0x06) { // feature supported and contact detected
        self.sensorContact = SENSOR_CONTACT_DETECTED;
    } else if ((bytes[0] & 0x06) == 0x04) { // feature supported but contact not detected
        self.sensorContact = SENSOR_CONTACT_NOT_DETECTED;
    } else { // feature not supported
        self.sensorContact = SENSOR_CONTACT_NOT_SUPPORTED;
    }
    
    // Energy Expended (EE)
    if (bytes[0] & 0x08) // EE present
    {
        uint16_t ee = CFSwapInt16LittleToHost(*(uint16_t *)(&bytes[offset]));
        self.energyExpended = [NSString stringWithFormat:@"%d", ee];
        offset =  offset + 2;
    }
    else // EE not present
    {
        self.energyExpended = @"0";
    }
    
    // RR interval
    if (bytes[0] & 0x10)
    {
        // The number of RR-interval values is total bytes left / 2 (size of uint16)
        NSUInteger length = [data length];
        NSUInteger count = (length - offset) / 2;
        uint16_t RRinterval = 0 ;
        for (int i = 0; i < count && i < MAX_NUM_RR_INTERVALS; i++) { // Display up to 3 RR-intervals
            // The unit for RR interval is 1/1024 seconds
            RRinterval = CFSwapInt16LittleToHost(*(uint16_t *)(&bytes[offset]));
            RRinterval = ((double)RRinterval / 1024.0 ) * 1000.0;
            offset = offset + 2; // Plus 2 bytes //
            if (i == 0) {
                self.RRinterval = [NSString stringWithFormat:@"%d",RRinterval];
            } else {
                self.RRinterval = [self.RRinterval stringByAppendingString:[NSString stringWithFormat:@"\n%d",RRinterval]];
            }
            NSLog(@"%@", self.RRinterval);
        }
    }
    
    [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:HRM_HEART_RATE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:HRM_CHARACTERISTIC_UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",NOTIFY_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:data]]];
}

/*!
 *  @method getSensorContactStatusFromCharacteristic:
 *
 *  @discussion   Instance method to get the body location of the device is available or not
 *
 */
-(BOOL)getSensorContactStatusFromCharacteristic:(CBCharacteristic *)characteristic {
    NSData *data = [characteristic value];
    const uint8_t *reportData = [data bytes];
    if((reportData[0] & 0x02) == 4) {
        return YES;
    }
    return NO;
}

/*!
 *  @method getBodyLocationFromCharacteristic:
 *
 *  @discussion   Instance method to get the body location of the device
 *
 */
- (void) getBodyLocationFromCharacteristic:(CBCharacteristic *)characteristic {
    NSData *sensorData = [characteristic value];
    uint8_t *sensorBytes = (uint8_t *)[sensorData bytes];
    if (sensorBytes) {
        uint8_t bodyLocation = sensorBytes[0];
        NSString *sensorLocationString = @"";
        switch (bodyLocation) {
            case 0:
                sensorLocationString = OTHER; break;
            case 1:
                sensorLocationString = CHEST; break;
            case 2:
                sensorLocationString = WRIST; break;
            case 3:
                sensorLocationString = FINGER; break;
            case 4:
                sensorLocationString = HAND; break;
            case 5:
                sensorLocationString = EAR; break;
            case 6:
                sensorLocationString = FOOT; break;
            default:
                break;
        }
        self.sensorLocation = sensorLocationString;
    }
    else {
        self.sensorLocation = LOCATION_NA;
    }
    
    [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",READ_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:sensorData]]];
}

@end
