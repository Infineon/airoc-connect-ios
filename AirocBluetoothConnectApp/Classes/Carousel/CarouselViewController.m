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

#import "RunningSpeedAndCadenceVC.h"
#import "HeartRateMesurementVC.h"
#import "CyclingSpeedAndCadenceVC.h"
#import "DeviceInformationVC.h"
#import "GlucoseViewController.h"
#import "BloodPressureViewController.h"
#import "CapsenseSliderViewController.h"
#import "CapsenseProximityVC.h"
#import "CapsenseButtonVC.h"
#import "RGBViewController.h"
#import "HealthThermometerVC.h"
#import "BatteryServiceVC.h"
#import "GATTDBServiceListViewController.h"
#import "CapsenseSliderViewController.h"
#import "FindMeViewController.h"
#import "CapsenseRootVC.h"
#import "ResourceHandler.h"
#import "CarouselViewController.h"
#import "SensorHubViewController.h"
#import "capsenseModel.h"
#import "FirmwareUpgradeHomeViewController.h"
#import "ResourceHandler.h"
#import "CyCBManager.h"
#import "Constants.h"
#import "UIAlertController+Additions.h"

#define EMPTY_SERVICE_LABEL_WIDTH       300
#define EMPTY_SERVICE_LABEL_HEIGHT      40

/*!
 *  @class CarouselViewController
 *
 *  @discussion Class to handle the services in carousel, selection and animation
 *
 */

@interface CarouselViewController () <iCarouselDataSource, iCarouselDelegate, AlertControllerDelegate>
{
    NSMutableArray *carouselArray;
    NSMutableArray *proximityServices;
    NSMutableArray *findMeServices;
    NSMutableArray *carouselServices;
    NSMutableArray *carouselCharacteristics;
    UILabel *emptyServiceLabel;
    BOOL isSensorHubFound;
}

@end

@implementation CarouselViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    carouselArray = [[NSMutableArray alloc] init];
    carouselServices = [[NSMutableArray alloc] init];
    carouselCharacteristics = [[NSMutableArray alloc] init];
    proximityServices = [[NSMutableArray alloc] init];
    findMeServices = [[NSMutableArray alloc] init];
    [self prepareCarouselList];

    isSensorHubFound = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[super navBarTitleLabel] setText:SERVICES];
}

#pragma mark - iCarousel methods

/*!
 *  @method numberOfItemsInCarousel:
 *
 *  @discussion Method that returns the total number of items in the carousel
 *
 */
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [carouselArray count];
}


/*!
 *  @method carousel: viewForItemAtIndex: reusingView:
 *
 *  @discussion Method for ceating views in carousal
 *
 */
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    UIImageView *serviceImage = nil;

    //create new view if no view is available for recycling
    if (nil == view)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later

        float refWidth;
        if (IS_IPHONE)
        {
            refWidth = _carouselView.frame.size.width;
        }
        else
        {
            refWidth = MIN(IPAD_PORTRAIT_SCREEN_WIDTH, _carouselView.frame.size.width);
        }

        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0,refWidth/1.25f, refWidth/2.0f)];

        serviceImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30.0f, refWidth/1.25f,(refWidth/2.0f) - 30.0)];
        serviceImage.contentMode = UIViewContentModeScaleAspectFit;
        serviceImage.tag = 2 ;

        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,refWidth/1.25f, 30.0f)];
        label.backgroundColor = [UIColor clearColor];
//        label.textColor = COLOR_DARK;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:FONT_SIZE_MEDIUM];
        label.tag = 1;
        [view addSubview:serviceImage];
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
        serviceImage = (UIImageView *)[view viewWithTag:2];
    }

    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    serviceImage.image = [UIImage imageNamed:[[carouselArray objectAtIndex:index] valueForKey:k_SERVICE_IMAGE_NAME_KEY]];

    label.text =[[carouselArray objectAtIndex:index] valueForKey:k_SERVICE_NAME_KEY];
    return view;
}



- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        if (IS_IPHONE_6P)
        {
            return value * 1.5;
        }
        if (IS_IPHONE_4_OR_LESS)
        {
            return value * 1.9;
        }
        // iPad and rest
        return value * 1.25;
    }
    else if (option == iCarouselOptionRadius)
    {
        return (IS_IPAD ? value * 3 : value);
    }
    else if (option == iCarouselOptionCount)
    {
        return (carouselArray.count == 2) ? 2 : 6;
    }
    else if (option == iCarouselOptionVisibleItems)
    {
        return (IS_IPAD ? carouselArray.count: 3);
    }
    return value;
}

/*!
 *  @method carousel: didSelectItemAtIndex:
 *
 *  @discussion Method to handle selection in carousal
 *
 */
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    [[CyCBManager sharedManager] setMyService:[carouselServices objectAtIndex:index]] ;
    [self pushViewController:index];
}


#pragma mark - Show View Controller

/*!
 *  @method pushViewController:
 *
 *  @discussion	 Redirect the view to selected service.
 *
 */
-(void)pushViewController:(NSInteger)index
{
    NSDictionary *carouselItem = [carouselArray objectAtIndex:index];
    NSString *keyAtIndex = [[[[CyCBManager sharedManager] serviceUUIDDict] allKeysForObject:carouselItem] objectAtIndex:0];

    CBUUID *keyID = [CBUUID UUIDWithString:keyAtIndex];

    if([keyID isEqual:HRM_HEART_RATE_SERVICE_UUID])
    {
        HeartRateMesurementVC *hrm = [self.storyboard instantiateViewControllerWithIdentifier:HRM_VIEW_SB_ID];
        [self.navigationController pushViewController:hrm animated:YES];
    }
    else if([keyID isEqual:RSC_SERVICE_UUID])
    {
        RunningSpeedAndCadenceVC *rsc = [self.storyboard instantiateViewControllerWithIdentifier:RSC_VIEW_SB_ID];
        [self.navigationController pushViewController:rsc animated:YES];
    }
    else if([keyID isEqual:CSC_SERVICE_UUID])
    {
        CyclingSpeedAndCadenceVC *csc = [self.storyboard instantiateViewControllerWithIdentifier:CSC_VIEW_SB_ID];
        [self.navigationController pushViewController:csc animated:YES];
    }
    else if ([keyID isEqual:DEVICE_INFO_SERVICE_UUID])
    {
        DeviceInformationVC *deviceInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:DEVICE_INFO_VIEW_SB_ID];
        [self.navigationController pushViewController:deviceInfoVC animated:YES];
    }
    else if ([keyID isEqual:GLUCOSE_SERVICE_UUID])
    {
        if ([ENABLE_GLUCOSE boolValue])
        {
            GlucoseViewController *glucoseVC = [self.storyboard instantiateViewControllerWithIdentifier:GLUCOSE_VIEW_SB_ID];
            [self.navigationController pushViewController:glucoseVC animated:YES];
        }
        else
        {
            [self showUnknownServiceAlert];
        }
    }
    else if ([keyID isEqual:BP_SERVICE_UUID])
    {
        BloodPressureViewController *bloodPressureVC = [self.storyboard instantiateViewControllerWithIdentifier:BP_VIEW_SB_ID];
        [self.navigationController pushViewController:bloodPressureVC animated:YES];
    }
    else if ([keyID isEqual:CAPSENSE_SERVICE_UUID] || [keyID isEqual:CUSTOM_CAPSENSE_SERVICE_UUID])
    {
        CapsenseRootVC *capsenseVC = [self.storyboard instantiateViewControllerWithIdentifier:CAPSENSE_VIEW_SB_ID];
        capsenseVC.capsenseCharList = [NSMutableArray arrayWithArray:carouselCharacteristics];
        [self.navigationController pushViewController:capsenseVC animated:YES];
    }

    else if ([keyID isEqual:CAPSENSE_BUTTON_CHARACTERISTIC_UUID])
    {
        CapsenseButtonVC *buttonVC = [self.storyboard instantiateViewControllerWithIdentifier:CAPSENSE_BTN_VIEW_SB_ID];
        CBCharacteristic *characteristic = nil;
        for (id c in carouselCharacteristics) {
            if ([[c UUID] isEqual:CAPSENSE_BUTTON_CHARACTERISTIC_UUID] || [[c UUID] isEqual:CUSTOM_CAPSENSE_BUTTONS_CHARACTERISTIC_UUID]) {
                characteristic = c;
                break;
            }
        }
        if (characteristic != nil) {
            buttonVC.capsenseButtonCharacteristicUUID = characteristic.UUID;
            [self.navigationController pushViewController:buttonVC animated:YES];
        }
    }
    else if ([keyID isEqual:CAPSENSE_PROXIMITY_CHARACTERISTIC_UUID])
    {
        CapsenseProximityVC *proximityVC = [self.storyboard instantiateViewControllerWithIdentifier:PROXIMITY_VIEW_SB_ID];
        CBCharacteristic *characteristic = nil;
        for (id c in carouselCharacteristics) {
            if ([[c UUID] isEqual:CAPSENSE_PROXIMITY_CHARACTERISTIC_UUID] || [[c UUID] isEqual:CUSTOM_CAPSENSE_PROXIMITY_CHARACTERISTIC_UUID]) {
                characteristic = c;
                break;
            }
        }
        if (characteristic != nil) {
            proximityVC.proximityCharacteristicUUID = characteristic.UUID;
            [self.navigationController pushViewController:proximityVC animated:YES];
        }
    }
    else if ([keyID isEqual:CAPSENSE_SLIDER_CHARACTERISTIC_UUID] )
    {
        CapsenseSliderViewController *sliderVC = [self.storyboard instantiateViewControllerWithIdentifier:CAPSENSE_SLIDER_VIEW_SB_ID];
        CBCharacteristic *characteristic = nil;
        for (id c in carouselCharacteristics) {
            if ([[c UUID] isEqual:CAPSENSE_SLIDER_CHARACTERISTIC_UUID] || [[c UUID] isEqual:CUSTOM_CAPSENSE_SLIDER_CHARACTERISTIC_UUID]) {
                characteristic = c;
                break;
            }
        }
        if (characteristic != nil) {
            sliderVC.sliderCharacteristicUUID = characteristic.UUID;
            [self.navigationController pushViewController:sliderVC animated:YES];
        }
    }
    else if ([keyID isEqual:RGB_SERVICE_UUID] || [keyID isEqual:CUSTOM_RGB_SERVICE_UUID])
    {
        RGBViewController *rgbVC = [self.storyboard instantiateViewControllerWithIdentifier:RGB_VIEW_SB_ID];
        [self.navigationController pushViewController:rgbVC animated:YES];
    }
    else if ([keyID isEqual:THM_SERVICE_UUID])
    {
        HealthThermometerVC *thermometerVC = [self.storyboard instantiateViewControllerWithIdentifier:HEALTH_THERMO_VIEW_SB_ID];
        [self.navigationController pushViewController:thermometerVC animated:YES];
    }
    else if ([keyID isEqual:BATTERY_LEVEL_SERVICE_UUID])
    {
        BatteryServiceVC *batteryVC = [self.storyboard instantiateViewControllerWithIdentifier:BATTERY_VIEW_SB_ID];
        [self.navigationController pushViewController:batteryVC animated:YES];
    }
    else if([keyID isEqual:TRANSMISSION_POWER_SERVICE] || [keyID isEqual:LINK_LOSS_SERVICE_UUID] )
    {
        FindMeViewController *findMeVC = [self.storyboard instantiateViewControllerWithIdentifier:FIND_ME_VIEW_SB_ID];
        findMeVC.servicesArray = proximityServices;
        [self.navigationController pushViewController:findMeVC animated:YES];
    }
    else if([keyID isEqual:IMMEDIATE_ALERT_SERVICE_UUID])
    {
        FindMeViewController *findMeVC = [self.storyboard instantiateViewControllerWithIdentifier:FIND_ME_VIEW_SB_ID];
        findMeVC.servicesArray = findMeServices;
        [self.navigationController pushViewController:findMeVC animated:YES];
    }
    else if ([keyID isEqual:BAROMETER_SERVICE_UUID])
    {
        SensorHubViewController *sensorHubVC = [self.storyboard instantiateViewControllerWithIdentifier:SENSOR_HUB_VIEW_SB_ID];
        [self.navigationController pushViewController:sensorHubVC animated:YES];
    }
    else if ([keyID isEqual:[CBUUID UUIDWithString:GENERIC_ACCESS_SERVICE_UUID]])
    {
        GATTDBServiceListViewController *servicesVC = [self.storyboard instantiateViewControllerWithIdentifier:GATTDB_VIEW_SB_ID];
        [self.navigationController pushViewController:servicesVC animated:YES];
    }
    else if ([keyID isEqual:CUSTOM_BOOT_LOADER_SERVICE_UUID])
    {
        if ([ENABLE_OTA boolValue])
        {
            FirmwareUpgradeHomeViewController *selectionVC = [self.storyboard instantiateViewControllerWithIdentifier:FILE_SEL_VIEW_SB_ID];
            [self.navigationController pushViewController:selectionVC animated:YES];
        }
        else
        {
            [self showUnknownServiceAlert];
        }
    }
    else
    {
        [self showUnknownServiceAlert];
    }
}

