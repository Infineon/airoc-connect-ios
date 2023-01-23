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

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Constants.h"
#import <UIKit/UIKit.h>


@interface Utilities : NSObject

/*!
 *  @method timeInFormat:
 *
 *  @discussion Method that converts seconds to minute:seconds format
 *
 */
+(NSString*)timeInFormat:(double)timeInterval;

/*!
 *  @method secondsToHour:
 *
 *  @discussion Method that converts seconds to hours
 *
 */

+(double)secondsToHour:(double)timeInterval;

/*!
 *  @method secondsToMinute:
 *
 *  @discussion Method that converts seconds to minute
 *
 */
+(double)secondsToMinute:(double)timeInterval;

/*!
 *  @method meterToKM:
 *
 *  @discussion Method that converts meter to km
 *
 */

+(double)meterToKM:(double)meter;

/*!
 *  @method getTodayDateString
 *
 *  @discussion Return today date string
 *
 */
+(NSString *)getTodayDateString;

/*!
 *  @method getTodayTimeString
 *
 *  @discussion Return today time string
 *
 */
+(NSString *)getTodayTimeString;

/*!
 *  @method getDiscriptorNameForUUID:
 *
 *  @discussion Method that returns descriptor name for given UUID
 *
 */
+(NSString *)getDiscriptorNameForUUID:(CBUUID *)UUID;

/*!
 *  @method getDescriptorValueInformation: andValue:
 *
 *  @discussion Method that returns descriptorValueInformation for given UUID
 *
 */

+(NSString *)getDescriptorValueInformation:(CBUUID *)UUID andValue:(NSNumber *)value;

/*!
 *  @method dataFromHexString:
 *
 *  @discussion Converts HEX string (Little Endian) to byte array (Little Endian)
 *
 */
+ (NSData *)dataFromHexString:(NSString *)string;

/*!
 *  @method dataFromHexString:isLSB:
 *
 *  @discussion Converts HEX string (LSB/MSB) to byte array (LSB)
 *
 */
+(NSData *) dataFromHexString:(NSString *)string isLSB:(BOOL)isLSB;

/*!
 *  @method ASCIIStringFromData:
 *
 *  @discussion Get ASCII string from NSData
 *
 */
+(NSString *)ASCIIStringFromData:(NSData *)data;

/*!
 *  @method captureScreenShot
 *
 *  @discussion Method to capture the currrent screen shot
 *
 */
+ (UIImage *)captureScreenShot;

/*!
 *  @method getIntegerFromHexString:
 *
 *  @discussion Method that returns the integer from hex string
 *
 */
+(unsigned int) getIntegerFromHexString:(NSString *)hexString;

/*!
 *  @method get128BitUUIDForUUID:
 *
 *  @discussion Method that returns the 128 bit UUID
 *
 */
+(NSString *)get128BitUUIDForUUID:(CBUUID *)UUID;

/*!
 *  @method convertDataToLoggerFormat:
 *
 *  @discussion Method that returns the data to logger forma string
 *
 */

+(NSString *) convertDataToLoggerFormat:(NSData *)data;

/*!
 *  @method logDataWithService: characteristic: descriptor: operation:
 *
 *  @discussion Method to log the data
 *
 */

+(void) logDataWithService:(NSString *)serviceName characteristic:(NSString *)characteristicName descriptor:(NSString *)descriptorName operation:(NSString *)operationInfo;

/*!
 *  @method convertSFLOATFromData:
 *
 *  @discussion Method to convert the SFLOAT to simple float
 *
 */

+(float) convertSFLOATFromData:(int16_t)tempData;

/*!
 * @method parse2ByteValueLittleFromByteArray:
 *
 * @discussion Returns uint16_t Little Endian from byte array
 *
 */
+(uint16_t) parse2ByteValueLittleFromByteArray:(uint8_t *)buf;

/*!
 * @method parse4ByteValueLittleFromByteArray:
 *
 * @discussion Returns uint32_t Little Endian from byte array
 *
 */
+(uint32_t) parse4ByteValueLittleFromByteArray:(uint8_t *)buf;

/*!
 * @method HEXStringLittleFromByteArray:ofSize:
 *
 * @discussion Returns HEX string Little Endian from byte array
 *
 */
+(NSString *) HEXStringLittleFromByteArray:(uint8_t *)buf ofSize:(int)size;

/*!
 * @method CRC32ForByteArray: ofSize:
 *
 * @discussion Computes CRC32 for bytes in byte array
 *
 */
+(uint32_t) CRC32ForByteArray:(uint8_t *)buf ofSize:(uint32_t)size;

@end
