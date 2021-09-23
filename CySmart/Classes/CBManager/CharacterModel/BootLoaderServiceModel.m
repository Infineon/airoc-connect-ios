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

#import "BootLoaderServiceModel.h"

#import "CyCBManager.h"
#import "Constants.h"

#define COMMAND_PACKET_MIN_SIZE  7

//Start of packet (1 byte) + command (1 byte) + data length (2 bytes)
#define COMMAND_PACKET_HEADER    4

#define DEFAULT_GATT_MTU        20

/*!
 *  @class BootLoaderServiceModel
 *
 *  @discussion Class to handle the bootloader service related operations
 *
 */
@interface BootLoaderServiceModel ()<cbCharacteristicManagerDelegate>
{
    void (^cbCharacteristicDiscoverHandler)(BOOL success, NSError *error);
    void (^cbBootloaderCharacteristicNotificationHandler)(NSError *error, id command, unsigned char otaError);
    CBCharacteristic * bootloaderCharacteristic;
    
    NSMutableArray * commandArray;
    NSString * checkSumType;
    unsigned int negotiatedGattMtu;
}

@end


@implementation BootLoaderServiceModel

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        commandArray = [[NSMutableArray alloc] init];
        negotiatedGattMtu = DEFAULT_GATT_MTU;
        _isWriteWithoutResponseSupported = NO;
    }
    return self;
}

/*!
 *  @method setCheckSumType:
 *
 *  @discussion Method to set the checksum calculation type
 *
 */
-(void) setCheckSumType:(NSString *) type
{
    checkSumType = type;
}

/*!
 *  @method discoverCharacteristicsWithCompletionHandler:
 *
 *  @discussion Method to discover the specified characteristics of a service.
 *
 */
-(void) discoverCharacteristicsWithCompletionHandler:(void (^) (BOOL success, NSError *error)) handler
{
    cbCharacteristicDiscoverHandler = handler;
    [[CyCBManager sharedManager] setCbCharacteristicDelegate:self];
    [[[CyCBManager sharedManager] myPeripheral] discoverCharacteristics:nil forService:[[CyCBManager sharedManager] myService]];
}

/*!
 *  @method enableNotificationForBootloaderCharacteristicAndSetCharacteristicUpdateHandler:
 *
 *  @discussion Enables notification for bootloader characteristic and sets notification handler
 *
 */
-(void) enableNotificationForBootloaderCharacteristicAndSetNotificationHandler:(void (^) (NSError *error, id command, unsigned char otaCommand)) handler
{
    cbBootloaderCharacteristicNotificationHandler = handler;
    
    if (bootloaderCharacteristic != nil)
    {
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:bootloaderCharacteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:bootloaderCharacteristic.UUID] descriptor:nil operation:START_NOTIFY];
        
        [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:YES forCharacteristic:bootloaderCharacteristic];
    }
}

/*!
 *  @method writeValueToCharacteristicWithData: bootLoaderCommandCode:
 *
 *  @discussion Method to write data to the device
 *
 */
-(void) writeCharacteristicValueWithData:(NSData *)data command:(unsigned short)commandCode
{
    if (data != nil && bootloaderCharacteristic != nil)
    {
        if (commandCode)
        {
            [commandArray addObject:@(commandCode)];
        }
        
        NSString * serviceName = [ResourceHandler getServiceNameForUUID:bootloaderCharacteristic.service.UUID];
        NSString * characteristicName = [ResourceHandler getCharacteristicNameForUUID:bootloaderCharacteristic.UUID];
        NSString * operationInfo = [NSString stringWithFormat:@"%@%@ %@",WRITE_REQUEST,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:data]];
        [Utilities logDataWithService:serviceName characteristic:characteristicName descriptor:nil operation:operationInfo];
        
        if (self.isWriteWithoutResponseSupported)
        {
            NSUInteger totalLength = data.length;
            NSUInteger localLength = 0;
            uint8_t localBytes[negotiatedGattMtu];
            NSData *localData;
            //Write data by chunks of 20 bytes
            do
            {
                if (totalLength > negotiatedGattMtu)
                {
                    for (int i = 0; i < negotiatedGattMtu; i++)
                    {
                        localBytes[i] = ((uint8_t *)data.bytes)[localLength + i];
                    }
                    localData = [NSMutableData dataWithBytes:localBytes length:negotiatedGattMtu];
                    totalLength -= negotiatedGattMtu;
                    localLength += negotiatedGattMtu;
                }
                else
                {
                    uint8_t lastBytes[totalLength];
                    for (int i = 0; i < totalLength; i++)
                    {
                        lastBytes[i] = ((uint8_t *)data.bytes)[localLength + i];
                    }
                    localData = [NSMutableData dataWithBytes:lastBytes length:totalLength];
                    totalLength = 0;
                }
                
                [[[CyCBManager sharedManager] myPeripheral] writeValue:localData forCharacteristic:bootloaderCharacteristic type:CBCharacteristicWriteWithoutResponse];
            }
            while (totalLength > 0);
        }
        else
        {
            [[[CyCBManager sharedManager] myPeripheral] writeValue:data forCharacteristic:bootloaderCharacteristic type:CBCharacteristicWriteWithResponse];
        }
    }
}

