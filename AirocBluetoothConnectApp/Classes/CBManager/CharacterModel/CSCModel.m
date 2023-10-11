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

#import "CSCModel.h"
#import "CyCBManager.h"
#import "Constants.h"


/*!
 *  @class CSCModel
 *
 *  @discussion Class to handle the cycling speed and cadence service related operations
 *
 */

@interface CSCModel () <cbCharacteristicManagerDelegate>
{
    void(^cbCharacteristicHandler)(BOOL success, NSError *error);
    void(^cbCharacteristicDiscoverHandler)(BOOL success, NSError *error);

    CBCharacteristic *CSCCharacteristic;

    float previousRevolution, previousEventTime;
}


@end

@implementation CSCModel


@synthesize coveredDistance;
@synthesize cadence;


- (instancetype)init
{
    self = [super init];
    if (self) {

        previousEventTime = 0.0;
        previousRevolution = 0.0;
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

    if (CSCCharacteristic)
    {
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:CSC_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:CSC_CHARACTERISTIC_UUID] descriptor:nil operation:START_NOTIFY];
        [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:YES forCharacteristic:CSCCharacteristic];
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

    if (CSCCharacteristic)
    {
        if (CSCCharacteristic.isNotifying)
        {
            [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:CSC_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:CSC_CHARACTERISTIC_UUID] descriptor:nil operation:STOP_NOTIFY];
            [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:NO forCharacteristic:CSCCharacteristic];
        }
    }
}

#pragma mark - CBCharacteristicManager delegate

/*!
 *  @method peripheral: didDiscoverCharacteristicsForService: error:
 *
 *  @discussion Method invoked when characteristics are discovered for a service
 *
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:CSC_SERVICE_UUID])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            // Checking for the required characteristic
            if ([aChar.UUID isEqual:CSC_CHARACTERISTIC_UUID])
            {
                CSCCharacteristic = aChar ;
                cbCharacteristicDiscoverHandler(YES,nil);
            }
        }
        cbCharacteristicDiscoverHandler(NO,error);

    }
    else
    {
        cbCharacteristicDiscoverHandler(NO,error);
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
    if ([characteristic.UUID isEqual:CSC_CHARACTERISTIC_UUID])
    {
        if(error == nil)
        {
            [self getCSCData:characteristic]; // Parse the data received from the characteristic

            if (cbCharacteristicHandler) {
                cbCharacteristicHandler(YES,nil);
            }
        }
        else
        {
            if (cbCharacteristicHandler) {
                cbCharacteristicHandler(NO,error);
            }
        }
    }
}


/*!
 *  @method getCSCData:
 *
 *  @discussion  Method to parse the characteristic value. The CSC Measurement characteristic (CSC refers to Cycling Speed and Cadence) is a variable length structure containing a Flags field and, based on the contents of the Flags field, may contain one or more additional fields.
 *
 */

-(void) getCSCData:(CBCharacteristic *)characteristic
{
    NSData *data =[characteristic value];
    const uint8_t *reportData = [data bytes];

    int bitPosition = 1;
    // Checking Cumulative Wheel Revolutions present

    if ((reportData[0] & 0x01) == 1)
    {
        // Cumulative Wheel Revolutions present
        uint32_t  wheelRevolutionsCount = (uint32_t)CFSwapInt32LittleToHost(*(uint32_t *)&reportData[bitPosition]);
        bitPosition += 6;

        if (wheelRevolutionsCount && _wheelRadius)
        {
            float wheelCircumference;
            wheelCircumference = (2 * 3.14 * _wheelRadius)/1000.0;
            self.coveredDistance = (float)wheelRevolutionsCount * wheelCircumference;
        }
    }

    if ((reportData[0] & 0x02) > 0)
    {
        // Cumulative Crank Revolutions present
        uint16_t CrankRevolutionsCount = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[bitPosition]));
        bitPosition += 2;

        uint16_t LastEvent = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[bitPosition]));
        [self calculateRPMForCrankrevolutions:CrankRevolutionsCount eventTime:LastEvent];
    }

    [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:CSC_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:CSC_CHARACTERISTIC_UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",NOTIFY_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:data]]];

}

/*!
 *  @method calculateRPMForCrankrevolutions: eventTime:
 *
 *  @discussion Method to calculate rpm from crank revolutions
 *
 */
-(void) calculateRPMForCrankrevolutions:(float)currentRevolution eventTime:(float)lastEventTime
{

    if (lastEventTime == previousEventTime)
    {
        return;
    }

    if (previousEventTime == 0.0 && previousRevolution == 0.0)
    {
        previousEventTime = lastEventTime;
        previousRevolution = currentRevolution;
    }
    else
    {
        float timeDelta, rpm;
        if (lastEventTime > previousEventTime)
        {
            timeDelta = (lastEventTime - previousEventTime)/1024.0;
        }
        else
            timeDelta = ((65535.0 + lastEventTime) - previousEventTime)/1024.0;

        rpm = (currentRevolution - previousRevolution) * (60.0 / timeDelta);

        if (rpm > 0.0)
        {
            cadence = (int) rpm;
        }

        previousEventTime = lastEventTime;
        previousRevolution = currentRevolution;
    }
}




@end