/*!
 *  @method showUnknownServiceAlert
 *
 *  @discussion Alert the user and redirect to the GATTDB view after receiving confirmation
 *
 */
- (void)showUnknownServiceAlert {
    [[UIAlertController alertWithTitle:LOCALIZEDSTRING(@"unknownServiceAlert") message:LOCALIZEDSTRING(@"goToGattDBAlert") delegate:self cancelButtonTitle:OPT_YES otherButtonTitles:OPT_CANCEL, nil] presentInParent:nil];
}

/*!
 *  @method UUIDArray:
 *
 *  @discussion Return all UUID as CBUUID
 *
 */
-(NSArray*)UUIDArray:(NSArray *)allService
{
    NSMutableArray *UUIDArray = [NSMutableArray array];
    for(NSString *string in allService)
    {
        [UUIDArray addObject:[CBUUID UUIDWithString:string]];
    }
    return (NSArray *)UUIDArray;
}

/*!
 *  @method prepareCarouselList
 *
 *  @discussion Method to list all services in Carousel View
 *
 */
-(void)prepareCarouselList
{
    NSArray *allService = [self UUIDArray:[[[CyCBManager sharedManager] serviceUUIDDict] allKeys]];

    if (proximityServices)
    {
        [proximityServices removeAllObjects];
    }
    if (findMeServices)
    {
        [findMeServices removeAllObjects];
    }

    // Check for sensor hub
    for (CBService *service in [[CyCBManager sharedManager] foundServices])
    {
        if ([service.UUID isEqual:BAROMETER_SERVICE_UUID])
        {
            [carouselArray addObject:[[[CyCBManager sharedManager] serviceUUIDDict] valueForKey:[service.UUID.UUIDString lowercaseString]]];
            [carouselServices addObject:service];

            isSensorHubFound = YES;
            break;
        }
    }

    if (!isSensorHubFound)
    {
        for(CBService *service in [[CyCBManager sharedManager] foundServices])
        {
            if([allService containsObject:service.UUID])
            {
                NSInteger serviceKeyIndex = [allService indexOfObject:service.UUID];
                CBUUID *keyID = [allService objectAtIndex:serviceKeyIndex];

                if([service.UUID isEqual:CAPSENSE_SERVICE_UUID] || [service.UUID isEqual:CUSTOM_CAPSENSE_SERVICE_UUID])
                {
                    [self checkCapsenseProfile:service];
                }
                else if(![self checkFindMeProfile:service])
                {
                    if ([service.UUID isEqual:IMMEDIATE_ALERT_SERVICE_UUID])
                    {
                        [findMeServices addObject:service];
                    }
                    [carouselArray addObject:[[[CyCBManager sharedManager] serviceUUIDDict] valueForKey:[keyID.UUIDString lowercaseString]]];
                    [carouselServices addObject:service];
                }
            }
            else
            {
                NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"unknown",k_SERVICE_IMAGE_NAME_KEY,[ResourceHandler getServiceNameForUUID:service.UUID],k_SERVICE_NAME_KEY, nil];
                [[[CyCBManager sharedManager] serviceUUIDDict] setValue:tempDict forKey:[service.UUID.UUIDString lowercaseString]];
                [carouselArray addObject:tempDict];
                [carouselServices addObject:service];
            }
        }
    }

    if ([[CyCBManager sharedManager] foundServices].count == 0)
    {
        emptyServiceLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-(EMPTY_SERVICE_LABEL_WIDTH/2), (self.view.frame.size.height/2)-(EMPTY_SERVICE_LABEL_HEIGHT/2), EMPTY_SERVICE_LABEL_WIDTH, EMPTY_SERVICE_LABEL_HEIGHT)];
        emptyServiceLabel.text = LOCALIZEDSTRING(@"serviceNotFound");
        emptyServiceLabel.font = [UIFont fontWithName:DEFAULT_FONT size:FONT_SIZE_MEDIUM];
        emptyServiceLabel.backgroundColor = [UIColor clearColor];
        emptyServiceLabel.textAlignment = NSTextAlignmentCenter;
        emptyServiceLabel.clipsToBounds = YES;
        [_carouselView addSubview:emptyServiceLabel];
    }
    else
    {
        //To add GATT DB item
        [self addGattDBCarouselItem];
    }

    if([carouselArray count])
    {
        [self initCarousel];
    }
}

