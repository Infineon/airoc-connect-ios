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

#import "GlucoseModel.h"
#import "Utilities.h"
#import "Constants.h"

#define CONCENTRATION_UNIT_IN_KG        @"kg/L"
#define CONCENTRATION_UNIT_IN_MOL       @"mol/L"

#define EXERCISE_DURATION_MAX           65535
#define EXERCISE_DURATION_UNIT          @"seconds"

#define MEDICATION_UNIT_KG              @"kilograms"
#define MEDICATION_UNIT_LITRE           @"liters"

/*!
 *  @class GlucoseModel
 *
 *  @discussion Class to handle the glucose service related operations
 *
 */

@interface GlucoseModel () <cbCharacteristicManagerDelegate>

@end

@implementation GlucoseModel
{
    void(^cbCharacteristicHandler)(BOOL success, NSError *error);
    void(^cbcharacteristicDiscoverHandler)(BOOL success, NSError *error);

    CBCharacteristic *glucoseMeasurementChar, *recordAccessControlPointChar, *glucoseMeasurementContextChar;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _glucoseRecords = [NSMutableArray array];
        _recordNameArray = [NSMutableArray array];
        _contextInfoArray = [NSMutableArray array];
    }
    return self;
}

/*!
 *  @method startDiscoverChar:
 *
 *  @discussion Discovers the specified characteristics of a service.
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

}

/*!
 *  @method setCharacteristicUpdates:
 *
 *  @discussion Sets notifications or indications for glucose characteristics.
 */

-(void) setCharacteristicUpdates{

    if (glucoseMeasurementChar) {
        [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:YES forCharacteristic:glucoseMeasurementChar];

        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:GLUCOSE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID] descriptor:nil operation:START_NOTIFY];
    }

    if (recordAccessControlPointChar) {
        [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:YES forCharacteristic:recordAccessControlPointChar];

        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:GLUCOSE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:GLUCOSE_RECORD_ACCESS_CONTROL_POINT_UUID] descriptor:nil operation:START_INDICATE];
    }

    if(glucoseMeasurementContextChar){
        [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:YES forCharacteristic:glucoseMeasurementContextChar];

        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:GLUCOSE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:GLUCOSE_MEASUREMENT_CONTEXT_UUID] descriptor:nil operation:START_NOTIFY];
    }

}

/*!
 *  @method writeRACPCharacteristicWithValueString:
 *
 *  @discussion Write specified value to the RACP characteristic.
 */

-(void) writeRACPCharacteristicWithValueString:(NSString *)Value{

    NSData *dataToWrite = [Utilities dataFromHexString:Value];
    if (recordAccessControlPointChar != nil) {

        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:GLUCOSE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:GLUCOSE_RECORD_ACCESS_CONTROL_POINT_UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@%@",WRITE_REQUEST,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:dataToWrite]]];

        [[[CyCBManager sharedManager] myPeripheral] writeValue:dataToWrite forCharacteristic:recordAccessControlPointChar type:CBCharacteristicWriteWithResponse];
    }
}

/*!
 *  @method removePreviousRecords
 *
 *  @discussion clear all the records received.
 */

-(void) removePreviousRecords{

    [_contextInfoArray removeAllObjects];
    [_glucoseRecords removeAllObjects];
    [_recordNameArray removeAllObjects];
}

/*!
 *  @method stopUpdate
 *
 *  @discussion Stop notifications or indications for the value of a specified characteristic.
 */
