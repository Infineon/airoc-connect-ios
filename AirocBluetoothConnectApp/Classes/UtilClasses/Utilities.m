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

#import "Utilities.h"
#import "LoggerHandler.h"
#import "NSString+hex.h"
#import "NSData+hexString.h"
#import "UIAlertController+Additions.h"

/*!
 *  @class Utilities
 *
 *  @discussion Class that contains common reusable methods
 *
 */
@implementation Utilities

/*!
 *  @method timeInFormat:
 *
 *  @discussion Method that converts seconds to minute:seconds format
 *
 */
+(NSString*)timeInFormat:(double)timeInterval
{
    int duration = (int)timeInterval; // cast timeInterval to int - note: some precision might be lost
    int minutes = duration / 60; //get the elapsed minutes
    int seconds = duration % 60; //get the elapsed seconds
    return  [NSString stringWithFormat:@"%02d:%02d", minutes, seconds]; //create a string of the elapsed time in xx:xx format for example 01:15 as 1 minute 15 seconds
}

/*!
 *  @method getTodayDateString
 *
 *  @discussion Return today date string
 *
 */
+(NSString *)getTodayDateString {
    NSDate *today = [NSDate date];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATE_FORMAT];

    NSString *dateString = [dateFormatter stringFromDate:today];
    return dateString;
}

/*!
 *  @method getTodayTimeString
 *
 *  @discussion Return today time string
 *
 */
+(NSString *)getTodayTimeString {
    NSDate *today = [NSDate date];

    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:TIME_FORMAT];

    NSString *timeString = [timeFormatter stringFromDate:today];
    return timeString;
}

/*!
 *  @method secondsToHour:
 *
 *  @discussion Method that converts seconds to hours
 *
 */
+(double)secondsToHour:(double)timeInterval
{
    if(timeInterval>0)
        return (timeInterval/3600.0f);
    return 0;
}

/*!
 *  @method secondsToMinute:
 *
 *  @discussion Method that converts seconds to minute
 *
 */
+(double)secondsToMinute:(double)timeInterval
{
    if(timeInterval>0)
        return (timeInterval/60.0f);
    return 0;
}

/*!
 *  @method meterToKM:
 *
 *  @discussion Method that converts meter to km
 *
 */
+(double)meterToKM:(double)meter
{
    if(meter>0)
        return meter/1000.0f;
    return 0;
}

/*!
 *  @method getDiscriptorNameForUUID:
 *
 *  @discussion Method that returns descriptor name for given UUID
 *
 */
+(NSString *)getDescriptorNameForUUID:(CBUUID *)UUID
{
    NSString * descriptorName;
    if ([UUID isEqual:DESCRIPTOR_CHARACTERISTIC_EXTENDED_PROPERTY_UUID]) {
        descriptorName = CHARACTERISTIC_EXTENDED_PROPERTIES;
    }else if ([UUID isEqual:DESCRIPTOR_CHARACTERISTIC_USER_DESCRIPTION_UUID]) {
        descriptorName = CHARACTERISTIC_USER_DESCRIPTION;
    }else if ([UUID isEqual:DESCRIPTOR_CLIENT_CHARACTERISTIC_CONFIG_UUID]) {
        descriptorName = CLIENT_CHARACTERISTIC_CONFIG;
    }else if ([UUID isEqual:DESCRIPTOR_SERVER_CHARACTERISTIC_CONFIG_UUID]) {
        descriptorName = SERVER_CHARACTERISTIC_CONFIG;
    }else if ([UUID isEqual:DESCRIPTOR_CHARACTERISTIC_PRESENTATION_FORMAT_UUID]) {
        descriptorName = CHARACTERISTIC_PRESENTATION_FORMAT;
    }else if ([UUID isEqual:DESCRIPTOR_CHARACTERISTIC_AGGREGATE_FORMAT_UUID]) {
        descriptorName = CHARACTERISTIC_AGGREGATE_FORMAT;
    }else if ([UUID isEqual:DESCRIPTOR_VALID_RANGE_UUID]) {
        descriptorName = VALID_RANGE;
    }else if ([UUID isEqual:DESCRIPTOR_EXTERNAL_REPORT_REFERENCE_UUID]) {
        descriptorName = EXTERNAL_REPORT_REFERENCE;
    }else if ([UUID isEqual:DESCRIPTOR_REPORT_REFERENCE_UUID]) {
        descriptorName = REPORT_REFERENCE;
    }else if ([UUID isEqual:DESCRIPTOR_ENVIRONMENTAL_SENSING_CONFIG_UUID]) {
        descriptorName = ENVIRONMENTAL_SENSING_CONFIG;
    }else if ([UUID isEqual:DESCRIPTOR_ENVIRONMENTAL_SENSING_MEASUREMENT_UUID]) {
        descriptorName = ENVIRONMENTAL_SENSING_MEASUREMENT;
    }else if ([UUID isEqual:DESCRIPTOR_ENVIRONMENTAL_SENSING_TRIGGER_SETTING_UUID]) {
        descriptorName =ENVIRONMENTAL_SENSING_TRIGGER_SETTING;
    }
    return descriptorName;
}