/*!
 *  @method stopUpdate
 *
 *  @discussion Method to stop notifications or indications for the specified characteristic.
 *
 */
-(void) stopUpdate
{
    cbBootloaderCharacteristicNotificationHandler = nil;
    [commandArray removeAllObjects];
    
    if (bootloaderCharacteristic != nil)
    {
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:bootloaderCharacteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:bootloaderCharacteristic.UUID] descriptor:nil operation:STOP_NOTIFY];
        
        [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:NO forCharacteristic:bootloaderCharacteristic];
    }
}

#pragma mark - CBCharacteristicManagerDelegate Methods


/*!
 *  @method peripheral: didDiscoverCharacteristicsForService: error:
 *
 *  @discussion Method invoked when characteristics are discovered for a service
 *
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:CUSTOM_BOOT_LOADER_SERVICE_UUID])
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            if ([characteristic.UUID isEqual:BOOT_LOADER_CHARACTERISTIC_UUID])
            {
                bootloaderCharacteristic = characteristic;
                
                if ((characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0)
                {
                    if ([peripheral respondsToSelector:@selector(maximumWriteValueLengthForType:)]) {
                        negotiatedGattMtu = (unsigned int)[peripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithoutResponse];
                    }
                    _isWriteWithoutResponseSupported = YES;
                }
                else if ((characteristic.properties & CBCharacteristicPropertyWrite) != 0)
                {
                    if ([peripheral respondsToSelector:@selector(maximumWriteValueLengthForType:)]) {
                        negotiatedGattMtu = (unsigned int)[peripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithResponse];
                    }
                    _isWriteWithoutResponseSupported = NO;
                }

                cbCharacteristicDiscoverHandler(YES,nil);
            }
        }
    }
    else
    {
        cbCharacteristicDiscoverHandler(NO,error);
    }
}

/*!
 *  @method peripheral: didUpdateValueForCharacteristic: error:
 *
 *  @discussion Invoked on the characteristic value change/read
 *
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error == nil) {
        if ([characteristic.UUID isEqual:BOOT_LOADER_CHARACTERISTIC_UUID]) {
            if (commandArray.count <= 0) {
                NSLog(@"ERROR: BootloaderServiceModel peripheral:didUpdateValueForCharacteristic: empty commandArray");
            } else {
                unsigned char *bytes = (unsigned char *) [characteristic.value bytes];
                unsigned char otaError = bytes[1];
                if (iFileVersionTypeCYACD2 == self.fileVersion) {
                    // Checking the error code from the response
                    if (SUCCESS == otaError) {
                        if([[commandArray objectAtIndex:0] isEqual:@(ENTER_BOOTLOADER)] || [[commandArray objectAtIndex:0] isEqual:@(POST_SYNC_ENTER_BOOTLOADER)]) {
                            [self getBootloaderDataFromCharacteristic_v1:characteristic];
                        } else if ([[commandArray objectAtIndex:0] isEqual:@(SEND_DATA)]) {
                            _isSendRowDataSuccess = YES;
                        } else if ([[commandArray objectAtIndex:0] isEqual:@(PROGRAM_DATA)] || [[commandArray objectAtIndex:0] isEqual:@(SET_EIV)]) {
                            _isProgramRowDataSuccess = YES;
                        } else if([[commandArray objectAtIndex:0] isEqual:@(VERIFY_APP)]) {
                            [self checkApplicationCheckSumFromCharacteristic:characteristic];
                        }
                    } else {
                        if ([[commandArray objectAtIndex:0] isEqual:@(SEND_DATA)]) {
                            _isSendRowDataSuccess = NO;
                        } else if ([[commandArray objectAtIndex:0] isEqual:@(PROGRAM_DATA)] || [[commandArray objectAtIndex:0] isEqual:@(SET_EIV)]) {
                            _isProgramRowDataSuccess = NO;
                        } else if ([[commandArray objectAtIndex:0] isEqual:@(VERIFY_APP)]) {
                            _isAppValid = NO;
                        }
                    }
                    if (nil != cbBootloaderCharacteristicNotificationHandler) {
                        cbBootloaderCharacteristicNotificationHandler(error, [commandArray objectAtIndex:0], otaError);
                        [commandArray removeObjectAtIndex:0];
                    }
                } else { //CYACD
                    // Checking the error code from the response
                    if (SUCCESS == otaError) {
                        if ([[commandArray objectAtIndex:0] isEqual:@(ENTER_BOOTLOADER)]) {
                            [self getBootloaderDataFromCharacteristic:characteristic];
                        } else if ([[commandArray objectAtIndex:0] isEqual:@(GET_APP_STATUS)]) {
                            uint8_t *bytes = (uint8_t *)[characteristic.value bytes];
                            uint8_t appValid = bytes[4];
                            uint8_t appActive = bytes[5];
                            _isDualAppBootloaderAppValid = appValid > 0;
                            _isDualAppBootloaderAppActive = appActive > 0;
                        } else if ([[commandArray objectAtIndex:0] isEqual:@(GET_FLASH_SIZE)]) {
                            [self getFlashDataFromCharacteristic:characteristic];
                        } else if ([[commandArray objectAtIndex:0] isEqual:@(SEND_DATA)]) {
                            _isSendRowDataSuccess = YES;
                        } else if ([[commandArray objectAtIndex:0] isEqual:@(PROGRAM_ROW)]) {
                            _isProgramRowDataSuccess = YES;
                        } else if ([[commandArray objectAtIndex:0] isEqual:@(VERIFY_ROW)]) {
                            [self getRowCheckSumFromCharacteristic:characteristic];
                        } else if([[commandArray objectAtIndex:0] isEqual:@(VERIFY_CHECKSUM)]) {
                            [self checkApplicationCheckSumFromCharacteristic:characteristic];
                        }
                    } else {
                        if ([[commandArray objectAtIndex:0] isEqual:@(SEND_DATA)]) {
                            _isSendRowDataSuccess = NO;
                        } else if ([[commandArray objectAtIndex:0] isEqual:@(PROGRAM_ROW)]) {
                            _isProgramRowDataSuccess = NO;
                        }
                    }
                    if (nil != cbBootloaderCharacteristicNotificationHandler) {
                        cbBootloaderCharacteristicNotificationHandler(error, [commandArray objectAtIndex:0], otaError);
                        [commandArray removeObjectAtIndex:0];
                    }
                }
            }
        }
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@", NOTIFY_RESPONSE, DATA_SEPERATOR, [Utilities convertDataToLoggerFormat:characteristic.value]]];
    } else {
        cbBootloaderCharacteristicNotificationHandler(error, 0, ERR_UNKNOWN);
    }
}

/*!
 *  @method getBootloaderDataFromCharacteristic:
 *
 *  @discussion Method to parse the characteristic value to get the siliconID and silicon rev string
 *
 */
