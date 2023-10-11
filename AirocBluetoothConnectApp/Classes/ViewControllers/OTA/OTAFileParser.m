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

#import "OTAFileParser.h"
#import "Constants.h"
#import "Utilities.h"

#define FILE_HEADER_MAX_LENGTH      12
#define FILE_HEADER_MAX_LENGTH_V1   24
#define FILE_PARSER_ERROR_CODE      555

#define APPINFO_PREFIX                      @"@APPINFO:0x"
#define APPINFO_SEPARATOR                   @",0x"
#define EIV_PREFIX                          @"@EIV:"
#define DATA_PREFIX                         @":"

/*!
 *  @class OTAFileParser
 *
 *  @discussion Class to parse the bootloader file
 *
 */

@implementation OTAFileParser

/*!
 *  @method parseFirmwareFileWithName: andPath: onFinish:
 *
 *  @discussion Method for parsing the OTA firmware file (CYACD)
 *
 */
- (void) parseFirmwareFileWithName:(NSString *)fileName path:(NSString *)filePath onFinish:(void(^)(NSMutableDictionary * header, NSArray * rowData, NSArray * rowIdArray, NSError * error))finish
{
    NSMutableDictionary * fileHeaderDict = [NSMutableDictionary new];
    NSMutableArray * fileDataArray = [NSMutableArray new];
    NSMutableArray * rowIdArray = [NSMutableArray new];
    NSError * error;

    NSString * fileContents = [NSString stringWithContentsOfFile:[NSString pathWithComponents:[NSArray arrayWithObjects:filePath, fileName, nil]]
                                                        encoding:NSUTF8StringEncoding error:nil];
    if (fileContents && fileContents.length > 0)
    {
        // Separate by new line
        NSMutableArray * fileContentsArray = (NSMutableArray *)[fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        if (fileContentsArray)
        {
            fileContentsArray = [self removeEmptyRowsAndJunkDataFromArray:fileContentsArray];
            NSString * fileHeader = [fileContentsArray objectAtIndex:0];

            if (fileHeader.length >= FILE_HEADER_MAX_LENGTH)
            {
                //Parse header
                [fileHeaderDict setObject:[NSNumber numberWithInt:iFileVersionTypeCYACD] forKey:FILE_VERSION];//Version of 0 for CYACD files
                [fileHeaderDict setObject:[fileHeader substringWithRange:NSMakeRange(0, 8)] forKey:SILICON_ID];
                [fileHeaderDict setObject:[fileHeader substringWithRange:NSMakeRange(8, 2)] forKey:SILICON_REV];
                [fileHeaderDict setObject:[fileHeader substringWithRange:NSMakeRange(10, 2)] forKey:CHECKSUM_TYPE];
                [fileContentsArray removeObjectAtIndex:0];

                //Parse data row
                NSString * rowID = @"";
                int rowCount = 0;
                NSMutableDictionary * rowIdDict = [NSMutableDictionary new];
                NSCharacterSet * charsToRemove = [NSCharacterSet characterSetWithCharactersInString:@"@:"];

                for (int i = 0; i < fileContentsArray.count; i++)
                {
                    //Strip '@' and ':' prefix off
                    NSString * dataRowString = [fileContentsArray objectAtIndex:i];
                    dataRowString = [[dataRowString componentsSeparatedByCharactersInSet:charsToRemove] componentsJoinedByString:@""];
                    if (dataRowString.length > 20)
                    {

                        if ([self parseDataRowString:dataRowString] != nil)
                        {
                            [fileDataArray addObject:[self parseDataRowString:dataRowString]];

                            //Counting Rows in each RowID
                            if ([rowID  isEqual: @""])
                            {
                                rowID = [dataRowString substringWithRange:NSMakeRange(0, 2)];
                                rowCount++;
                            }
                            else if ([rowID isEqual:[dataRowString substringWithRange:NSMakeRange(0, 2)]] )
                            {
                                rowCount++;
                            }
                            else
                            {
                                [rowIdDict setValue:rowID forKey:ROW_ID];
                                [rowIdDict setValue:[NSNumber numberWithInt:rowCount] forKey:ROW_COUNT];
                                [rowIdArray addObject:(NSDictionary *)rowIdDict];
                                rowIdDict = [NSMutableDictionary new];
                                rowID = [dataRowString substringWithRange:NSMakeRange(0, 2)];
                                rowCount = 1;
                            }
                        }
                        else
                        {
                            error = [[NSError alloc] initWithDomain:PARSING_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"invalidFile") forKey:NSLocalizedDescriptionKey]];
                            finish(nil,nil,nil, error);
                        }
                    }
                    else
                    {
                        error = [[NSError alloc] initWithDomain:FILE_FORMAT_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"dataFormatInvalid") forKey:NSLocalizedDescriptionKey]];
                        finish(nil,nil,nil, error);
                        break;
                    }
                }

                if (!error)
                {
                    //Counting Rows in each RowID. Adding last RowID count to Dict.
                    [rowIdDict setValue:rowID forKey:ROW_ID];
                    [rowIdDict setValue:[NSNumber numberWithInt:rowCount] forKey:ROW_COUNT];
                    [rowIdArray addObject:(NSDictionary *)rowIdDict];
                    finish(fileHeaderDict, fileDataArray, rowIdArray, nil);
                }
            }
            else
            {
                error = [[NSError alloc] initWithDomain:PARSING_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"invalidFile") forKey:NSLocalizedDescriptionKey]];
                finish(nil,nil,nil, error);
            }
        }
        else
        {
            error = [[NSError alloc] initWithDomain:PARSING_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"parsingFailed") forKey:NSLocalizedDescriptionKey]];
            finish(nil,nil,nil, error);
        }
    }
    else
    {
        error = [[NSError alloc] initWithDomain:FILE_EMPTY_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"fileEmpty") forKey:NSLocalizedDescriptionKey]];
        finish(nil,nil,nil, error);
    }
}