-(void) stopUpdate
{
    if (glucoseMeasurementChar){
        if (glucoseMeasurementChar.isNotifying){
            [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:GLUCOSE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID] descriptor:nil operation:STOP_NOTIFY];
            [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:NO forCharacteristic:glucoseMeasurementChar];
        }
    }

    if (recordAccessControlPointChar) {
        if (recordAccessControlPointChar.isNotifying) {
             [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:GLUCOSE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:GLUCOSE_RECORD_ACCESS_CONTROL_POINT_UUID] descriptor:nil operation:STOP_INDICATE];
            [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:NO forCharacteristic:recordAccessControlPointChar];
        }
    }

    if (glucoseMeasurementContextChar) {
        if (glucoseMeasurementContextChar.isNotifying) {
             [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:GLUCOSE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:GLUCOSE_MEASUREMENT_CONTEXT_UUID] descriptor:nil operation:STOP_NOTIFY];
            [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:NO forCharacteristic:glucoseMeasurementContextChar];
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
    if ([service.UUID isEqual:GLUCOSE_SERVICE_UUID])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            // Check for the required characteristic
            if ([aChar.UUID isEqual:GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID])
            {
                glucoseMeasurementChar = aChar;
            }
            else if ([aChar.UUID isEqual:GLUCOSE_RECORD_ACCESS_CONTROL_POINT_UUID])
            {
                recordAccessControlPointChar = aChar;
            }
            else if ([aChar.UUID isEqual:GLUCOSE_MEASUREMENT_CONTEXT_UUID])
            {
                glucoseMeasurementContextChar = aChar;
            }
        }

        if (glucoseMeasurementChar || glucoseMeasurementContextChar || recordAccessControlPointChar) {
            cbcharacteristicDiscoverHandler(YES,nil);
        }
        else
            cbcharacteristicDiscoverHandler(NO,nil);
    }
    else
    {
        cbcharacteristicDiscoverHandler(NO,error);
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
    if (error == nil)
    {
        if ([characteristic.UUID isEqual:GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID])
        {
            if ([_glucoseRecords containsObject:characteristic.value]){
                [_glucoseRecords removeObject:characteristic.value];
                [_recordNameArray removeObject:[self getRecordNameFromcharacteristicValue:characteristic.value]];
            }

            [_glucoseRecords addObject:characteristic.value];
            [_recordNameArray addObject:[self getRecordNameFromcharacteristicValue:characteristic.value]];

            [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:GLUCOSE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",NOTIFY_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:characteristic.value]]];

        }
        else if ([characteristic.UUID isEqual:GLUCOSE_MEASUREMENT_CONTEXT_UUID])
        {
            if (![_contextInfoArray containsObject:characteristic.value]) {
                [_contextInfoArray addObject:characteristic.value];
            }

            [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:GLUCOSE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:GLUCOSE_MEASUREMENT_CONTEXT_UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",NOTIFY_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:characteristic.value]]];
        }
        else if ([characteristic.UUID isEqual:GLUCOSE_RECORD_ACCESS_CONTROL_POINT_UUID]){

            [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:GLUCOSE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:GLUCOSE_RECORD_ACCESS_CONTROL_POINT_UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",INDICATE_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:characteristic.value]]];
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


-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{

    if ([characteristic.UUID isEqual:GLUCOSE_RECORD_ACCESS_CONTROL_POINT_UUID]) {
        if (error == nil) {

            [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@- %@",WRITE_REQUEST_STATUS,WRITE_SUCCESS]];
        }
        else
        {
            [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@- %@%@",WRITE_REQUEST_STATUS,WRITE_ERROR,[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
        }
    }
}


/*!
 *  @method getGlucoseData:
 *
 *  @discussion  Instance method to parse the data received from the peripheral
 */

-(NSMutableDictionary *) getGlucoseData:(NSData *)characteristicValue
{
    NSData *charData = characteristicValue;
    uint8_t *dataPointer = (uint8_t *)[charData bytes];
    uint8_t flags = dataPointer[0];

    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    int16_t timeOffset = 0;

    // Get the sequence number
    dataPointer++;

    uint16_t sequenceNumber = (uint16_t) CFSwapInt16LittleToHost(*(uint16_t *) dataPointer);
    [dataDict setObject:[NSNumber numberWithUnsignedInteger:sequenceNumber] forKey:SEQUENCE_NUMBER];
    // Get date

    dataPointer+=2;
    uint16_t year = CFSwapInt16LittleToHost(*(uint16_t*)dataPointer); dataPointer += 2;
    uint8_t month = *(uint8_t*)dataPointer; dataPointer++;
    uint8_t day = *(uint8_t*)dataPointer; dataPointer++;
    uint8_t hour = *(uint8_t*)dataPointer; dataPointer++;
    uint8_t min = *(uint8_t*)dataPointer; dataPointer++;
    uint8_t sec = *(uint8_t*)dataPointer; dataPointer++;

    NSString * dateString = [NSString stringWithFormat:@"%d %d %d %d %d %d", year, month, day, hour, min, sec];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"yyyy MM dd HH mm ss"];
    NSDate* date = [dateFormat dateFromString:dateString];

    if (flags & 0x01) {
        // Time Offset Present

        timeOffset = CFSwapInt16LittleToHost(*(int16_t *) dataPointer);
        dataPointer= dataPointer + 2;
    }

    if (timeOffset > 0) {
        date = [date dateByAddingTimeInterval:timeOffset * 60];
    }
    /*EEE for day, yyyy for Year, dd for date, MM for month*/

    [dateFormat setDateFormat:@"yyyy MMM dd"];
    NSString* dateFormattedString = [dateFormat stringFromDate:date];

    [dateFormat setDateFormat:@"hh:mm:ss"];
    NSString* timeFormattedString = [dateFormat stringFromDate:date];


    if( dateFormattedString && timeFormattedString )
    {
        NSString *timeString = [NSString stringWithFormat:@"%@ %@", dateFormattedString, timeFormattedString];
        [dataDict setObject:timeString forKey:BASE_TIME];
    }


    // Checking whether Glucose concentration,type or sample location present

    if (flags & 0x02)
    {
        // Checking Glucose concentration unit

        float concentrationValue;

        if (!(flags & 0x04))
        {
            // Unit is kg/L

            [dataDict setObject:CONCENTRATION_UNIT_IN_KG forKey:CONCENTRATION_UNIT];

            int16_t tempData = (uint16_t)CFSwapInt16LittleToHost(*((uint16_t *) dataPointer));
            concentrationValue = [Utilities convertSFLOATFromData:tempData];

            dataPointer +=2;
        }
        else
        {
            // Unit is mol/L

            [dataDict setObject:CONCENTRATION_UNIT_IN_MOL forKey:CONCENTRATION_UNIT];

            int16_t tempData = (uint16_t)CFSwapInt16LittleToHost(*((uint16_t *) dataPointer));
            concentrationValue = [Utilities convertSFLOATFromData:tempData];
            dataPointer +=2;
        }

        [dataDict setObject:[NSString stringWithFormat:@"%f",concentrationValue] forKey:CONCENTRATION_VALUE];

        // Get type

        uint8_t tempValue = *(uint8_t *)dataPointer;
        uint8_t typeValue = tempValue & 0x0F;
        [dataDict setObject:[self getTypeNameForValue:typeValue] forKey:TYPE];

        // Get sample location

        uint8_t locationValue = (tempValue >> 4) & 0x0F;
        [dataDict setObject:[self getSampleLocationForValue:locationValue] forKey:SAMPLE_LOCATION];
    }

    // Checking whether the context information is available
    if (flags & 0x10) {
        [dataDict setObject:[NSNumber numberWithBool:YES] forKey:CONTEXT_INFO_PRESENT];
    }
    else{
        [dataDict setObject:[NSNumber numberWithBool:NO] forKey:CONTEXT_INFO_PRESENT];
    }

    return dataDict;
}

/*!
 *  @method getGlucoseContextInfoFromData:
 *
 *  @discussion Method to parse the value from the glucose measurement context characteristic
 *
 */

-(NSMutableDictionary *) getGlucoseContextInfoFromData:(NSData *) characteristicValue
{

    NSMutableDictionary *contextDataDict = [NSMutableDictionary dictionary];

    uint8_t *dataPointer = (uint8_t *) [characteristicValue bytes];
    uint8_t flags = dataPointer[0];

    // Get the sequence number
    dataPointer++;

    uint16_t sequenceNumber = (uint16_t) CFSwapInt16LittleToHost(*(uint16_t *) dataPointer);
    [contextDataDict setObject:[NSNumber numberWithUnsignedInteger:sequenceNumber] forKey:SEQUENCE_NUMBER];

    dataPointer += 2;
    // Checking Carbohydrate ID And Carbohydrate Present

    if (flags & 01) {

        dataPointer = dataPointer + 1;
        uint8_t carboHydrateID = *(uint8_t *)dataPointer;
        [contextDataDict setObject:[self getCarbohydrateIDForValue:carboHydrateID] forKey:CARBOHYDARATE_ID];

        // Getting carbohydrate in units of Kg
        dataPointer++;

        int16_t carbohydrateData = (int16_t)CFSwapInt16LittleToHost(*(int16_t *) dataPointer);
        float carbohydrate = [Utilities convertSFLOATFromData:carbohydrateData];

        dataPointer = dataPointer + 2;
        [contextDataDict setObject:[NSString stringWithFormat:@"%f Kg",carbohydrate] forKey:CARBOHYDARATE];
    }

    // Checking meal present

    if (flags & 0x02) {

        uint8_t mealValue = *(uint8_t *)dataPointer;
        dataPointer++;
        [contextDataDict setObject:[self getMealInfoForValue:mealValue] forKey:MEAL];
    }

    // Checking Tester-Health Present

    if (flags & 0x04) {

        uint8_t tempValue = *(uint8_t *)dataPointer;
        uint8_t testerValue = (tempValue & 0x0F);
        [contextDataDict setObject:[self getTesterInfo:testerValue] forKey:TESTER];

        uint8_t healthValue = ((tempValue >> 4) & 0x0F);
        [contextDataDict setObject:[self getMealInfoForValue:healthValue] forKey:HEALTH];
        dataPointer++;
    }

    // Checking Exercise Duration And Exercise Intensity Present

    if (flags & 0x08) {

        uint16_t exerciseduration = CFSwapInt16LittleToHost(*(uint16_t *) dataPointer);
        [contextDataDict setObject:[NSString stringWithFormat:@"%d %@",exerciseduration,EXERCISE_DURATION_UNIT] forKey:EXERCISE_DURATION];

        dataPointer = dataPointer + 2;

        uint8_t exerciseIntensity = *(uint8_t *)dataPointer;
        [contextDataDict setObject:[NSString stringWithFormat:@"%d",exerciseIntensity] forKey:EXERCISE_INTENSITY];

        dataPointer++;
    }

    // Checking Medication ID And Medication Present

    float medicationValue = 0.0;

    if (flags & 0x10) {

        uint8_t medicationID = *(uint8_t *) dataPointer;
        [contextDataDict setObject:[self getMedicationIDInfoForValue:medicationID] forKey:MEDICATION_ID];

        dataPointer++;

        int16_t medicationData = (int16_t)CFSwapInt16LittleToHost(*(int16_t *) dataPointer);
        medicationValue = [Utilities convertSFLOATFromData:medicationData];

        dataPointer = dataPointer + 2;
    }

    // Checking Medication Value Units

    NSString *medicationUnit = @"";

    if (flags & 0x20) {
        medicationUnit = MEDICATION_UNIT_LITRE;
    }
    else{
        medicationUnit = MEDICATION_UNIT_KG;
    }

    if (medicationValue > 0.0) {
        [contextDataDict setObject:[NSString stringWithFormat:@"%F %@",medicationValue,medicationUnit] forKey:MEDICATION];
    }

    // CHECKING HbA1c Present

    if (flags & 0x04) {
        int16_t diebeticsData = (int16_t) CFSwapInt16LittleToHost(*(int16_t *) dataPointer);
        float hbA1cValue = [Utilities convertSFLOATFromData:diebeticsData];
        [contextDataDict setObject:[NSString stringWithFormat:@"%f",hbA1cValue] forKey:HBA1C];
    }
    return contextDataDict;
}


-(NSString *)getRecordNameFromcharacteristicValue:(NSData *)characteristicValue{

    NSString *recordName = @"";
    NSString *timeString = @"";
    uint8_t *dataPointer = (uint8_t *)[characteristicValue bytes];
    uint8_t flags = dataPointer[0];

    dataPointer++;
    uint16_t sequenceNumber = CFSwapInt16LittleToHost(*(uint16_t *)dataPointer);
    dataPointer = dataPointer + 2;

    uint16_t year = CFSwapInt16LittleToHost(*(uint16_t*)dataPointer); dataPointer += 2;
    uint8_t month = *(uint8_t*)dataPointer; dataPointer++;
    uint8_t day = *(uint8_t*)dataPointer; dataPointer++;
    uint8_t hour = *(uint8_t*)dataPointer; dataPointer++;
    uint8_t min = *(uint8_t*)dataPointer; dataPointer++;
    uint8_t sec = *(uint8_t*)dataPointer; dataPointer++;

    int16_t timeOffset = 0;
    if (flags & 0x01) {
        timeOffset = CFSwapInt16LittleToHost(*(int16_t *) dataPointer);
    }

    // Adding the time offset with base time

    NSString * dateString = [NSString stringWithFormat:@"%d %d %d %d %d %d", year, month, day, hour, min, sec];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"yyyy MM dd HH mm ss"];
    NSDate* date = [dateFormat dateFromString:dateString];

    if (timeOffset > 0) {
        date = [date dateByAddingTimeInterval:timeOffset * 60];
    }

    /*EEE for day, yyyy for Year, dd for date, MM for month*/

    [dateFormat setDateFormat:@"yyyy MMM dd"];
    NSString* dateFormattedString = [dateFormat stringFromDate:date];

    [dateFormat setDateFormat:@"hh:mm:ss"];
    NSString* timeFormattedString = [dateFormat stringFromDate:date];


    if( dateFormattedString && timeFormattedString )
    {
        timeString = [NSString stringWithFormat:@"%@ %@", dateFormattedString, timeFormattedString];
    }

    recordName = [NSString stringWithFormat:@"%d - %@",sequenceNumber,timeString];

    return recordName;
}



/*!
 *  @method getTypeNameForValue:
 *
 *  @discussion  Instance method to get the Type Name
 */

-(NSString *) getTypeNameForValue:(uint8_t)value
{
    NSString *typeName = nil;

    switch (value)
    {
        case 0x00:
            typeName = RESERVED_FOR_FUTURE_USE;
            break;

        case 0x01:
            typeName = CAPILLARY_WHOLE_BLOOD;
            break;
        case 0x02:
            typeName = CAPILLARY_PLASMA;
            break;
        case 0x03:
            typeName = VENOUS_WHOLE_BLOOD;
            break;
        case 0x04:
            typeName = VENOUS_PLASMA;
            break;
        case 0x05:
            typeName = ARTERIAL_WHOLE_BLOOD;
            break;
        case 0x06:
            typeName = ARTERIAL_PLASMA;
            break;
        case 0x07:
            typeName = UNDETERMINED_WHOLE_BLOOD;
            break;
        case 0x08:
            typeName = UNDETERMINED_PLASMA;
            break;
        case 0x09:
            typeName = INTERSTITIAL_FLUID;
            break;
        case 0x0A:
            typeName = CONTROL_SOLUTION;
            break;
        default:
            typeName = RESERVED_FOR_FUTURE_USE;
            break;
    }

    return typeName;
}

/*!
 *  @method getSampleLocationForValue:
 *
 *  @discussion  Instance method to get the sample location
 */

-(NSString *) getSampleLocationForValue:(uint8_t)value
{
    NSString *locationName = nil;

    switch (value)
    {
        case 0x00:
            locationName = RESERVED_FOR_FUTURE_USE;
            break;
        case 0x01:
            locationName = FINGER;
            break;
        case 0x02:
            locationName = ALTERNATE_SITE_TEST;
            break;
        case 0x03:
            locationName = EAR_LOBE;
            break;
        case 0x04:
            locationName = CONTROL_SOLUTION;
            break;
        case 0x0F:
            locationName = LOCATION_UNAVAILABLE;
            break;

        default:
            locationName = RESERVED_FOR_FUTURE_USE;
            break;
    }

    return locationName;
}



/*!
 *  @method getCarbohydrateIDForValue
 *
 *  @discussion Method to get the carbohydrate ID enumeration for a given value
 *
 */

-(NSString *) getCarbohydrateIDForValue:(uint8_t)value{

    NSString *carbohydateID = @"";

    switch (value) {
        case 0:
            carbohydateID = RESERVED_FOR_FUTURE_USE;
            break;
        case 1:
            carbohydateID = BRAEKFAST;
            break;
        case 2:
            carbohydateID = LUNCH;
            break;
        case 3:
            carbohydateID = DINNER;
            break;
        case 4:
            carbohydateID = SNACK;
            break;
        case 5:
            carbohydateID = DRINK;
            break;
        case 6:
            carbohydateID = SUPPER;
            break;
        case 7:
            carbohydateID = BRUNCH;
            break;
        default:
            carbohydateID = RESERVED_FOR_FUTURE_USE;
            break;
    }
    return carbohydateID;
}

/*!
 *  @method getMealInfoForValue:
 *
 *  @discussion Method to get the meal enumeration for a given value
 *
 */

-(NSString *) getMealInfoForValue:(uint8_t)value{

    NSString *mealInfo = @"";

    switch (value) {
        case 0:
            mealInfo = RESERVED_FOR_FUTURE_USE;
            break;
        case 1:
            mealInfo = PREPRANDIAL;
            break;
        case 2:
            mealInfo = POSTPRANDIAL;
            break;
        case 3:
            mealInfo = FASTING;
            break;
        case 4:
            mealInfo = CASUAL;
            break;
        case 5:
            mealInfo = BEDTIME;
            break;

        default:
            mealInfo = RESERVED_FOR_FUTURE_USE;
            break;
    }

    return mealInfo;
}

/*!
 *  @method getTesterInfo:
 *
 *  @discussion Method tester enumeration for a given value
 *
 */
-(NSString *) getTesterInfo:(uint8_t)Value{

    NSString *testerInfo = @"";

    switch (Value) {
        case 0:
            testerInfo = RESERVED_FOR_FUTURE_USE;
            break;
        case 1:
            testerInfo = SELF;
            break;
        case 2:
            testerInfo = HEALTH_CARE_PROFESSIONAL;
            break;
        case 3:
            testerInfo = LAB_TEST;
            break;
        case 15:
            testerInfo = TESTER_VALUE_NOT_AVAILABLE;
            break;
        default:
            testerInfo = RESERVED_FOR_FUTURE_USE;
            break;
    }
    return testerInfo;
}

/*!
 *  @method getHealthInfoForValue:
 *
 *  @discussion Method that returns health enumeration for given value
 *
 */
-(NSString *) getHealthInfoForValue:(uint8_t)value{

    NSString *healthInfo = @"";

    switch (value) {
        case 0:
            healthInfo = RESERVED_FOR_FUTURE_USE;
            break;
        case 1:
            healthInfo = MINOR_HEALTH_ISSUES;
            break;
        case 2:
            healthInfo = MAJOR_HEALTH_ISSUES;
            break;
        case 3:
            healthInfo = DURING_MENSES;
            break;
        case 4:
            healthInfo = UNDER_STRESS;
            break;
        case 5:
            healthInfo = NO_HEALTH_ISSUE;
            break;
        case 15:
            healthInfo = HEALTH_VALUE_NOT_AVAILABLE;
            break;
        default:
            healthInfo = RESERVED_FOR_FUTURE_USE;
            break;
    }
    return healthInfo;
}

/*!
 *  @method getMedicationIDInfoForValue:
 *
 *  @discussion Method that returns medicatonID for a given value
 *
 */
-(NSString *) getMedicationIDInfoForValue:(uint8_t)value{

    NSString *medicationIdInfo = @"";

    switch (value) {
        case 0:
            medicationIdInfo = RESERVED_FOR_FUTURE_USE;
            break;
        case 1:
            medicationIdInfo = RAPID_ACTING_INSULIN;
            break;
        case 2:
            medicationIdInfo = SHORT_ACTING_INSULIN;
            break;
        case 3:
            medicationIdInfo = INTERMEDIETE_ACTING_INSULIN;
            break;
        case 4:
            medicationIdInfo = LONG_ACTING_INSULIN;
            break;
        default:
            medicationIdInfo = RESERVED_FOR_FUTURE_USE;
            break;
    }

    return medicationIdInfo;
}



@end