-(void) getBootloaderDataFromCharacteristic:(CBCharacteristic *) characteristic
{
    uint8_t *dataPointer = (uint8_t *)[characteristic.value bytes];
    
    // Move to the position of data field
    dataPointer += COMMAND_PACKET_HEADER;
    
    // Get silicon Id
    NSMutableString *siliconIDString = [NSMutableString stringWithCapacity:8];
    for (int i = 3; i >= 0; i--)
    {
        [siliconIDString appendFormat:@"%02x",(unsigned int)dataPointer[i]];
    }
    _siliconIDString = siliconIDString;
    
    // Get silicon Rev
    NSMutableString *siliconRevString = [NSMutableString stringWithCapacity:2];
    [siliconRevString appendFormat:@"%02x",(unsigned int)dataPointer[4]];
    _siliconRevString = siliconRevString;
}

/*!
 *  @method getBootloaderDataFromCharacteristic_v1:
 *
 *  @discussion Method to parse characteristic value to get siliconID, siliconRev and bootloader SDK version
 *
 */
-(void) getBootloaderDataFromCharacteristic_v1:(CBCharacteristic *) characteristic
{
    uint8_t * dataPointer = (uint8_t *)[characteristic.value bytes];
    
    dataPointer += COMMAND_PACKET_HEADER;
    const int siliconIdLength = 4;
    _siliconIDString = [Utilities HEXStringLittleFromByteArray:dataPointer ofSize:siliconIdLength];
    
    dataPointer += siliconIdLength;
    const int siliconRevLength = 1;
    _siliconRevString = [Utilities HEXStringLittleFromByteArray:dataPointer ofSize:siliconRevLength];
    
    dataPointer += siliconRevLength;
    const int bootloaderVersionLength = 3;
    _bootloaderVersionString = [Utilities HEXStringLittleFromByteArray:dataPointer ofSize:bootloaderVersionLength];
}