/*!
 *  @method getDescriptorValueInformation: andValue:
 *
 *  @discussion Method that returns descriptorValueInformation for given UUID
 *
 */

+(NSString *)getDescriptorValueInformation:(CBUUID *)UUID andValue:(NSNumber *)value
{
    NSString * descriptorValueInformation;
    if ([UUID isEqual:DESCRIPTOR_CHARACTERISTIC_EXTENDED_PROPERTY_UUID]) {
        // Check 01 and 10 bits
        NSString* writeState = [value integerValue] & 0x01 ? RELIABLE_WRITE_ENABLED : RELIABLE_WRITE_DISABLED;
        NSString* auxState = [value integerValue] & 0x02 ? WRITABLE_AUXILARIES_ENABLED : WRITABLE_AUXILARIES_DISABLED;
        descriptorValueInformation = [NSString stringWithFormat:@"%@ \n%@", writeState, auxState];
    }else if ([UUID isEqual:DESCRIPTOR_CHARACTERISTIC_USER_DESCRIPTION_UUID]) {
        descriptorValueInformation = @"";
    }else if ([UUID isEqual:DESCRIPTOR_CLIENT_CHARACTERISTIC_CONFIG_UUID]){
        // Check 01 and 10 bits
        NSString* notifyState = [value integerValue] & 0x01 ? NOTIFY_ENABLED : NOTIFY_DISABLED;
        NSString* indicateState = [value integerValue] & 0x02 ? INDICATE_ENABLED : INDICATE_DISABLED;
        descriptorValueInformation = [NSString stringWithFormat:@"%@ \n%@", notifyState, indicateState];
    }else if ([UUID isEqual:DESCRIPTOR_SERVER_CHARACTERISTIC_CONFIG_UUID]) {
        descriptorValueInformation = value ? BROADCAST_ENABLED : BOADCAST_DISABLED;
    }else if ([UUID isEqual:DESCRIPTOR_CHARACTERISTIC_PRESENTATION_FORMAT_UUID]) {
        descriptorValueInformation = @"";
    }else if ([UUID isEqual:DESCRIPTOR_CHARACTERISTIC_AGGREGATE_FORMAT_UUID]) {
        descriptorValueInformation = @"";
    }else if ([UUID isEqual:DESCRIPTOR_VALID_RANGE_UUID]) {
        descriptorValueInformation = @"";
    }else if ([UUID isEqual:DESCRIPTOR_EXTERNAL_REPORT_REFERENCE_UUID]) {
        descriptorValueInformation = @"";
    }else if ([UUID isEqual:DESCRIPTOR_REPORT_REFERENCE_UUID]) {
        descriptorValueInformation = @"";
    }else if ([UUID isEqual:DESCRIPTOR_ENVIRONMENTAL_SENSING_CONFIG_UUID]) {
        descriptorValueInformation = @"";
    }else if ([UUID isEqual:DESCRIPTOR_ENVIRONMENTAL_SENSING_MEASUREMENT_UUID]) {
        descriptorValueInformation = @"";
    }else if ([UUID isEqual:DESCRIPTOR_ENVIRONMENTAL_SENSING_TRIGGER_SETTING_UUID]) {
        descriptorValueInformation = @"";
    }
    return descriptorValueInformation;
}

/*!
 *  @method dataFromHexString:
 *
 *  @discussion Converts HEX string (Little Endian) to byte array (Little Endian)
 *
 */
