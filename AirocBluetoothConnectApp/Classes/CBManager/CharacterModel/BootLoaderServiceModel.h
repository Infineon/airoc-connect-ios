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

#import <Foundation/Foundation.h>

@interface BootLoaderServiceModel : NSObject

/*!
 *  @property siliconIDString
 *
 *  @discussion siliconID from the device response
 *
 */
@property (strong,nonatomic) NSString * siliconIDString;

/*!
 *  @property siliconRevString
 *
 *  @discussion silicon rev from the device response
 *
 */
@property (strong,nonatomic) NSString * siliconRevString;

/*!
 *  @property blVersionString
 *
 *  @discussion bootloader SDK version from the device response
 *
 */
@property (strong,nonatomic) NSString * bootloaderVersionString;

/*!
 *  @property isProgramRowDataSuccess
 *
 *  @discussion flag used to check if sending o fdata succeeded
 *
 */
@property (nonatomic) BOOL isProgramRowDataSuccess;

/*!
 *  @property isSendRowDataSuccess
 *
 *  @discussion flag used to check if programming of data succeeded
 *
 */
@property (nonatomic) BOOL isSendRowDataSuccess;

/*!
 *  @property startRowNumber
 *
 *  @discussion Device flash start row number
 *
 */
@property (nonatomic) int startRowNumber;

/*!
 *  @property endRowNumber
 *
 *  @discussion Device flash end row number
 *
 */
@property (nonatomic) int endRowNumber;

/*!
 *  @property checkSum
 *
 *  @discussion checkSum received from the device for writing a single row
 *
 */
@property (nonatomic) uint8_t checksum;

/*!
 * @property fileVersion
 *
 * @discussion firmware file version, e.g. 0 for CYACD, 1 for CYACD2
 *
 */
@property (nonatomic) uint8_t fileVersion;

/*!
 *  @property isAppValid
 *
 *  @discussion flag used to check whether the application writing is success
 *
 */
@property (nonatomic) BOOL isAppValid;

/*!
 *  @property isDualAppBootloaderAppValid
 *
 *  @discussion Dual App Bootlooader only: YES if programmed app checksum is valid; NO otherwise.
 *
 */
@property (nonatomic) BOOL isDualAppBootloaderAppValid;

/*!
 *  @property isDualAppBootloaderAppActive
 *
 *  @discussion Dual App Bootlooader only: YES if the application to be programmed is currently active; NO otherwise.
 *
 */
@property (nonatomic) BOOL isDualAppBootloaderAppActive;

/*!
 * @property isWriteWithoutResponseSupported
 *
 * @discussion TRUE if write w/o response is supported by the bootloader characteristic
 *
 */
@property (nonatomic, readonly) BOOL isWriteWithoutResponseSupported;

/*!
 *  @method discoverCharacteristicsWithCompletionHandler:
 *
 *  @discussion Method to discover the specified characteristics of a service.
 *
 */
-(void) discoverCharacteristicsWithCompletionHandler:(void (^) (BOOL success, NSError *error)) handler;

/*!
 *  @method enableNotificationForBootloaderCharacteristicAndSetCharacteristicUpdateHandler:
 *
 *  @discussion Enables notification for bootloader characteristic and sets notification handler
 *
 */
-(void) enableNotificationForBootloaderCharacteristicAndSetNotificationHandler:(void (^) (NSError *error, id command, unsigned char otaError)) handler;

/*!
 *  @method writeValueToCharacteristicWithData: bootLoaderCommandCode:
 *
 *  @discussion Method to write data to the device
 *
 */
-(void) writeCharacteristicValueWithData:(NSData *)data command:(unsigned short)commandCode;

/*!
 *  @method stopUpdate
 *
 *  @discussion Method to stop notifications or indications for the specified characteristic.
 *
 */
-(void) stopUpdate;

/*!
 *  @method createCommandPacketWithCommand: dataLength: data:
 *
 *  @discussion Method to create the command packet from the host
 *
 */
-(NSData *) createPacketWithCommandCode:(uint8_t)command dataLength:(unsigned short)dataLength data:(NSDictionary *)dataDict;

/*!
 *  @method createCommandPacketWithCommand_v1: dataLength: data:
 *
 *  @discussion Method to create the command packet from the host
 *
 */
-(NSData *) createPacketWithCommandCode_v1:(uint8_t)command dataLength:(unsigned short)dataLength data:(NSDictionary *)dataDict;

/*!
 *  @method setCheckSumType:
 *
 *  @discussion Method to set the checksum calculation type
 *
 */
-(void) setCheckSumType:(NSString *)type;

/*!
 *  @method translateErrorCode:
 *
 *  @discussion Return error message for error code
 */
-(NSString *) errorMessageForErrorCode:(unsigned char)errorCode;

@end