/*!
 *  @method addGattDBCarouselItem
 *
 *  @discussion Method to add GATTDB carousel item
 *
 */
-(void)addGattDBCarouselItem
{
    [carouselArray insertObject:[[[CyCBManager sharedManager] serviceUUIDDict] valueForKey:GENERIC_ACCESS_SERVICE_UUID] atIndex:0];
    CBMutableService *gattDBService=[[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:GENERIC_ACCESS_SERVICE_UUID] primary:YES];
    [carouselServices insertObject:gattDBService atIndex:0];
}


/*!
 *  @method checkCapsenseProfile:
 *
 *  @discussion Method to check if Capsense service included in peripheral and handle it.
 *              If service list contain more than one Capsense item then all items will list under one carousel item. Otherwise it will display carousel item related to the capsense
 *
 */
-(void)checkCapsenseProfile:(CBService *)service
{
    NSArray *allService = [self UUIDArray:[[[CyCBManager sharedManager] serviceUUIDDict] allKeys]];

    if([service.UUID isEqual:CAPSENSE_SERVICE_UUID] || [service.UUID isEqual:CUSTOM_CAPSENSE_SERVICE_UUID]) {
        [[CyCBManager sharedManager] setMyService:service];
        capsenseModel *capsenseServiceModel = [[capsenseModel alloc] init];

        __weak __typeof(self) wself = self;
        [capsenseServiceModel startDiscoverCharacteristicWithUUID:nil completionHandler:^(BOOL success, CBService *service, NSError *error) {
            __strong __typeof(self) sself = wself;
            if (sself) {
                if (success) {
                    NSMutableArray *tempCarouselArray = [NSMutableArray array];
                    NSInteger serviceKeyIndex = 0;

                    for (CBCharacteristic *characteristic in service.characteristics) {
                        if ([characteristic.UUID isEqual:CAPSENSE_SLIDER_CHARACTERISTIC_UUID] || [characteristic.UUID isEqual:CUSTOM_CAPSENSE_SLIDER_CHARACTERISTIC_UUID]) {
                            serviceKeyIndex = [allService indexOfObject:CAPSENSE_SLIDER_CHARACTERISTIC_UUID];
                        } else if ([characteristic.UUID isEqual:CAPSENSE_PROXIMITY_CHARACTERISTIC_UUID] || [characteristic.UUID isEqual:CUSTOM_CAPSENSE_PROXIMITY_CHARACTERISTIC_UUID]) {
                            serviceKeyIndex = [allService indexOfObject:CAPSENSE_PROXIMITY_CHARACTERISTIC_UUID];
                        } else if ([characteristic.UUID isEqual:CAPSENSE_BUTTON_CHARACTERISTIC_UUID] || [characteristic.UUID isEqual:CUSTOM_CAPSENSE_BUTTONS_CHARACTERISTIC_UUID]) {
                            serviceKeyIndex = [allService indexOfObject:CAPSENSE_BUTTON_CHARACTERISTIC_UUID];
                        }

                        CBUUID *keyID = [allService objectAtIndex:serviceKeyIndex];
                        [tempCarouselArray addObject:[[[CyCBManager sharedManager] serviceUUIDDict] valueForKey:[keyID.UUIDString lowercaseString]]];
                        [sself->carouselCharacteristics addObject:characteristic];
                    }

                    if([tempCarouselArray count] > 1) {
                        NSInteger serviceKeyIndex = [allService indexOfObject:service.UUID];
                        CBUUID *keyID = [allService objectAtIndex:serviceKeyIndex];
                        [sself->carouselArray addObject:[[[CyCBManager sharedManager] serviceUUIDDict] valueForKey:[keyID.UUIDString lowercaseString]]];
                        [sself->carouselServices addObject:service];
                        [sself.carouselView reloadData];
                    } else {
                        [sself->carouselArray addObjectsFromArray:(NSArray*)tempCarouselArray];
                        [sself->carouselServices addObject:service];
                        [sself.carouselView reloadData];
                    }
                }
            }
        }];
    }
}