/*!
 *  @method parseFirmwareFileWithName_v1: andPath: onFinish:
 *
 *  @discussion Parses the OTA firmware file (CYACD2)
 *
 */
- (void) parseFirmwareFileWithName_v1:(NSString *)fileName path:(NSString *)filePath onFinish:(void(^)(NSMutableDictionary *header, NSDictionary *appInfo, NSArray *rowData, NSError *error))finish
{
    NSMutableDictionary *fileHeaderDict = [NSMutableDictionary new];
    NSDictionary *appInfoDict = nil;
    NSMutableArray *fileDataArr = [NSMutableArray new];
    NSError *error;

    NSString *fileContents = [NSString stringWithContentsOfFile:[NSString pathWithComponents:[NSArray arrayWithObjects:filePath, fileName, nil]]
                                                        encoding:NSUTF8StringEncoding error:nil];
    if (fileContents && fileContents.length > 0)
    {
        // Separate by new line
        NSMutableArray * fileContentsArr = (NSMutableArray *)[fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        if (fileContentsArr)
        {
            fileContentsArr = [self removeEmptyRowsAndJunkDataFromArray:fileContentsArr];
            NSString * fileHeader = [fileContentsArr objectAtIndex:0];

            if (fileHeader.length >= FILE_HEADER_MAX_LENGTH_V1)
            {
                NSData * fileHeaderData = [Utilities dataFromHexString:fileHeader];
                uint8_t fileVersion = ((uint8_t *)[fileHeaderData bytes])[0];

                if (iFileVersionTypeCYACD2 == fileVersion)
                {
                    //Parse header
                    [fileHeaderDict setObject:[NSNumber numberWithInt:fileVersion] forKey:FILE_VERSION];

                    NSData * siliconIDData = [Utilities dataFromHexString:[fileHeader substringWithRange:NSMakeRange(2, 8)]];
                    NSString * siliconIDStr = [Utilities HEXStringLittleFromByteArray:(uint8_t *)[siliconIDData bytes] ofSize:4];
                    [fileHeaderDict setObject:siliconIDStr forKey:SILICON_ID];

                    [fileHeaderDict setObject:[fileHeader substringWithRange:NSMakeRange(10, 2)] forKey:SILICON_REV];
                    [fileHeaderDict setObject:[fileHeader substringWithRange:NSMakeRange(12, 2)] forKey:CHECKSUM_TYPE];

                    NSString * appIDStr = [fileHeader substringWithRange:NSMakeRange(14, 2)];
                    NSData * appIDData = [Utilities dataFromHexString:appIDStr];
                    uint8_t appID = ((uint8_t *)[appIDData bytes])[0];
                    [fileHeaderDict setObject:[NSNumber numberWithUnsignedChar:appID] forKey:APP_ID];

                    NSString * productIDStr = [fileHeader substringWithRange:NSMakeRange(16, 8)];
                    NSData * productIDData = [Utilities dataFromHexString:productIDStr];
                    uint32_t productID = [Utilities parse4ByteValueLittleFromByteArray:(uint8_t *)[productIDData bytes]];
                    [fileHeaderDict setObject:[NSNumber numberWithUnsignedInt:productID] forKey:PRODUCT_ID];

                    [fileContentsArr removeObjectAtIndex:0];//Remove header line

                    //Parse data lines
                    for (int i = 0; i < fileContentsArr.count; i++)
                    {
                        BOOL success = NO;
                        NSString * dataRowStr = [fileContentsArr objectAtIndex:i];
                        if ([dataRowStr hasPrefix:APPINFO_PREFIX])
                        {
                            //Process APPINFO row
                            appInfoDict = [self parseAppInfoRowString_v1:dataRowStr];
                            success = (appInfoDict != nil);
                        }
                        else if ([dataRowStr hasPrefix:EIV_PREFIX])
                        {
                            //Process EIV row
                            dataRowStr = [dataRowStr substringFromIndex:[EIV_PREFIX length]];//Strip "@EIV:" prefix off
                            NSDictionary *dataRowDict = [self parseEivRowString_v1:dataRowStr];
                            success = (dataRowDict != nil);
                            if (success){
                                [fileDataArr addObject:dataRowDict];
                            }
                        }
                        else if ([dataRowStr hasPrefix:DATA_PREFIX])
                        {
                            //Process data row
                            dataRowStr = [dataRowStr substringFromIndex:[DATA_PREFIX length]];//Strip ":" prefix off
                            NSDictionary *dataRowDict = [self parseDataRowString_v1:dataRowStr];
                            success = (dataRowDict != nil);
                            if (success){
                                [fileDataArr addObject:dataRowDict];
                            }
                        }

                        if (!success)
                        {
                            error = [[NSError alloc] initWithDomain:PARSING_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"invalidFile") forKey:NSLocalizedDescriptionKey]];
                            finish(nil, nil, nil, error);
                            break;
                        }
                    }

                    if (!error)
                    {
                        finish(fileHeaderDict, appInfoDict, fileDataArr, nil);
                    }
                }
                else
                {
                    error = [[NSError alloc] initWithDomain:PARSING_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"unsupportedFileVersion") forKey:NSLocalizedDescriptionKey]];
                    finish(nil, nil, nil, error);
                }
            }
            else
            {
                error = [[NSError alloc] initWithDomain:PARSING_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"invalidFile") forKey:NSLocalizedDescriptionKey]];
                finish(nil, nil, nil, error);
            }
        }
        else
        {
            error = [[NSError alloc] initWithDomain:PARSING_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"parsingFailed") forKey:NSLocalizedDescriptionKey]];
            finish(nil, nil, nil, error);
        }
    }
    else
    {
        error = [[NSError alloc] initWithDomain:FILE_EMPTY_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"fileEmpty") forKey:NSLocalizedDescriptionKey]];
        finish(nil, nil, nil, error);
    }
}