/*!
 *  @method getFlashDataFromCharacteristic:
 *
 *  @discussion Method to parse the characteristic value to get the flash start and end row number
 *
 */
-(void) getFlashDataFromCharacteristic:(CBCharacteristic *)charatceristic
{
    uint8_t * dataPointer = (uint8_t *)[charatceristic.value bytes];
    
    dataPointer += 4;

    uint16_t firstRowNumber = CFSwapInt16LittleToHost(*(uint16_t *) dataPointer);
    
    dataPointer += 2;
    
    uint16_t lastRowNumber = CFSwapInt16LittleToHost(*(uint16_t *) dataPointer);

    _startRowNumber = firstRowNumber;
    _endRowNumber = lastRowNumber;
}

/*!
 *  @method getRowCheckSumFromCharacteristic:
 *
 *  @discussion Method to parse the characteristic value to get the row checksum
 *
 */
-(void) getRowCheckSumFromCharacteristic:(CBCharacteristic *)characteristic
{
    uint8_t * dataPointer = (uint8_t *)[characteristic.value bytes];
    
    _checksum = dataPointer[4];
}

/*!
 *  @method checkApplicationCheckSumFromCharacteristic:
 *
 *  @discussion Method to parse the characteristic value to get the application checksum
 *
 */
-(void) checkApplicationCheckSumFromCharacteristic:(CBCharacteristic *) characteristic
{
    uint8_t *dataPointer = (uint8_t *)[characteristic.value bytes];
    int chksumValid = dataPointer[4];
    if (chksumValid > 0)
    {
        _isAppValid = YES;
    }
    else
    {
        _isAppValid = NO;
    }
}

/*!
 *  @method createPacketWithCommandCode: dataLength: data:
 *
 *  @discussion Method to create the command packet from the host
 *
 */