/*!
 *  @method checkFindMeProfile:
 *
 *  @discussion Method to check if any one of below service is listed as a carousel item , if then skip the rest.
 *  TRANSMISSION_POWER_SERVICE
 *  LINK_LOSS_SERVICE_UUID
 *  IMMEDIATE_ALERT_SERVICE_UUID
 *
 *  The service UUID check with the carousel array whether exist or not , if NO then method will return BOOL value of NO.
 *
 */
-(BOOL)checkFindMeProfile:(CBService *)service
{
    NSArray *findMEUUIDs = [NSArray arrayWithObjects:TRANSMISSION_POWER_SERVICE,LINK_LOSS_SERVICE_UUID, nil];
    if(![findMEUUIDs containsObject:service.UUID])
    {
        return NO;
    }

    [proximityServices addObject:service];

    NSArray *allService = [self UUIDArray:[[[CyCBManager sharedManager] serviceUUIDDict] allKeys]];

    for(CBUUID *findMEServiceID in findMEUUIDs)
    {
        NSInteger fServiceKeyIndex = [allService indexOfObject:findMEServiceID];
        CBUUID *fkeyID = [allService objectAtIndex:fServiceKeyIndex];
        NSDictionary *fDict = [[[CyCBManager sharedManager] serviceUUIDDict] valueForKey:[fkeyID.UUIDString lowercaseString]];
        if([carouselArray containsObject:fDict])
        {
            return  YES;
        }
    }
    return NO;
}

