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

#import "RSCModel.h"
#import "CyCBManager.h"

/*!
 *  @class RSCModel
 *
 *  @discussion Class to handle the running speed and cadence service related operations
 *
 */

@interface RSCModel () <cbCharacteristicManagerDelegate>
{
    void (^cbCharacteristicHandler)(BOOL success, NSError *error);
    void (^cbCharacteristicDiscoverHandler)(BOOL success, NSError *error);
    CBCharacteristic *RSCCharacter;
}

@end

@implementation RSCModel

@synthesize InstantaneousSpeed;
@synthesize InstantaneousCadence;
@synthesize InstantaneousStrideLength;
@synthesize TotalDistance;


- (instancetype)init
{
    self = [super init];
    if (self) {

    }
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
    if(RSCCharacter)
    {
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:RSC_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:RSC_CHARACTERISTIC_UUID] descriptor:nil operation:START_NOTIFY];
        [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:YES forCharacteristic:RSCCharacter];
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
    if(RSCCharacter)
    {
        if (RSCCharacter.isNotifying)
        {
            [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:RSC_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:RSC_CHARACTERISTIC_UUID] descriptor:nil operation:STOP_NOTIFY];
            [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:NO forCharacteristic:RSCCharacter];
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
    if ([service.UUID isEqual:RSC_SERVICE_UUID]){
        for (CBCharacteristic *aChar in service.characteristics)
        {
            // Checking for required characteristic
            if ([aChar.UUID isEqual:RSC_CHARACTERISTIC_UUID]){
                RSCCharacter = aChar ;
                cbCharacteristicDiscoverHandler(YES,nil);
            }
        }
    }
}

/*!
 *  @method peripheral: didUpdateValueForCharacteristic: error:
 *
 *  @discussion Method invoked when the characteristic value changes or read value
 *
 */

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:RSC_CHARACTERISTIC_UUID])
    {
        if(error == nil)
        {
            [self getRSCData:characteristic];
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
 *  @method getRSCData:
 *
 *  @discussion   The RSC Measurement characteristic (RSC refers to Running Speed and Cadence) is a variable length structure containing a Flags field, an Instantaneous Speed field and an Instantaneous Cadence field and, based on the contents of the Flags field, may contain a Stride Length field and a Total Distance field.
 *
 */

- (void)getRSCData:(CBCharacteristic *)characteristic
{
    NSData *data = [characteristic value];      // 1
    const uint8_t *reportData = [data bytes];
     NSInteger shiftVal = 1;

    //    Instantaneous Speed ------ Unit is in m/s with a resolution of 1/256 s
    uint16_t _instantaneousSpeed = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[shiftVal]));
    //Unit is in m/s with a resolution of 1/256 s
    //Convert to km/hr  ( m/s *3.6)
    self.InstantaneousSpeed = 3.6*(_instantaneousSpeed/256.0);

    shiftVal+=2;

    //    Instantaneous Cadence ---- Unit is in 1/minute (or RPM) with a resolutions of 1 1/min (or 1 RPM)

    uint8_t _instantaneousCadence = reportData[shiftVal++];
    self.InstantaneousCadence = (float)_instantaneousCadence;

    uint16_t _instantaneousStrideLength = 0;
    uint32_t _totalDistancePresent = 0;

    self.InstantaneousStrideLength = 0.0f;

    if ((reportData[0] & 0x01) == 1)
    {
        //Instantaneous Stride Length Present
        // Instantaneous Stride Length ---- Unit is in meter with a resolution of 1/100 m (or centimeter).
         _instantaneousStrideLength = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[shiftVal]));
        self.InstantaneousStrideLength = ((float)_instantaneousStrideLength)/100.0f;

        shiftVal += 2 ;
    }

    if (reportData[0] & 0x02)
    {
        //Total Distance Present
        // Unit is in meter with a resolution of 1/10 m (or decimeter)
        _totalDistancePresent =(uint32_t)CFSwapInt32LittleToHost(*(uint32_t*)&reportData[shiftVal]);

        if (_totalDistancePresent)
        {
            self.TotalDistance = _totalDistancePresent/10.0;

        }
    }

    if ((reportData[0] & 0x04) == 0)
    {
        self.IsWalking = YES ;
    }

    [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:RSC_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:RSC_CHARACTERISTIC_UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",NOTIFY_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:data]]];

}


@end