-(NSData *) createPacketWithCommandCode:(uint8_t)commandCode dataLength:(unsigned short)dataLength data:(NSDictionary *)dataDict {
    int idx = 0;
    unsigned char *commandPacket =  (unsigned char *)malloc((COMMAND_PACKET_MIN_SIZE + dataLength) * sizeof(unsigned char));
    
    commandPacket[idx++] = COMMAND_START_BYTE;
    commandPacket[idx++] = commandCode;
    commandPacket[idx++] = dataLength;
    commandPacket[idx++] = dataLength >> 8;
    
    if (ENTER_BOOTLOADER == commandCode) {
        NSData *securityKeyData = [dataDict objectForKey:SECURITY_KEY];
        if (securityKeyData) {
            for (int i = 0; i < securityKeyData.length; ++i) {
                commandPacket[idx++] = ((unsigned char *)[securityKeyData bytes])[i];
            }
        }
    }
    
    if (GET_APP_STATUS == commandCode) {
        NSInteger activeApp = [[dataDict objectForKey:ACTIVE_APP] integerValue];
        commandPacket[idx++] = activeApp;
    }
    
    if (GET_FLASH_SIZE == commandCode) {
        uint8_t flashArrayID = [[dataDict objectForKey:FLASH_ARRAY_ID] integerValue];
        commandPacket[idx++] = flashArrayID;
    }
    
    if (PROGRAM_ROW == commandCode ||  VERIFY_ROW == commandCode) {
        uint8_t flashArrayID = [[dataDict objectForKey:FLASH_ARRAY_ID] integerValue];
        unsigned short flashRowNumber = [[dataDict objectForKey:FLASH_ROW_NUMBER] integerValue];
        commandPacket[idx++] = flashArrayID;
        commandPacket[idx++] = flashRowNumber;
        commandPacket[idx++] = flashRowNumber >> 8;
    }
    
    //Add the data to send to the command packet
    if (SEND_DATA == commandCode || PROGRAM_ROW == commandCode) {
        NSArray * dataArray = [dataDict objectForKey:ROW_DATA];
        for (int i = 0; i<dataArray.count; i++) {
            NSString * value = dataArray[i];
            
            unsigned int outVal;
            NSScanner * scanner = [NSScanner scannerWithString:value];
            [scanner scanHexInt:&outVal];
            
            unsigned short valueToWrite = (unsigned short)outVal;
            commandPacket[idx++] = valueToWrite;
        }
    }
    
    if (SET_ACTIVE_APP == commandCode) {
        NSInteger activeApp = [[dataDict objectForKey:ACTIVE_APP] integerValue];
        commandPacket[idx++] = activeApp;
    }
   
    unsigned short checkSum  = [self calculateChecksumWithCommandPacket:commandPacket withSize:(idx) type:checkSumType];
    commandPacket[idx++] = checkSum;
    commandPacket[idx++] = checkSum >> 8;
    commandPacket[idx++] = COMMAND_END_BYTE;
    
    NSData *data = [NSData dataWithBytes:commandPacket length:(idx)];
    free(commandPacket);
    
    return data;
}

/*!
 *  @method createPacketWithCommandCode_v1: dataLength: data:
 *
 *  @discussion Method to create the command packet from the host
 *
 */
-(NSData *) createPacketWithCommandCode_v1:(uint8_t)commandCode dataLength:(unsigned short)dataLength data:(NSDictionary *)dataDict
{
    int idx = 0;
    unsigned char *commandPacket =  (unsigned char *)malloc((COMMAND_PACKET_MIN_SIZE + dataLength) * sizeof(unsigned char));
    
    commandPacket[idx++] = COMMAND_START_BYTE;
    commandPacket[idx++] = commandCode;
    commandPacket[idx++] = dataLength;
    commandPacket[idx++] = dataLength >> 8;
    
    if (ENTER_BOOTLOADER == commandCode)
    {
        uint32_t productID = [[dataDict objectForKey:PRODUCT_ID] unsignedIntValue];
        commandPacket[idx++] = productID;
        commandPacket[idx++] = productID >> 8;
        commandPacket[idx++] = productID >> 16;
        commandPacket[idx++] = productID >> 24;
    }
    if (SET_APP_METADATA == commandCode)
    {
        uint8_t appID = [[dataDict objectForKey:APP_ID] unsignedCharValue];
        commandPacket[idx++] = appID;
        
        uint32_t appStartAddr = [[dataDict objectForKey:APP_META_APP_START] unsignedIntValue];
        commandPacket[idx++] = appStartAddr;
        commandPacket[idx++] = appStartAddr >> 8;
        commandPacket[idx++] = appStartAddr >> 16;
        commandPacket[idx++] = appStartAddr >> 24;

        uint32_t appSize = [[dataDict objectForKey:APP_META_APP_SIZE] unsignedIntValue];
        commandPacket[idx++] = appSize;
        commandPacket[idx++] = appSize >> 8;
        commandPacket[idx++] = appSize >> 16;
        commandPacket[idx++] = appSize >> 24;
    }
    if (PROGRAM_DATA == commandCode)
    {
        uint32_t addr = [[dataDict objectForKey:ADDRESS] unsignedIntValue];
        commandPacket[idx++] = addr;
        commandPacket[idx++] = addr >> 8;
        commandPacket[idx++] = addr >> 16;
        commandPacket[idx++] = addr >> 24;

        uint32_t crc32 = [[dataDict objectForKey:CRC_32] unsignedIntValue];
        commandPacket[idx++] = crc32;
        commandPacket[idx++] = crc32 >> 8;
        commandPacket[idx++] = crc32 >> 16;
        commandPacket[idx++] = crc32 >> 24;
    }
    if (VERIFY_APP == commandCode)
    {
        uint8_t appID = [[dataDict objectForKey:APP_ID] unsignedCharValue];
        commandPacket[idx++] = appID;
    }
    if (SET_EIV == commandCode || SEND_DATA == commandCode || PROGRAM_DATA == commandCode)
    {
        NSArray * dataArr = [dataDict objectForKey:ROW_DATA];
        for (NSString * byteStr in dataArr)
        {
            uint32_t byte;
            NSScanner * scanner = [NSScanner scannerWithString:byteStr];
            [scanner scanHexInt:&byte];
            commandPacket[idx++] = byte;
        }
    }
    
    uint16_t checkSum  = [self calculateChecksumWithCommandPacket:commandPacket withSize:(idx) type:checkSumType];
    commandPacket[idx++] = checkSum;
    commandPacket[idx++] = checkSum >> 8;
    commandPacket[idx++] = COMMAND_END_BYTE;
    
    NSData *data = [NSData dataWithBytes:commandPacket length:(idx)];
    free(commandPacket);
    
    return data;
}

