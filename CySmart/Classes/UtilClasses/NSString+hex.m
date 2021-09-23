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

#import "NSString+hex.h"
#import "NSData+hexString.h"

@implementation NSString (NSString_hex)

-(NSString *) undecoratedHexString {
    NSMutableString *undecorated = [NSMutableString stringWithString:self];
    [undecorated replaceOccurrencesOfString:@"0x" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, undecorated.length)];
    [undecorated replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, undecorated.length)];
    return undecorated;
}

-(NSString *) decoratedHexStringLSB:(BOOL)isLSB {
    //First undecorate...
    NSString *undecorated = [self undecoratedHexString];
    //Pad with 0
    NSString *padded = [undecorated paddedHexStringLSB:isLSB];
    //...then decorate back
    NSMutableString *decorated = [NSMutableString stringWithString:padded];
    if (decorated.length > 0) {
        for (int count = 0, n = decorated.length * 0.5, i = 0; count < n; ++count, i += 5) {
            [decorated insertString:@" 0x" atIndex:i];
        }
        [decorated replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];//Remove initial space
    }
    return decorated;
}

-(NSString *) paddedHexStringLSB:(BOOL)isLSB {
    NSMutableString *padded = [NSMutableString stringWithString:self];
    if (padded.length % 2 != 0) {//Odd number of digits
        if (isLSB) {//Prepend 0 to the last byte (0x123 -> 0x1203)
            [padded insertString:@"0" atIndex:(padded.length - 1)];
        } else  {//Prepend 0 to the first byte (0x123 -> 0x0123)
            [padded insertString:@"0" atIndex:0];
        }
    }
    return padded;
}

- (NSString *) asciiToHex {
    NSString *hex = @"";
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *tmpHex = [data hexString];
    tmpHex = [tmpHex uppercaseString];
    for (NSUInteger i = 0, n = tmpHex.length; i < n; i += 2) {
        NSString *digit = [tmpHex substringWithRange:NSMakeRange(i, 2)];
        NSString *format = i + 2 >= n ? @"0x%@" : @"0x%@ ";
        hex = [hex stringByAppendingString:[NSString stringWithFormat:format, digit]];
    }
    return hex;
}

@end
