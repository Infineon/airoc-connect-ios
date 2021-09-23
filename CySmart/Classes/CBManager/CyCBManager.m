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

#import <UIKit/UIKit.h>
#import "CyCBManager.h"
#import "CBPeripheralExt.h"
#import "ResourceHandler.h"
#import "Utilities.h"
#import "UIAlertController+Additions.h"

#define MY_DOMAIN       @"myDomain"

/*!
 *  @class CyCBManager
 *
 *  @discussion Singleton, coordinates all the peripheral related operations.
 *
 */
@interface CyCBManager () <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager *centralManager;
    NSMutableArray *peripheralArray;
    
    void (^cbCommunicationHandler)(BOOL success, NSError *error);
    BOOL isTimeOutAlert;
}
@end

@implementation CyCBManager

@synthesize cbCharacteristicDelegate;
@synthesize myPeripheral;
@synthesize myService;
@synthesize myCharacteristic;
@synthesize serviceUUIDDict;
@synthesize cbDiscoveryDelegate;
@synthesize foundPeripherals;
@synthesize foundServices;
@synthesize characteristicDescriptors;
@synthesize characteristicProperties;
@synthesize bootloaderFileArray;
@synthesize bootloaderSecurityKey;
@synthesize bootloaderActiveApp;

#define k_SERVICE_UUID_PLIST_NAME @"ServiceUUIDPList"

#pragma mark - Singleton Methods

/*!
 *  @method sharedManager
 *
 *  @discussion Returns single instance of CyCBManager.
 *
 */
+ (id)sharedManager {
    static CyCBManager *sharedMgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMgr = [[self alloc] init];
    });
    return sharedMgr;
}

- (id)init {
    if (self = [super init])
    {
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        foundPeripherals = [[NSMutableArray alloc] init];
        foundServices = [[NSMutableArray alloc] init];
        peripheralArray = [[NSMutableArray alloc] init];
        serviceUUIDDict = [NSMutableDictionary dictionaryWithDictionary:[ResourceHandler getItemsFromPropertyList:k_SERVICE_UUID_PLIST_NAME]];
        bootloaderFileArray = nil;
        bootloaderSecurityKey = nil;
        bootloaderActiveApp = NoChange;
    }
    return self;
}

#pragma mark - Discovery

/*!
 *  @method startScanning
 *
 *  @discussion Scan for advertising peripherals.
 *
 */
- (void) startScanning {
    if(centralManager.state == CBManagerStatePoweredOn) {
        [cbDiscoveryDelegate bluetoothStateUpdatedToState:YES];
        [centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @NO}];
    } else if (centralManager.state == CBManagerStateUnsupported) {
        [[UIAlertController alertWithTitle:APP_NAME message:LOCALIZEDSTRING(@"BLENotSupportedAlert")] presentInParent:nil];
    }
}

/*!
 *  @method stopScanning
 *
 *  @discussion  Stop scanning for peripherals.
 *
 */
- (void) stopScanning
{
    [centralManager stopScan];
}

/*!
 *  @method centralManager:didDiscoverPeripheral:advertisementData:RSSI
 *
 *  @discussion Central manager discovered some advertising peripheral.
 *
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    CBPeripheralExt *peripheralExt = nil;
    const NSUInteger index = [peripheralArray indexOfObject:peripheral];
    
    if (index != NSNotFound) {
        peripheralExt = foundPeripherals[index];
    } else {
        if (peripheral.state != CBPeripheralStateConnected) {
            peripheralExt = [[CBPeripheralExt alloc] init];
        }
    }
    
    if (peripheralExt != nil) {
        peripheralExt.mPeripheral = [peripheral copy];
        peripheralExt.mAdvertisementData = [advertisementData copy];
        peripheralExt.mRSSI = [RSSI copy];

        if (index == NSNotFound) {
            [peripheralArray addObject:peripheral];
            [foundPeripherals addObject:peripheralExt];
        }

        [cbDiscoveryDelegate discoveryDidRefresh];
    }
}

#pragma mark - Connection/Disconnection

/*!
 *  @method cancelTimeOutAlert
 *
 *  @discussion Cancel timeout alert.
 *
 */