/*!
 *  @method initCarousel
 *
 *  @discussion Method to initialize carousel view
 *
 */
-(void)initCarousel
{
    _carouselView.delegate = self ;
    _carouselView.dataSource = self ;
    _carouselView.type = iCarouselTypeRotary;
    _carouselView.scrollSpeed = 0.9;
    _carouselView.decelerationRate = 0.7;
    [_carouselView reloadData];

    [self performSelector:@selector(animateCarousel) withObject:nil afterDelay:0.2];
}


/*!
 *  @method animateCarousel
 *
 *  @discussion Method to perform animation if only two carousel item are present.
 *
 */
-(void)animateCarousel
{
    if(2 == [carouselArray count])
    {
        [_carouselView scrollByNumberOfItems:2 duration:3.0];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    __weak __typeof(self) wself = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            if (IS_IPAD && [[CyCBManager sharedManager] foundServices].count == 0) {
                sself->emptyServiceLabel.frame = CGRectMake((sself.view.frame.size.width / 2) - (EMPTY_SERVICE_LABEL_WIDTH / 2), (sself.view.frame.size.height / 2) - (EMPTY_SERVICE_LABEL_HEIGHT / 2), EMPTY_SERVICE_LABEL_WIDTH, EMPTY_SERVICE_LABEL_HEIGHT);
            }
        }
    } completion:nil];
}

#pragma mark - AlertControllerDelegate

- (void)alertController:(nonnull UIAlertController *)alertController clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == alertController.cancelButtonIndex) { //YES button
        GATTDBServiceListViewController *servicesVC = [self.storyboard instantiateViewControllerWithIdentifier:GATTDB_VIEW_SB_ID];
        [self.navigationController pushViewController:servicesVC animated:YES];
    }
}

@end
