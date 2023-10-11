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

#import "GATTDBDescriptorDetailsViewController.h"
#import "CyCBManager.h"
#import "Utilities.h"
#import "Constants.h"
#import "Utilities.h"
#import "ResourceHandler.h"
#import "LoggerHandler.h"
#import "NSData+hexString.h"

#define FORMAT_PLIST        @"CharacteristicFormatPList"
#define RESERVED            @"Reserved"

#define HEX_ALERTVIEW_TAG       101
#define MAX_FORMAT_VALUE        27
#define X_CONSTRAINT_VALUE      80.0f
#define X_CONSTRAINT_MIN_VALUE  0.0f

#define NAMESPACE_MIN       0
#define NAMESPACE_MAX       255

/*!
 *  @class GATTDBDescriptorDetailsViewController
 *
 *  @discussion Class to handle the descriptor related operations
 *
 */
@interface GATTDBDescriptorDetailsViewController () <cbCharacteristicManagerDelegate>
{
    /* Datafields  */
    IBOutlet UILabel *descriptorNameLabel;
    IBOutlet UILabel *characteristicNameLabel;
    IBOutlet UILabel *descriptorHexValueLabel;
    IBOutlet UILabel *descriptorValueLabel;

    //Layout Constraint variables to control read/notify buttons
    IBOutlet NSLayoutConstraint *readButtonCenterXConstraint;
    IBOutlet NSLayoutConstraint *notifyButtonCenterXConstraint;
    IBOutlet NSLayoutConstraint *indicateButtonCenterXconstraint;

    IBOutlet NSLayoutConstraint *readButtonWidthConstraint;
    IBOutlet NSLayoutConstraint *notifyButtonWidthConstraint;
    IBOutlet NSLayoutConstraint *indicateButtonWidthconstraint;

    //UIButton Outlets
    IBOutlet UIButton *readButton;
    IBOutlet UIButton *notifyButton;
    IBOutlet UIButton *indicateButton;

    BOOL isViewInitiated;
}

@end

@implementation GATTDBDescriptorDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[CyCBManager sharedManager] setCbCharacteristicDelegate:self];

    if (self.descriptor)
    {
        /* Updating datafields */
        // Display Descriptor name or Descriptor UUID if Descriptor don't have any name. 
        if([Utilities getDescriptorNameForUUID:self.descriptor.UUID] != nil){
            descriptorNameLabel.text = [Utilities getDescriptorNameForUUID:self.descriptor.UUID];
        } else {
            descriptorNameLabel.text = [[self.descriptor.UUID UUIDString] lowercaseString];
        }
        characteristicNameLabel.text = self.characteristicName;
    }

    [self readBtnClicked:nil];
    [notifyButton setHidden:YES];
    [indicateButton setHidden:YES];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.descriptor) {
        if ([self.descriptor.UUID.UUIDString isEqual:CBUUIDClientCharacteristicConfigurationString]) {
            for (NSString *property in [[CyCBManager sharedManager] characteristicProperties]) {
                if ([property isEqual:NOTIFY]) {
                    [notifyButton setHidden:NO];
                } else if ([property isEqual:INDICATE]) {
                    [indicateButton setHidden:NO];
                }
            }
            if (!notifyButton.hidden && indicateButton.hidden) {
                readButtonCenterXConstraint.constant = X_CONSTRAINT_VALUE;
                notifyButtonCenterXConstraint.constant = -X_CONSTRAINT_VALUE;
            } else if (notifyButton.hidden && !indicateButton.hidden) {
                readButtonCenterXConstraint.constant = X_CONSTRAINT_VALUE;
                indicateButtonCenterXconstraint.constant = -X_CONSTRAINT_VALUE;
            } else if (!notifyButton.hidden && !indicateButton.hidden) {
                // handle for 3 buttons
                [self initializeButtonPosition];
            }
        } else {
            readButtonCenterXConstraint.constant = X_CONSTRAINT_MIN_VALUE;
            [self.view layoutIfNeeded];
        }
    }
    [[super navBarTitleLabel] setText:GATT_DB];
}

/*!
 *  @method initiateViewWithDescriptorValue:
 *
 *  @discussion Method to initialize the button state with value read initially
 *
 */
-(void) initiateViewWithDescriptorValue:(int) descriptorValue
{
    switch (descriptorValue)
    {
        case 1:
            notifyButton.selected = YES;
            break;
        case 2:
            indicateButton.selected = YES;
            break;
        case 3:
            notifyButton.selected = YES;
            indicateButton.selected = YES;
            break;
        default:
            break;
    }
}

/*!
 *  @method initializeButtonPosition
 *
 *  @discussion Method to organize button frame and position
 *
 */