/*!
 *  @method calculateChacksumWithCommandPacket: withSize: type:
 *
 *  @discussion Method to calculate the checksum
 *
 */
-(unsigned short) calculateChecksumWithCommandPacket:(unsigned char [])array withSize:(int)packetSize type:(NSString *)type
{
    if ([type isEqualToString:CHECK_SUM])
    {
        // Sum checksum
        unsigned short sum = 0;
        
        for (int i = 0; i< packetSize; i++)
        {
            sum = sum + array[i];
        }
        return ~sum+1;
    }
    else
    {
        // CRC 16
        unsigned short sum = 0xffff;
        
        unsigned short tmp;
        int i;
        
        if (packetSize == 0)
            return (~sum);
        
        do
        {
            for (i = 0, tmp = 0x00ff & *array++; i < 8; i++, tmp >>= 1)
            {
                if ((sum & 0x0001) ^ (tmp & 0x0001))
                    sum = (sum >> 1) ^ 0x8408;
                else
                    sum >>= 1;
            }
        }
        while (--packetSize);
        
        sum = ~sum;
        tmp = sum;
        sum = (sum << 8) | (tmp >> 8 & 0xFF);
        return sum;
    }
}

-(NSString *) errorMessageForErrorCode:(unsigned char)errorCode {
    switch(errorCode) {
        case ERR_FILE:
            return CYRET_ERR_FILE;
        case ERR_EOF:
            return CYRET_ERR_EOF;
        case ERR_LENGTH:
            return CYRET_ERR_LENGTH;
        case ERR_DATA:
            return CYRET_ERR_DATA;
        case ERR_COMMAND:
            return CYRET_ERR_COMMAND;
        case ERR_DEVICE:
            return CYRET_ERR_DEVICE;
        case ERR_VERSION:
            return CYRET_ERR_VERSION;
        case ERR_CHECKSUM:
            return CYRET_ERR_CHECKSUM;
        case ERR_ARRAY:
            return CYRET_ERR_ARRAY;
        case ERR_ROW:
            return CYRET_ERR_ROW;
        case ERR_BOOTLOADER:
            return CYRET_ERR_BOOTLOADER;
        case ERR_APPLICATION:
            return CYRET_ERR_APPLICATION;
        case ERR_ACTIVE:
            return CYRET_ERR_ACTIVE;
        case ERR_UNKNOWN:
            return CYRET_ERR_UNKNOWN;
        case ERR_ABORT:
            return CYRET_ERR_ABORT;
        default:
            return @"Unknown error code";
    }
}

@end
