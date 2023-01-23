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

#import "ThermometerModel.h"
#import "CyCBManager.h"


// Temperature units

#define TEMPERATURE_UNIT_IN_CELCIUS         @"°C"
#define TEMPERATURE_UNIT_IN_FAHRENHEIT      @"°F"

/*!
 *  @class ThermometerModel
 *
 *  @discussion Class to handle the thermometer service related operations
 *
 */


@interface ThermometerModel () <cbCharacteristicManagerDelegate>
{
    void (^cbCharacteristicHandler)(BOOL success, NSError *error);
    void (^cbCharacteristicDiscoverHandler)(BOOL success, NSError *error);
    CBCharacteristic *RSCCharacter;
}

@end

@implementation ThermometerModel

@synthesize tempStringValue;
@synthesize mesurementType;
@synthesize timeStampString;
@synthesize tempType;


- (instancetype)init
{
    self = [super init];
    return self;
}


/*!
 *  @method startDiscoverChar:
 *
 *  @discussion Discovers the specified characteristics of a service..
 */
-(void)startDiscoverChar:(void (^) (BOOL success, NSError *error))handler
{
    cbCharacteristicDiscoverHandler = handler;
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
}

/*!
 *  @method stopUpdate
 *
 *  @discussion Stop notifications or indications for the value of a specified characteristic.
 */

-(void)stopUpdate
{
    cbCharacteristicHandler = nil;
    
    if ([[[CyCBManager sharedManager] myService].UUID isEqual:THM_SERVICE_UUID])
    {
        for (CBCharacteristic *aChar in [[CyCBManager sharedManager] myService].characteristics)
        {
            if ([aChar.UUID isEqual:THM_TEMPERATURE_MEASUREMENT_CHARACTERISTIC_UUID]){
                
                if (aChar.isNotifying)
                {
                    [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:NO  forCharacteristic:aChar];
                    [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:THM_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:THM_TEMPERATURE_MEASUREMENT_CHARACTERISTIC_UUID] descriptor:nil operation:STOP_INDICATE];
                }
                cbCharacteristicDiscoverHandler(YES,nil);
            }
        }
    }
}


#pragma mark - CBCharecteristicManger delegate methods

/*!
 *  @method peripheral: didDiscoverCharacteristicsForService: error:
 *
 *  @discussion Method invoked when characteristics are discovered for a service
 *
 */

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:THM_SERVICE_UUID]){
        for (CBCharacteristic *aChar in service.characteristics){
            if ([aChar.UUID isEqual:THM_TEMPERATURE_MEASUREMENT_CHARACTERISTIC_UUID])
            {
                [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:YES forCharacteristic:aChar];
                
                [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:THM_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:THM_TEMPERATURE_MEASUREMENT_CHARACTERISTIC_UUID] descriptor:nil operation:START_INDICATE];
                
                cbCharacteristicDiscoverHandler(YES,nil);
            }
            else if([aChar.UUID isEqual:THM_TEMPERATURE_TYPE_CHARACTERISTIC_UUID])
            {
                [[[CyCBManager sharedManager] myPeripheral] readValueForCharacteristic:aChar];
                
                [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:THM_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:THM_TEMPERATURE_TYPE_CHARACTERISTIC_UUID] descriptor:nil operation:READ_REQUEST];
            }
        }
    }
    else
    {
        cbCharacteristicDiscoverHandler(NO,nil);
    }
}