-(void) initializeButtonPosition {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        readButtonWidthConstraint.constant = self.view.frame.size.width/3 - 5;
        indicateButtonWidthconstraint.constant = self.view.frame.size.width/3 - 5;
        notifyButtonWidthConstraint.constant = self.view.frame.size.width/3 - 5;
        [self.view layoutIfNeeded];

        readButtonCenterXConstraint.constant = indicateButton.frame.size.width + 5;
        notifyButtonCenterXConstraint.constant = -(indicateButton.frame.size.width + 5);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Button Events

/*!
 *  @method readBtnClicked:
 *
 *  @discussion Method to handle the read buttonclick
 *
 */
-(IBAction)readBtnClicked:(UIButton *)sender
{
    [self logButtonAction:READ_REQUEST];
    [[[CyCBManager sharedManager] myPeripheral] readValueForDescriptor:self.descriptor];
}

/*!
 *  @method notifyBtnClicked:
 *
 *  @discussion Method to handle the notify/stop notify buttonclick
 *
 */
-(IBAction)notifyBtnClicked:(UIButton *)sender
{
    if (!sender.selected) {
        /*Indicate and notify buttons should be mutually exclusive. If Notify button was selected, Indicate should be turned off*/
        if (indicateButton.selected)
            [self indicateButtonClicked:indicateButton];

        [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:YES forCharacteristic:[[CyCBManager sharedManager] myCharacteristic]];
        [self logOperation:[NSString stringWithFormat:@"%@%@ [01 00]",WRITE_REQUEST,DATA_SEPERATOR] andData:nil];
        [self logButtonAction:START_NOTIFY];
    }
    else {
        [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:NO forCharacteristic:[[CyCBManager sharedManager] myCharacteristic]];
        [self logOperation:[NSString stringWithFormat:@"%@%@ [00 00]",WRITE_REQUEST,DATA_SEPERATOR] andData:nil];
        [self logButtonAction:STOP_NOTIFY];
    }

    [sender setSelected:sender.selected ? NO : YES];

    // Read value after setting notify
    [self readBtnClicked:nil];
}

- (IBAction)indicateButtonClicked:(UIButton *)sender
{
    if (!sender.selected) {
        /*Indicate and notify buttons should be mutually exclusive. If Indicate button was selected, Notify should be turned off*/
        if (notifyButton.selected)
            [self notifyBtnClicked:notifyButton];

        [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:YES forCharacteristic:[[CyCBManager sharedManager] myCharacteristic]];
        [self logOperation:[NSString stringWithFormat:@"%@%@ [02 00]",WRITE_REQUEST,DATA_SEPERATOR] andData:nil];
        [self logButtonAction:START_INDICATE];
    }
    else {
        [[[CyCBManager sharedManager] myPeripheral] setNotifyValue:NO forCharacteristic:[[CyCBManager sharedManager] myCharacteristic]];
        [self logOperation:[NSString stringWithFormat:@"%@%@ [00 00]",WRITE_REQUEST,DATA_SEPERATOR] andData:nil];
        [self logButtonAction:STOP_INDICATE];
    }

    [sender setSelected:sender.selected ? NO : YES];

    // Read value after setting notify
    [self readBtnClicked:nil];
}

#pragma mark - CBCharacteristicManagerDelegate Methods

/*!
 *  @method peripheral: didUpdateValueForDescriptor:
 *
 *  @discussion Method invoked when read value for descriptor
 *
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    if (error == nil)
    {
        if ([descriptor.UUID.UUIDString isEqual:CBUUIDCharacteristicFormatString])
        {
            // For CBUUIDCharacteristicFormatString descriptor.value is of type NSData*
            [self parseCBUUIDCharacteristicFormatStringDescriptor:descriptor];
            [self logOperation:READ_RESPONSE andData:descriptor.value];
        }
        else if ([descriptor.UUID.UUIDString isEqual:CBUUIDCharacteristicUserDescriptionString])
        {
            // For CBUUIDCharacteristicUserDescriptionString descriptor.value is of type NSString*
            NSString *descriptorValueString = [NSString stringWithFormat:@"%@", descriptor.value];
            NSData *data = [descriptorValueString dataUsingEncoding:NSUTF8StringEncoding];

            descriptorHexValueLabel.text = [NSString stringWithFormat:@"%@", [data hexString]];
            descriptorValueLabel.text = descriptor.value;

            [self logOperation:READ_RESPONSE andData:data];
        }
        else
        {
            // For CBUUIDClientCharacteristicConfigurationString, CBUUIDServerCharacteristicConfigurationString descriptor.value is of type NSNumber*
            // For CBUUIDCharacteristicAggregateFormatString descriptor.value is of type NSString*
            descriptorHexValueLabel.text = [NSString stringWithFormat:@"%@", descriptor.value];

            NSString * descriptorValueInfo = [Utilities getDescriptorValueInformation:descriptor.UUID andValue:[NSNumber numberWithInteger:[descriptorHexValueLabel.text integerValue]]];
            descriptorValueLabel.text = descriptorValueInfo;

            if (!isViewInitiated)
            {
                [self initiateViewWithDescriptorValue:(int)[descriptorHexValueLabel.text integerValue]];
                isViewInitiated = YES;
            }

            if (descriptorHexValueLabel.text.length == 1)
            {
                [self logOperation:[NSString stringWithFormat:@"%@%@ [0%@ 00]", READ_RESPONSE, DATA_SEPERATOR, descriptorHexValueLabel.text] andData:nil];
                descriptorHexValueLabel.text = [NSString stringWithFormat:@"0%@ 00", descriptorHexValueLabel.text];
            }
            else
                [self logOperation:READ_RESPONSE andData:descriptor.value];
        }
    }
}

/*!
 *  @method parseDataForCharacteristicPresentationFormatDescriptor:
 *
 *  @discussion Method to parse the data received from the descriptor
 *
 */
-(void) parseCBUUIDCharacteristicFormatStringDescriptor:(CBDescriptor *)descriptor
{
    // For CBUUIDCharacteristicFormatString descriptor.value is of type NSData*
    descriptorHexValueLabel.text = [descriptor.value hexString];

    const uint8_t *bytes = [descriptor.value bytes];
    NSUInteger offset = 0;

    int formatValue = bytes[offset];

    offset++;
    uint8_t exponentValue = bytes[offset];

    // Finding unit value
    offset++;
    uint16_t unitValue = 0;
    unitValue = CFSwapInt16LittleToHost(*(uint16_t *)&bytes[offset]);

    // Finding the name space value
    offset = offset + 2;
    uint8_t namespaceValue = bytes[offset];
    NSString *nameSpace;
    if (namespaceValue == NAMESPACE_MIN)
    {
        nameSpace = NOT_SPECIFIED;
    }
    else if (namespaceValue == 1)
    {
        nameSpace = BLUETOOTH_SIG_ASSIGNED_NUMBERS;
    }
    else if (namespaceValue >= 2 && namespaceValue <= NAMESPACE_MAX)
    {
        nameSpace = RESERVED_FOR_FUTURE_USE;
    }

    // Finding the description value
    offset++;
    uint16_t descriptionValue;
    descriptionValue = CFSwapInt16LittleToHost(*(uint16_t *)&bytes[offset]);

    NSString *descriptorValueInfo = [NSString stringWithFormat:@"Format = %@ \nExponent = %d\nUnit = %d \nNamespace = %@ \nDescription = %d", [self getEnumerationForformatValue:formatValue], exponentValue, unitValue, nameSpace, descriptionValue];
    descriptorValueLabel.text = descriptorValueInfo;
}

/*!
 *  @method getEnumerationForformatValue:
 *
 *  @discussion Method to get the corresponding enumeration for format value
 *
 */
-(NSString *) getEnumerationForformatValue:(int)formatValue
{
    NSDictionary *formatDictionary = [ResourceHandler getItemsFromPropertyList:FORMAT_PLIST];
    NSString *formatInfoString;

    if (formatValue <= MAX_FORMAT_VALUE)
    {
        formatInfoString = [formatDictionary valueForKey:[NSString stringWithFormat:@"%d",formatValue]];
    }
    else
    {
        formatInfoString = RESERVED;
    }
    return formatInfoString;
}

/*!
 *  @method logButtonAction:
 *
 *  @discussion Method to log details of various operations
 *
 */
-(void) logButtonAction:(NSString *)action
{
    [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:[[CyCBManager sharedManager] myService].UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:[[CyCBManager sharedManager] myCharacteristic].UUID] descriptor:nil operation:action];
}

/*!
 *  @method logOperation:  andData:
 *
 *  @discussion Method to log characteristic value
 *
 */
-(void) logOperation:(NSString *)operation andData:(NSData *)data
{
    if (data != nil)
    {
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:[[CyCBManager sharedManager] myService].UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:[[CyCBManager sharedManager] myCharacteristic].UUID] descriptor:[Utilities getDescriptorNameForUUID:self.descriptor.UUID] operation:[NSString stringWithFormat:@"%@%@ %@",operation,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:data]]];
    }
    else
    {
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:[[CyCBManager sharedManager] myService].UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:[[CyCBManager sharedManager] myCharacteristic].UUID] descriptor:[Utilities getDescriptorNameForUUID:self.descriptor.UUID] operation:operation];
    }
}

@end