+(NSData *) dataFromHexString:(NSString *)string {
    return [Utilities dataFromHexString:string isLSB:YES];
}

/*!
 *  @method dataFromHexString:isLSB:
 *
 *  @discussion Converts HEX string (LSB/MSB) to byte array (LSB)
 *
 */
+(NSData *)dataFromHexString:(NSString *)string isLSB:(BOOL)isLSB {
    NSMutableData *data = [NSMutableData new];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];//Removing spaces
    string = [string lowercaseString];//Lowercase
    NSCharacterSet *illegalSymbols = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdef"] invertedSet];

    // Check whether the string is a valid hex string, otherwise return empty data
    if ([string rangeOfCharacterFromSet:illegalSymbols].location == NSNotFound) {
        // Pad to complete bytes
        string = [string paddedHexStringLSB:isLSB];

        unsigned char wholeByte;
        char byteChars[3] = {'\0','\0','\0'};

        if (isLSB) {
            for (int i = 0, n = (int)string.length; i < n - 1; i += 2) {
                byteChars[0] = [string characterAtIndex:i];
                byteChars[1] = [string characterAtIndex:i + 1];
                wholeByte = strtol(byteChars, NULL, 16);
                [data appendBytes:&wholeByte length:1];
            }
        } else {
            for (int n = (int)string.length, i = n - 2; i >= 0; i -= 2) {
                byteChars[0] = [string characterAtIndex:i];
                byteChars[1] = [string characterAtIndex:i + 1];
                wholeByte = strtol(byteChars, NULL, 16);
                [data appendBytes:&wholeByte length:1];
            }
        }
    }
    return data;
}

/*!
 *  @method ASCIIStringFromData:
 *
 *  @discussion Get ASCII string from NSData
 *
 */
+(NSString *)ASCIIStringFromData:(NSData *)data
{
    NSMutableString *string = [NSMutableString stringWithString:@""];

    for (int i = 0; i < data.length; i++)
    {
        unsigned char byte;
        [data getBytes:&byte range:NSMakeRange(i, 1)];

        if (byte >= 32 && byte < 127)
        {
            [string appendFormat:@"%c", byte];
        }
    }
    return string;
}

/*!
 *  @method captureScreenShot
 *
 *  @discussion Method to capture the currrent screen shot
 *
 */

