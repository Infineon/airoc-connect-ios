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

#import "ScannedPeripheralTableViewCell.h"
#import "Constants.h"

/*!
 *  @class ScannedPeripheralTableViewCell
 *
 *  @discussion Model class for handling operations related to peripheral table cell
 *
 */
@implementation ScannedPeripheralTableViewCell
{
    /*  Data fields  */
    __weak IBOutlet UILabel *RSSIValueLabel;
    __weak IBOutlet UILabel *peripheralAdressLabel;
    __weak IBOutlet UILabel *peripheralName;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/*!
 *  @method nameForPeripheral:
 *
 *  @discussion Method to get the peripheral name
 *
 */
-(NSString *)nameForPeripheral:(CBPeripheralExt *)ble
{
    NSString *bleName ;

    if ([ble.mAdvertisementData valueForKey:CBAdvertisementDataLocalNameKey] != nil)
    {
        bleName = [ble.mAdvertisementData valueForKey:CBAdvertisementDataLocalNameKey];
    }

    // If the peripheral name is not found in advertisement data, then check whether it is there in peripheral object. If it's not found then assign it as unknown peripheral

    if(bleName.length < 1 )
    {
        if (ble.mPeripheral.name.length > 0) {
            bleName = ble.mPeripheral.name;
        }
        else
            bleName = LOCALIZEDSTRING(@"unknownPeripheral");
    }

    return bleName;
}


/*!
 *  @method UUIDStringfromPeripheral:
 *
 *  @discussion Method to get the UUID from the peripheral
 *
 */
-(NSString *)UUIDStringfromPeripheral:(CBPeripheralExt *)ble
{

    NSString *bleUUID = ble.mPeripheral.identifier.UUIDString;
    if(bleUUID.length < 1 )
        bleUUID = @"Nil";
    else
        bleUUID = [NSString stringWithFormat:@"UUID: %@",bleUUID];

    return bleUUID;
}

/*!
 *  @method ServiceCountfromPeripheral:
 *
 *  @discussion Method to get the number of services present in a device
 *
 */
-(NSString *)serviceCountForPeripheral:(CBPeripheralExt *)ble
{
    NSString *bleService =@"";
    NSInteger serviceCount = [[ble.mAdvertisementData valueForKey:CBAdvertisementDataServiceUUIDsKey] count];
    if(serviceCount < 1 )
        bleService = LOCALIZEDSTRING(@"noServices");
    else
        bleService = [NSString stringWithFormat:@" %ld Service Advertised ",(long)serviceCount];

    return bleService;
}

/*!
 *  @method RSSIValue:
 *
 *  @discussion Method to get the RSSI value
 *
 */
-(NSString *)RSSIValueForPeripheral:(CBPeripheralExt *)ble
{
    NSString *deviceRSSI = [ble.mRSSI stringValue];

    if ([deviceRSSI intValue] >= RSSI_UNDEFINED_VALUE) {
        deviceRSSI = LOCALIZEDSTRING(@"undefined");
    } else {
        deviceRSSI=[NSString stringWithFormat:@"%@ dBm",deviceRSSI];
    }

    return deviceRSSI;
}


/*!
 *  @method setDiscoveredPeripheralDataFromPeripheral:
 *
 *  @discussion Method to display the device details
 *
 */
-(void)setDiscoveredPeripheralDataFromPeripheral:(CBPeripheralExt*) discoveredPeripheral
{
    peripheralName.text         = [self nameForPeripheral:discoveredPeripheral];
    peripheralAdressLabel.text  = [self serviceCountForPeripheral:discoveredPeripheral];
    RSSIValueLabel.text         = [self RSSIValueForPeripheral:discoveredPeripheral];
    // CONFIGURATORS-2444
    self.contentView.alpha = (discoveredPeripheral.mRSSI.intValue >= RSSI_UNDEFINED_VALUE) ? 0.5 : 1.0;
//    self.selectionStyle = (discoveredPeripheral.mRSSI.intValue >= RSSI_UNDEFINED_VALUE) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
}

/*!
 *  @method updateRSSIWithValue:
 *
 *  @discussion Method to update the RSSI value of a device
 *
 */
-(void)updateRSSIWithValue:(NSString*) newRSSI
{
    RSSIValueLabel.text=newRSSI;
}

@end