-(void)cancelTimeOutAlert
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeOutMethodForConnect) object:nil];
}

/*!
 *  @method timeOutMethodForConnect
 *
 *  @discussion Handler for the timed out connection attempt.
 *
 */
-(void)timeOutMethodForConnect
{
    isTimeOutAlert = YES;
    [self cancelTimeOutAlert];
    [self disconnectPeripheral:myPeripheral];
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:LOCALIZEDSTRING(@"connectionTimeOutAlert") forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:MY_DOMAIN code:100 userInfo:errorDetail];
    [self refreshPeripheralsPreservingPeripheralList];
    cbCommunicationHandler(NO,error);
}

/*!
 *  @method connectPeripheral:completionHandler:
 *
 *  @discussion	 Connect to the peripheral.
 *
 */
- (void) connectPeripheral:(CBPeripheral*)peripheral completionHandler:(void (^)(BOOL success, NSError *error))completionHandler
{
    if((NSInteger)[centralManager state] == CBManagerStatePoweredOn)
    {
        cbCommunicationHandler = completionHandler ;
        
        if ([peripheral state] == CBPeripheralStateDisconnected)
        {
            [centralManager connectPeripheral:peripheral options:nil];
            [[LoggerHandler logManager] addLogData:[NSString stringWithFormat:@"[%@] %@", peripheral.name, CONNECTION_REQUEST]];
        }
        else
        {
            [centralManager cancelPeripheralConnection:peripheral];
        }
        
        [self performSelector:@selector(timeOutMethodForConnect) withObject:nil afterDelay:DEVICE_CONNECTION_TIMEOUT];
    }
}

/*!
 *  @method disconnectPeripheral:
 *
 *  @discussion	 Disconnect the peripheral.
 *
 */
- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    if(peripheral)
    {
        [centralManager cancelPeripheralConnection:peripheral];
    }
}

/*!
 *  @method centralManager:didConnectPeripheral:
 *
 *  @discussion	Central manager established connection with the peripheral.
 *
 */
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    myPeripheral =  nil;
    myPeripheral = [peripheral copy];
    myPeripheral.delegate = self ;
    [myPeripheral discoverServices:nil];
    
    [[LoggerHandler logManager] addLogData:[NSString stringWithFormat:@"[%@] %@", peripheral.name, CONNECTION_ESTABLISH]];
    [[LoggerHandler logManager] addLogData:[NSString stringWithFormat:@"[%@] %@", peripheral.name, SERVICE_DISCOVERY_REQUEST]];
}

/*!
 *  @method centralManager:didFailToConnectPeripheral:error:
 *
 *  @discussion	Central manager failed to established connection with the peripheral.
 *
 */
- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self cancelTimeOutAlert];
    cbCommunicationHandler(NO,error);
}

/*!
 *  @method centralManager:didDisconnectPeripheral:error:
 *
 *  @discussion	Central manager terminated the connection with the peripheral.
 *
 */
- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self cancelTimeOutAlert];
    
    NSUInteger index = [peripheralArray indexOfObject:peripheral];
    if (index != NSNotFound) {
        // CONFIGURATORS-2444
        CBPeripheralExt *peripheralExt = foundPeripherals[index];
        peripheralExt.mRSSI = @RSSI_UNDEFINED_VALUE;
    }
    
    /*  Check whether the disconnection is done by the device */
    if (error == nil && !isTimeOutAlert)
    {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:LOCALIZEDSTRING(@"deviceDisconnectedAlert") forKey:NSLocalizedDescriptionKey];
        NSError *disconnectError = [NSError errorWithDomain:MY_DOMAIN code:100 userInfo:errorDetail];
        [[LoggerHandler logManager] addLogData:[NSString stringWithFormat:@"[%@] %@",peripheral.name,DISCONNECTION_REQUEST]];
        
        cbCommunicationHandler(NO,disconnectError);
    }
    else
    {
        isTimeOutAlert = NO;
        
        // Checking whether the disconnected device has pending firmware upgrade
        if ([[CyCBManager sharedManager] bootloaderFileArray] != nil && error != nil)
        {
            NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
            [errorDict setValue:[NSString stringWithFormat:@"%@%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey],LOCALIZEDSTRING(@"firmwareUpgradePendingMessage")] forKey:NSLocalizedDescriptionKey];
            
            NSError *disconnectionError = [NSError errorWithDomain:MY_DOMAIN code:100 userInfo:errorDict];
            cbCommunicationHandler(NO,disconnectionError);
        }
        else
            cbCommunicationHandler(NO,error);
    }
    
    [self redirectToRootViewController];
    [[LoggerHandler logManager] addLogData:[NSString stringWithFormat:@"[%@] %@",peripheral.name,DISCONNECTED]];
    
    // CONFIGURATORS-2444
    // [self clearDevices];
    [self clearServices];
}

/*!
 *  @method redirectToRootViewController
 *
 *  @discussion	 Pops all the view controllers on the stack except the root view controller and updates the display.
 *  This will redirect to BLE Devices Page which lists all discovered peripherals.
 *
 */
-(void)redirectToRootViewController
{
    if(cbDiscoveryDelegate)
    {
        [[(UIViewController*)cbDiscoveryDelegate navigationController] popToRootViewControllerAnimated:YES];
    }
    else if(cbCharacteristicDelegate)
    {
        [[(UIViewController*)cbCharacteristicDelegate navigationController] popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Service Discovery

/*!
 *  @method peripheral:didDiscoverServices:
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    [self cancelTimeOutAlert];
    if(error == nil)
    {
        [[LoggerHandler logManager] addLogData:[NSString stringWithFormat:@"[%@] %@- %@",peripheral.name,SERVICE_DISCOVERY_STATUS,SERVICE_DISCOVERED]];
        BOOL isCapsenseExist = NO;
        for (CBService *service in peripheral.services)
        {
            if (![foundServices containsObject:service])
            {
                [foundServices addObject:service];
                if(([service.UUID isEqual:CAPSENSE_SERVICE_UUID] || [service.UUID isEqual:CUSTOM_CAPSENSE_SERVICE_UUID])
                   && (NO == isCapsenseExist))//There is no need to perform characteristics discovery for subsequent CapSense services
                {
                    isCapsenseExist = YES;
                    cbCharacteristicDelegate = nil;
                    [myPeripheral discoverCharacteristics:nil forService:service];
                }
            }
        }
        if(NO == isCapsenseExist)
        {
            cbCommunicationHandler(YES,nil);
        }
    }
    else
    {
        [[LoggerHandler logManager] addLogData:[NSString stringWithFormat:@"[%@] %@- %@%@]",peripheral.name,SERVICE_DISCOVERY_STATUS,SERVICE_DISCOVERY_ERROR,[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
        
        cbCommunicationHandler(NO,error);
    }
}

#pragma mark - Characteristic Discovery

/*!
 *  @method peripheral:didDiscoverCharacteristicsForService:error:
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if([cbCharacteristicDelegate isKindOfClass:[CyCBManager class]] || cbCharacteristicDelegate == nil)
    {
        cbCommunicationHandler(YES,nil);
    }
    else
    {
        [cbCharacteristicDelegate peripheral:peripheral didDiscoverCharacteristicsForService:service error:error];
    }
}

/*!
 *  @method peripheral:didUpdateValueForCharacteristic:error:
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        if (!characteristic.isNotifying)
        {
            [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@- %@%@",READ_RESPONSE,READ_ERROR,[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
        }
    }
    
    if([cbCharacteristicDelegate respondsToSelector:@selector(peripheral:didUpdateValueForCharacteristic:error:)])
    {
        [cbCharacteristicDelegate peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    }
}

/*!
 *  @method peripheral:didWriteValueForCharacteristic:error:
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([cbCharacteristicDelegate respondsToSelector:@selector(peripheral:didWriteValueForCharacteristic:error:)])
    {
        [cbCharacteristicDelegate peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
    }
}

/*!
 *  @method peripheral:didDiscoverDescriptorsForCharacteristic:error:
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([cbCharacteristicDelegate respondsToSelector:@selector(peripheral:didDiscoverDescriptorsForCharacteristic:error:)])
        [cbCharacteristicDelegate peripheral:peripheral didDiscoverDescriptorsForCharacteristic:characteristic error:error];
}

/*!
 *  @method peripheral:didUpdateValueForDescriptor:error:
 *
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    if (error)
    {
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:descriptor.characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:descriptor.characteristic.UUID] descriptor:[Utilities getDiscriptorNameForUUID:descriptor.UUID] operation:[NSString stringWithFormat:@"%@- %@%@",READ_RESPONSE,READ_ERROR,[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
    }
    [cbCharacteristicDelegate peripheral:peripheral didUpdateValueForDescriptor:descriptor error:error];
}

/*!
 *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if([cbCharacteristicDelegate respondsToSelector:@selector(peripheral:didUpdateNotificationStateForCharacteristic:error:)]) {
        [cbCharacteristicDelegate peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
    }
}


#pragma mark - BLE State

/*!
 *  @method clearPeripherals
 *
 *  @discussion	 Clear all listed peripherals and services.
 *
 */
- (void) clearPeripherals {
    [peripheralArray removeAllObjects];
    [foundPeripherals removeAllObjects];
    [self clearServices];
}

- (void) clearServices {
    [foundServices removeAllObjects];
}

/*
 * @method centralManagerDidUpdateState:
 *
 * @discussion Invoked when the central manager’s state is updated. (required)
 * If the state is On then app start scanning for peripherals that are advertising services.
 * If the state is Off then call method [clearDevices] and redirect to Home screen.
 */
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch ((NSInteger)[centralManager state])
    {
        case CBManagerStatePoweredOff:
        {
            [self clearPeripherals];
            /* Tell user to power ON BT for functionality, but not on first run - the Framework will alert in that instance. */
            //Show Alert
            [self redirectToRootViewController];
            [cbDiscoveryDelegate bluetoothStateUpdatedToState:NO];
            break;
        }
            
        case CBManagerStateUnauthorized:
        {
            /* Tell user the app is not allowed. */
            [[UIAlertController alertWithTitle:APP_NAME message:LOCALIZEDSTRING(@"appNotAuthorizedAlert")] presentInParent:nil];
            break;
        }
            
        case CBManagerStateUnknown:
        {
            /* Bad news, let's wait for another event. */
            [[UIAlertController alertWithTitle:APP_NAME message:LOCALIZEDSTRING(@"stateUnknownAlert" )] presentInParent:nil];
            break;
        }
            
        case CBManagerStatePoweredOn:
        {
            [cbDiscoveryDelegate bluetoothStateUpdatedToState:YES];
            [self startScanning];
            break;
        }
            
        case CBManagerStateResetting:
        {
            [self clearPeripherals];
            break;
        }
    }
}

/*!
 * @method refreshPeripherals
 *
 * @discussion	Clear all listed peripherals and services.
 * Also check the status of Bluetooth and alert the user if it is turned Off.
 *
 */
- (void) refreshPeripherals {
    [self clearPeripherals];
    [self refreshPeripheralsPreservingPeripheralList];
}

- (void) refreshPeripheralsPreservingPeripheralList {
    [self clearServices];
    if([centralManager state] == CBManagerStatePoweredOff)
    {
        [[UIAlertController alertWithTitle:LOCALIZEDSTRING(@"warning") message:LOCALIZEDSTRING(@"bluetoothDeviceTurnOnAlert" )] presentInParent:nil];
    }
    [[CyCBManager sharedManager] stopScanning];
    [[CyCBManager sharedManager] startScanning];
}

@end