+(UIImage *) captureScreenShot
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions([UIApplication sharedApplication].keyWindow.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext([UIApplication sharedApplication].keyWindow.bounds.size);

    UIGraphicsBeginImageContext([UIApplication sharedApplication].keyWindow.bounds.size);
    [[UIApplication sharedApplication].keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

/*!
 *  @method getIntegerFromHexString:
 *
 *  @discussion Method that returns the integer from hex string
 *
 */
+(unsigned int) getIntegerFromHexString:(NSString *)hexString
{
    unsigned int integerValue;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&integerValue];

    return integerValue;
}

/*!
 *  @method convertDataToLoggerFormat:
 *
 *  @discussion Method that returns the data to logger forma string
 *
 */

+(NSString *) convertDataToLoggerFormat:(NSData *)data
{
    NSString *dataString = [data hexString];
    NSString *tempString = @"";

    if (dataString.length != 0)
    {
        int i = 0;
        for (; i < dataString.length-1; i++)
        {
            if ((i%2) != 0)
            {
                tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%c ",[dataString characterAtIndex:i]]];
            }
            else
                tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%c",[dataString characterAtIndex:i]]];
        }
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%c",[dataString characterAtIndex:i]]];

    }
    else
        tempString = @" ";

    NSString *logString = [NSString stringWithFormat:@"[%@]",tempString];
    return logString;
}

/*!
 *  @method logDataWithService: characteristic: descriptor: operation:
 *
 *  @discussion Method to log the data
 *
 */

+(void) logDataWithService:(NSString *)serviceName characteristic:(NSString *)characteristicName descriptor:(NSString *)descriptorName operation:(NSString *)operationInfo
{
    if (descriptorName != nil)
    {
        [[LoggerHandler logManager] addLogData:[NSString stringWithFormat:@"[%@|%@|%@] %@", serviceName, characteristicName, descriptorName, operationInfo]];
    }
    else
    {
        [[LoggerHandler logManager] addLogData:[NSString stringWithFormat:@"[%@|%@] %@", serviceName, characteristicName, operationInfo]];
    }
}


/*!
 *  @method convertSFLOATFromData:
 *
 *  @discussion Method to convert the SFLOAT to simple float
 *
 */

+(float) convertSFLOATFromData:(int16_t)tempData{

    int16_t exponent = (tempData & 0xF000) >> 12;
    int16_t mantissa = (int16_t)(tempData & 0x0FFF);

    if (mantissa >= 0x0800)
        mantissa = -(0x1000 - mantissa);
    if (exponent >= 0x08)
        exponent = -(0x10 - exponent);

    float tempValue = (float)(mantissa*pow(10, exponent));
    return tempValue;
}

/*!
 * @method parse2ByteValueLittleFromByteArray:
 *
 * @discussion Returns uint16_t Little Endian from byte array
 *
 */
+(uint16_t) parse2ByteValueLittleFromByteArray:(uint8_t *)buf
{
    return ((uint16_t)buf[0]) | (((uint16_t)buf[1]) << 8);
}

/*!
 * @method parse4ByteValueLittleFromByteArray:
 *
 * @discussion Returns uint32_t Little Endian from byte array
 *
 */
+(uint32_t) parse4ByteValueLittleFromByteArray:(uint8_t *)buf
{
    return ((uint32_t)[self parse2ByteValueLittleFromByteArray:buf]) | (((uint32_t)[self parse2ByteValueLittleFromByteArray:(buf + 2)]) << 16);
}

/*!
 * @method HEXStringLittleFromByteArray:ofSize:
 *
 * @discussion Returns HEX string Little Endian from byte array
 *
 */
+(NSString *) HEXStringLittleFromByteArray:(uint8_t *)buf ofSize:(int)size
{
    NSMutableString * s = [NSMutableString stringWithCapacity:(size * 2)];
    for (int i = (size - 1); i >= 0; i--)
    {
        [s appendFormat:@"%02x", buf[i]];
    }
    return s;
}

/*!
 * @method CRC32ForByteArray: ofSize:
 *
 * @discussion Computes CRC32 for bytes in byte array
 *
 */
+(uint32_t) CRC32ForByteArray:(uint8_t *)buf ofSize:(uint32_t)size
{
    enum {
        g0 = 0x82F63B78,
        g1 = (g0 >> 1) & 0x7fffffff,
        g2 = (g0 >> 2) & 0x3fffffff,
        g3 = (g0 >> 3) & 0x1fffffff,
    };
    const static uint32_t table[16] =
    {
        0,                  (uint32_t)g3,           (uint32_t)g2,           (uint32_t)(g2^g3),
        (uint32_t)g1,       (uint32_t)(g1^g3),      (uint32_t)(g1^g2),      (uint32_t)(g1^g2^g3),
        (uint32_t)g0,       (uint32_t)(g0^g3),      (uint32_t)(g0^g2),      (uint32_t)(g0^g2^g3),
        (uint32_t)(g0^g1),  (uint32_t)(g0^g1^g3),   (uint32_t)(g0^g1^g2),   (uint32_t)(g0^g1^g2^g3),
    };

    uint8_t* data = (uint8_t*)buf;
    uint32_t crc = 0xFFFFFFFF;
    while (size != 0)
    {
        int i;
        --size;
        crc = crc ^ (*data);
        ++data;
        for (i = 1; i >= 0; i--)
        {
            crc = (crc >> 4) ^ table[crc & 0xF];
        }
    }
    return ~crc;
}

/*!
 * @method sortDates: withNewestFirst
 *
 * @discussion Sorts the array with dates
 *
 */
+(NSArray *) sortDates:(NSArray *)inputArray withNewestFirst:(BOOL)isNewestFirst; {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = DATE_FORMAT;
    
    NSArray *result = [inputArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        // Convert objects to strings
        NSString* name1 = (NSString*)obj1;
        NSString* name2 = (NSString*)obj2;
        // Then to dates
        NSDate *date1 = [dateFormatter dateFromString:name1];
        NSDate *date2 = [dateFormatter dateFromString:name2];
        // And compare the dates
        return isNewestFirst ? [date2 compare:date1] : [date1 compare:date2];
    }];
    return result;
}

@end