/*!
 *  @method removeEmptyRowsAndJunkDataFromArray:
 *
 *  @discussion Method for empty rows and junk data from the parsed array of data
 *
 */
- (NSMutableArray *)removeEmptyRowsAndJunkDataFromArray:(NSMutableArray *)dataArray
{
    NSMutableCharacterSet * charsToRemain = [[NSMutableCharacterSet alloc] init];
    [charsToRemain formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
    [charsToRemain addCharactersInString:@"@:,"];// CYACD - data rows start with ':'; CYACD2 - data rows start with ':', EIV row starts with '@EIV:', APPINFO row starts with '@APPINFO:'
    NSCharacterSet * charsToRemove = [charsToRemain invertedSet];

    for (int i = 0; i < dataArray.count; ) {
        if ([[dataArray objectAtIndex:i] isEqualToString:@""]) {
            [dataArray removeObjectAtIndex:i];
        }else{
            NSString *trimmedReplacement = [[[dataArray objectAtIndex:i]componentsSeparatedByCharactersInSet:charsToRemove]
                                            componentsJoinedByString:@""];
            [dataArray replaceObjectAtIndex:i withObject:trimmedReplacement];
            i++;
        }
    }
    return dataArray;
}

/*!
 *  @method parseRowDataString:
 *
 *  @discussion Method for parsing each row of data in the firmware file.
 *
 */
- (NSMutableDictionary *)parseDataRowString:(NSString *)rowData
{
    NSMutableDictionary * rowDataDict = [NSMutableDictionary new];

    [rowDataDict setValue:[rowData substringWithRange:NSMakeRange(0, 2)] forKey:ARRAY_ID];
    [rowDataDict setValue:[rowData substringWithRange:NSMakeRange(2, 4)] forKey:ROW_NUMBER];
    [rowDataDict setValue:[rowData substringWithRange:NSMakeRange(6, 4)] forKey:DATA_LENGTH];

    NSString * dataString = [rowData substringWithRange:NSMakeRange(10, rowData.length - 12)];
    if ([Utilities getIntegerFromHexString:[rowDataDict objectForKey:DATA_LENGTH]] != dataString.length/2 )
    {
        return nil;
    }

    NSMutableArray * byteArray = [NSMutableArray new];
    for (int i = 0; i + 2 <= dataString.length; i += 2) {
        [byteArray addObject:[dataString substringWithRange:NSMakeRange(i, 2)]];
    }
    [rowDataDict setValue:byteArray forKey:DATA_ARRAY];
    [rowDataDict setValue:[rowData substringWithRange:NSMakeRange(rowData.length - 2, 2)] forKey:CHECKSUM_OTA];

    return rowDataDict;
}

/*!
 *  @method parseDataRowString_v1:
 *
 *  @discussion Method for parsing data row in firmware file (CYACD2).
 *
 */
- (NSMutableDictionary *)parseDataRowString_v1:(NSString *)rowData
{
    const int ADDR_LEN = 8;

    if (nil == rowData || [rowData length] < ADDR_LEN || ([rowData length] - ADDR_LEN) % 2)
    {
        return nil;
    }

    NSMutableDictionary * rowDataDict = [NSMutableDictionary new];
    [rowDataDict setObject:[NSNumber numberWithUnsignedChar:RowTypeData] forKey:ROW_TYPE];

    NSString * addrStr = [rowData substringWithRange:NSMakeRange(0, ADDR_LEN)];
    NSData * addrData = [Utilities dataFromHexString:addrStr];
    uint32_t addr = [Utilities parse4ByteValueLittleFromByteArray:(uint8_t *)[addrData bytes]];
    [rowDataDict setObject:[NSNumber numberWithUnsignedInt:addr] forKey:ADDRESS];

    NSString * dataStr = [rowData substringWithRange:NSMakeRange(ADDR_LEN, [rowData length] - ADDR_LEN)];

    NSData * bytesData = [Utilities dataFromHexString:dataStr];
    uint32_t crc32 = [Utilities CRC32ForByteArray:(uint8_t *)[bytesData bytes] ofSize:(uint32_t)[bytesData length]];

    [rowDataDict setObject:[NSNumber numberWithUnsignedInt:crc32] forKey:CRC_32];
    [rowDataDict setObject:[NSNumber numberWithUnsignedInt:(uint32_t)[bytesData length]] forKey:DATA_LENGTH];

    NSMutableArray * byteArr = [NSMutableArray new];
    for (int i = 0; i + 2 <= dataStr.length; i += 2) {
        [byteArr addObject:[dataStr substringWithRange:NSMakeRange(i, 2)]];
    }
    [rowDataDict setValue:byteArr forKey:DATA_ARRAY];

    return rowDataDict;
}

/*!
 *  @method parseAppInfoRowString_v1:
 *
 *  @discussion Parses APPINFO row in firmware file (CYACD2).
 *
 */
- (NSMutableDictionary *)parseAppInfoRowString_v1:(NSString *)rowData
{
    if (nil == rowData)
        return nil;

    NSMutableDictionary * rowDataDict = [NSMutableDictionary new];

    NSRange range = [rowData rangeOfString:APPINFO_SEPARATOR];
    if (range.length <= 0)
        return nil;

    NSUInteger separatorIndex = range.location;
    NSUInteger pos = APPINFO_PREFIX.length;
    NSUInteger length = separatorIndex - pos;
    NSString *appStartStr = [rowData substringWithRange:NSMakeRange(pos, length)];
    NSData *appStartData = [Utilities dataFromHexString:appStartStr isLSB:NO];
    if (appStartData == nil || appStartData.length == 0 || appStartData.length > 4)
        return nil;

    uint8_t appStartBytes[4] = {0,0,0,0};//If data is less than 4 bytes then high bytes will be set to 0
    for (int i = 0; i < appStartData.length; i++)
    {
        appStartBytes[i] = ((uint8_t *)appStartData.bytes)[i];
    }
    uint32_t appStart = [Utilities parse4ByteValueLittleFromByteArray:appStartBytes];
    [rowDataDict setValue:@(appStart) forKey:APPINFO_APP_START];

    pos += length + APPINFO_SEPARATOR.length;
    length = rowData.length - pos;
    NSString *appSizeStr = [rowData substringWithRange:NSMakeRange(pos, length)];
    NSData *appSizeData = [Utilities dataFromHexString:appSizeStr isLSB:NO];
    if (appSizeData == nil || appSizeData.length == 0)
        return nil;

    uint8_t appSizeBytes[4] = {0,0,0,0};//If data is less than 4 bytes then high bytes will be set to 0
    for (int i = 0; i < appSizeData.length; i++)
    {
        appSizeBytes[i] = ((uint8_t *)appSizeData.bytes)[i];
    }
    uint32_t appSize = [Utilities parse4ByteValueLittleFromByteArray:appSizeBytes];
    [rowDataDict setValue:@(appSize) forKey:APPINFO_APP_SIZE];

    return rowDataDict;
}

/*!
 *  @method parseEivRowString_v1:
 *
 *  @discussion Parses EIV row in firmware file (CYACD2).
 *
 */
- (NSMutableDictionary *)parseEivRowString_v1:(NSString *)rowData
{
    if (nil == rowData || [rowData length] % 2)
    {
        return nil;
    }

    NSMutableDictionary * rowDataDict = [NSMutableDictionary new];
    [rowDataDict setValue:[NSNumber numberWithUnsignedChar:RowTypeEiv] forKey:ROW_TYPE];

    uint32_t numBytes = (uint32_t)(rowData.length / 2);
    [rowDataDict setObject:[NSNumber numberWithUnsignedInt:numBytes] forKey:DATA_LENGTH];

    NSMutableArray * dataArr = [NSMutableArray new];
    for (int i = 0; i + 2 <= rowData.length; i += 2) {
        [dataArr addObject:[rowData substringWithRange:NSMakeRange(i, 2)]];
    }
    [rowDataDict setValue:dataArr forKey:DATA_ARRAY];

    return rowDataDict;
}

@end