/*!
 *  @method peripheral: didUpdateValueForCharacteristic: error:
 *
 *  @discussion Method invoked when the characteristic value changes
 *
 */

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error == nil)
    {
        if ([characteristic.UUID isEqual:THM_TEMPERATURE_MEASUREMENT_CHARACTERISTIC_UUID] && characteristic.value)
        {
            [self getTHMtemp:characteristic];
        }
        else if ([characteristic.UUID isEqual:THM_TEMPERATURE_TYPE_CHARACTERISTIC_UUID] && characteristic.value)
        {
            [self getTempType:characteristic];
        }
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

/*!
 *  @method getTHMtemp:
 *
 *  @discussion   Instance method to get the temperature value
 *
 */


-(void)getTHMtemp:(CBCharacteristic *)characteristic
{
  
    // Convert the contents of the characteristic value to a data-object //
    NSData *data = [characteristic value];
    
    // Get the byte sequence of the data-object //
    const uint8_t *reportData = [data bytes];
    
    // Initialise the offset variable //
    NSUInteger offset = 1;
    // Initialise the bpm variable //
   
    if ((reportData[0] & 0x01) == 0) {
        
        [self calculateTemperaturefromCharacteristic:characteristic];

        offset = offset + 4; // Plus 4 byte //
        self.mesurementType = TEMPERATURE_UNIT_IN_CELCIUS;
    }
    else {
        
        [self calculateTemperaturefromCharacteristic:characteristic];

        offset =  offset + 4; // Plus 4 bytes //
        self.mesurementType = TEMPERATURE_UNIT_IN_FAHRENHEIT;
    }
    
    
    /* timestamp */
    if( (reportData[0] & 0x02) )
    {
        uint16_t year = CFSwapInt16LittleToHost(*(uint16_t *) &reportData[offset]); offset += 2;
        uint8_t month = *(uint8_t *) &reportData[offset]; offset++;
        uint8_t day = *(uint8_t*) &reportData[offset]; offset++;
        uint8_t hour = *(uint8_t*) &reportData[offset]; offset++;
        uint8_t min = *(uint8_t*) &reportData[offset]; offset++;
        uint8_t sec = *(uint8_t*) &reportData[offset]; offset++;
        
        NSString * dateString = [NSString stringWithFormat:@"%d %d %d %d %d %d", year, month, day, hour, min, sec];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat: @"yyyy MM dd HH mm ss"];
        NSDate* date = [dateFormat dateFromString:dateString];
        
        [dateFormat setDateFormat:@"EEE MMM dd, yyyy"];
        NSString* dateFormattedString = [dateFormat stringFromDate:date];
        
        [dateFormat setDateFormat:@"h:mm a"];
        NSString* timeFormattedString = [dateFormat stringFromDate:date];
        
        
        if( dateFormattedString && timeFormattedString )
        {
            self.timeStampString = [NSString stringWithFormat:@"%@ at %@", dateFormattedString, timeFormattedString];
        }
    }
    
    [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",NOTIFY_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:data]]];
}

/*!
 *  @method calculateTemperaturefromCharacteristic
 *
 *  @discussion Method to calculate the temperature
 *
 */


-(void) calculateTemperaturefromCharacteristic:(CBCharacteristic *)characteristic
{
    // Convert the contents of the characteristic value to a data-object //
    NSData *data = [characteristic value];
    
    // Get the byte sequence of the data-object //
    const uint8_t *reportDataPointer = [data bytes];
    reportDataPointer++;
    
    
    int32_t tempData = (int32_t)CFSwapInt32LittleToHost(*(uint32_t *)reportDataPointer);

    int32_t exponent = (tempData & 0xFF000000) >> 24;
    int32_t mantissa = (int32_t)(tempData & 0x00FFFFFF);
    
 
    if (mantissa >= 0x800000) {
        mantissa = -(0x01000000 - mantissa);
    }
    
    if (exponent >= 0x80) {
        exponent = -(0x0100 - exponent);
    }
    
    
    float tempValue = (float)(mantissa * pow(10, exponent));
    self.tempStringValue = [NSString stringWithFormat:@"%.2f",(float) tempValue];
}

/*!
 *  @method isTempTypeValid:
 *
 *  @discussion   Instance method to check temperature type exist or not
 *
 */

-(BOOL)isTempTypeValid:(CBCharacteristic *)characteristic
{
    NSData * updatedValue = characteristic.value;
    uint8_t* dataPointer = (uint8_t*)[updatedValue bytes];
    
    uint8_t flags = dataPointer[0];
    
     if( flags & 0x04 )
     {
         return true;
     }
    return false;
}

/*!
 *  @method getTempType:
 *
 *  @discussion   Instance method to get the Temperature Type characteristic is an enumeration that indicates where the temperature was measured
 *
 */

-(void)getTempType:(CBCharacteristic *)characteristic
{
    /* temperature type */
    
    NSData * updatedValue = characteristic.value;
    uint8_t* dataPointer = (uint8_t*)[updatedValue bytes];
    uint8_t type = *(uint8_t*)dataPointer;
    NSString* location = nil;
    
    switch (type)
    {
        case 0x01:
            location = ARMPIT;
            break;
        case 0x02:
            location = BODY_GENERAL;
            break;
        case 0x03:
            location = EAR_LOBE;
            break;
        case 0x04:
            location = FINGER;
            break;
        case 0x05:
            location = GASTRO_INTENSTINAL_TRACT;
            break;
        case 0x06:
            location = MOUTH;
            break;
        case 0x07:
            location = RECTUM;
            break;
        case 0x08:
            location = TOE;
            break;
        case 0x09:
            location = TYMPANUM_EAR_DRUM;
            break;
        default:
            break;
    }
    if (location)
    {
        self.tempType = [NSString stringWithFormat:@"%@", location];
    }
    
    [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",READ_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:updatedValue]]];
}




@end
