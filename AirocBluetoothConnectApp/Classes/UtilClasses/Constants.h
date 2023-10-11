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

#ifndef Constants_h
#define Constants_h


#endif

enum alertOptions
{
    kAlertNone,
    kAlertMild,
    kAlertHigh
};

#define APP_NAME    @"AIROC™ Bluetooth® Connect App"
#define OPT_CANCEL  @"Cancel"
#define OPT_OK      @"OK"
#define OPT_NO      @"No"
#define OPT_YES     @"Yes"

//Constant for enabling disabling OTA : To disable change YES to NO and vice versa
#define ENABLE_OTA   [NSNumber numberWithBool:YES]

//Constant for enabling disabling Glucose Service : To disable change YES to NO and vice versa
#define ENABLE_GLUCOSE   [NSNumber numberWithBool:YES]

#pragma mark - UI Colors

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                 blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                alpha:1.0]

#define COLOR_PRIMARY UIColorFromRGB(0x5EA290)
#define COLOR_ACCENT  UIColorFromRGB(0xAB377A)
#define COLOR_DARK    UIColorFromRGB(0x263238)

#pragma mark - UI Font sizes
#define FONT_SIZE_LARGE  22
#define FONT_SIZE_MEDIUM 18
#define FONT_SIZE_SMALL  14


#define BLE_PRODUCTS_URL        @"https://www.infineon.com/cms/en/product/wireless-connectivity/airoc-bluetooth-le-bluetooth-multiprotocol/"
#define CONTACT_URL             @"https://www.infineon.com/cms/en/about-infineon/company/contacts/"
#define CYPRESS_HOME_URL        @"https://www.infineon.com"
#define CYPRESS_MOBILE_URL      @"https://www.infineon.com/cms/en/design-support/tools/utilities/wireless-connectivity/airoc-bluetooth-connect-app-mobile-app"


#define DEVICE_CONNECTION_TIMEOUT   20.0


#define ABOUT_VIEW_NIB_NAME           @"AboutView"
#define BUNDLE_VERSION_KEY            @"CFBundleShortVersionString"

#define KEYBOARD_HEIGHT     305.0f
#define STATUS_BAR_HEIGHT   20.0f
#define NAV_BAR_HEIGHT      44.0f
#define MAX_GRAPH_POINTS    200

#define DEFAULT_SIZE_NORMALISATION_CONSTANT_FOR_IPAD     75.0f

#define RSSI_UNDEFINED_VALUE 127

#define RSC_SERVICE_UUID            [CBUUID UUIDWithString:@"1814"]
#define RSC_CHARACTERISTIC_UUID     [CBUUID UUIDWithString:@"2A53"]
#define POLARH7_HRM_DEVICE_INFO_SERVICE_UUID @"180A"       // 180A = Device Information


#define HRM_HEART_RATE_SERVICE_UUID               [CBUUID UUIDWithString:@"180D"]
#define HRM_CHARACTERISTIC_UUID     [CBUUID UUIDWithString:@"2A37"]
#define HRM_BODY_LOCATION_CHARACTERISTIC_UUID     [CBUUID UUIDWithString:@"2A38"]

#define CSC_SERVICE_UUID            [CBUUID UUIDWithString:@"1816"]
#define CSC_CHARACTERISTIC_UUID     [CBUUID UUIDWithString:@"2A5B"]

#define BP_SERVICE_UUID                       [CBUUID UUIDWithString:@"1810"]
#define BP_MEASUREMENT_CHARACTERISTIC_UUID    [CBUUID UUIDWithString:@"2A35"]


#define GLUCOSE_SERVICE_UUID                                  [CBUUID UUIDWithString:@"1808"]
#define GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID               [CBUUID UUIDWithString:@"2A18"]
#define GLUCOSE_RECORD_ACCESS_CONTROL_POINT_UUID              [CBUUID UUIDWithString:@"2A52"]
#define GLUCOSE_MEASUREMENT_CONTEXT_UUID                      [CBUUID UUIDWithString:@"2A34"]

#define THM_SERVICE_UUID                                      [CBUUID UUIDWithString:@"1809"]
#define THM_TEMPERATURE_MEASUREMENT_CHARACTERISTIC_UUID       [CBUUID UUIDWithString:@"2A1C"]
#define THM_TEMPERATURE_TYPE_CHARACTERISTIC_UUID              [CBUUID UUIDWithString:@"2A1D"]

#define DEVICE_INFO_SERVICE_UUID                              [CBUUID UUIDWithString:@"180A"]
#define DEVICE_MANUFACTURER_NAME_CHARACTERISTIC_UUID          [CBUUID UUIDWithString:@"2A29"]
#define DEVICE_MODEL_NUMBER_CHARACTERISTIC_UUID               [CBUUID UUIDWithString:@"2A24"]
#define DEVICE_SERIAL_NUMBER_CHARACTERISTIC_UUID              [CBUUID UUIDWithString:@"2A25"]
#define DEVICE_HARDWARE_REVISION_CHARACTERISTIC_UUID          [CBUUID UUIDWithString:@"2A27"]
#define DEVICE_FIRMWARE_REVISION_CHARACTERISTIC_UUID          [CBUUID UUIDWithString:@"2A26"]
#define DEVICE_SOFTWARE_REVISION_CHARACTERISTIC_UUID          [CBUUID UUIDWithString:@"2A28"]
#define DEVICE_SYSTEMID_CHARACTERISTIC_UUID                   [CBUUID UUIDWithString:@"2A23"]
#define DEVICE_CERTIFICATION_DATALIST_CHARACTERISTIC_UUID     [CBUUID UUIDWithString:@"2A2A"]
#define DEVICE_PNPID_CHARACTERISTIC_UUID                      [CBUUID UUIDWithString:@"2A50"]

#define BATTERY_LEVEL_SERVICE_UUID                            [CBUUID UUIDWithString:@"180F"]
#define BATTERY_LEVEL_CHARACTERISTIC_UUID                     [CBUUID UUIDWithString:@"2A19"]


#define CAPSENSE_SERVICE_UUID                        [CBUUID UUIDWithString:@"CAB5"]
#define CAPSENSE_PROXIMITY_CHARACTERISTIC_UUID       [CBUUID UUIDWithString:@"CAA1"]
#define CAPSENSE_SLIDER_CHARACTERISTIC_UUID          [CBUUID UUIDWithString:@"CAA2"]
#define CAPSENSE_BUTTON_CHARACTERISTIC_UUID          [CBUUID UUIDWithString:@"CAA3"]

#define CUSTOM_CAPSENSE_SERVICE_UUID                             [CBUUID UUIDWithString:@"0003cab5-0000-1000-8000-00805f9b0131"]
#define CUSTOM_CAPSENSE_PROXIMITY_CHARACTERISTIC_UUID            [CBUUID UUIDWithString:@"0003caa1-0000-1000-8000-00805f9b0131"]
#define CUSTOM_CAPSENSE_SLIDER_CHARACTERISTIC_UUID               [CBUUID UUIDWithString:@"0003caa2-0000-1000-8000-00805f9b0131"]
#define CUSTOM_CAPSENSE_BUTTONS_CHARACTERISTIC_UUID              [CBUUID UUIDWithString:@"0003caa3-0000-1000-8000-00805f9b0131"]



#define RGB_SERVICE_UUID            [CBUUID UUIDWithString:@"CBBB"]
#define RGB_CHARACTERISTIC_UUID     [CBUUID UUIDWithString:@"CBB1"]

#define CUSTOM_RGB_SERVICE_UUID               [CBUUID UUIDWithString:@"0003cbbb-0000-1000-8000-00805f9b0131"]
#define CUSTOM_RGB_CHARACTERISTIC_UUID        [CBUUID UUIDWithString:@"0003cbb1-0000-1000-8000-00805f9b0131"]




#define TRANSMISSION_POWER_SERVICE              [CBUUID UUIDWithString:@"1804"]
#define TRANSMISSION_POWER_LEVEL_UUID           [CBUUID UUIDWithString:@"2A07"]
#define LINK_LOSS_SERVICE_UUID                  [CBUUID UUIDWithString:@"1803"]
#define IMMEDIATE_ALERT_SERVICE_UUID            [CBUUID UUIDWithString:@"1802"]
#define ALERT_CHARACTERISTIC_UUID               [CBUUID UUIDWithString:@"2A06"]


#define DESCRIPTOR_CHARACTERISTIC_EXTENDED_PROPERTY_UUID       [CBUUID UUIDWithString:@"2900"]
#define DESCRIPTOR_CHARACTERISTIC_USER_DESCRIPTION_UUID        [CBUUID UUIDWithString:@"2901"]
#define DESCRIPTOR_CLIENT_CHARACTERISTIC_CONFIG_UUID           [CBUUID UUIDWithString:@"2902"]
#define DESCRIPTOR_SERVER_CHARACTERISTIC_CONFIG_UUID           [CBUUID UUIDWithString:@"2903"]
#define DESCRIPTOR_CHARACTERISTIC_PRESENTATION_FORMAT_UUID     [CBUUID UUIDWithString:@"2904"]
#define DESCRIPTOR_CHARACTERISTIC_AGGREGATE_FORMAT_UUID        [CBUUID UUIDWithString:@"2905"]
#define DESCRIPTOR_VALID_RANGE_UUID                            [CBUUID UUIDWithString:@"2906"]
#define DESCRIPTOR_EXTERNAL_REPORT_REFERENCE_UUID              [CBUUID UUIDWithString:@"2907"]
#define DESCRIPTOR_REPORT_REFERENCE_UUID                       [CBUUID UUIDWithString:@"2908"]
#define DESCRIPTOR_ENVIRONMENTAL_SENSING_CONFIG_UUID           [CBUUID UUIDWithString:@"290B"]
#define DESCRIPTOR_ENVIRONMENTAL_SENSING_MEASUREMENT_UUID      [CBUUID UUIDWithString:@"290C"]
#define DESCRIPTOR_ENVIRONMENTAL_SENSING_TRIGGER_SETTING_UUID  [CBUUID UUIDWithString:@"290D"]



#define BAROMETER_SERVICE_UUID                                     [CBUUID UUIDWithString:@"00040001-0000-1000-8000-00805f9b0131"]
#define BAROMETER_DIGITAL_SENSOR_CHARACTERISTIC_UUID               [CBUUID UUIDWithString:@"00040002-0000-1000-8000-00805f9b0131"]
#define BAROMETER_SENSOR_SCAN_INTERVAL_CHARACTERISTIC_UUID         [CBUUID UUIDWithString:@"00040004-0000-1000-8000-00805f9b0131"]
#define BAROMETER_DATA_ACCUMULATION_CHARACTERISTIC_UUID            [CBUUID UUIDWithString:@"00040007-0000-1000-8000-00805f9b0131"]
#define BAROMETER_READING_CHARACTERISTIC_UUID                      [CBUUID UUIDWithString:@"00040009-0000-1000-8000-00805f9b0131"]
#define BAROMETER_THRESHOLD_FOR_INDICATION_CHARACTERISTIC_UUID     [CBUUID UUIDWithString:@"0004000d-0000-1000-8000-00805f9b0131"]


#define ACCELEROMETER_SERVICE_UUID                             [CBUUID UUIDWithString:@"00040020-0000-1000-8000-00805f9b0131"]
#define ACCELEROMETER_ANALOG_SENSOR_CHARACTERISTIC_UUID        [CBUUID UUIDWithString:@"00040021-0000-1000-8000-00805f9b0131"]
#define ACCELEROMETER_SENSOR_SCAN_INTERVAL_CHARACTERISTIC_UUID [CBUUID UUIDWithString:@"00040023-0000-1000-8000-00805f9b0131"]
#define ACCELEROMETER_DATA_ACCUMULATION_CHARACTERISTIC_UUID    [CBUUID UUIDWithString:@"00040026-0000-1000-8000-00805f9b0131"]
#define ACCELEROMETER_READING_X_CHARACTERISTIC_UUID            [CBUUID UUIDWithString:@"00040028-0000-1000-8000-00805f9b0131"]
#define ACCELEROMETER_READING_Y_CHARACTERISTIC_UUID            [CBUUID UUIDWithString:@"0004002b-0000-1000-8000-00805f9b0131"]
#define ACCELEROMETER_READING_Z_CHARACTERISTIC_UUID            [CBUUID UUIDWithString:@"0004002d-0000-1000-8000-00805f9b0131"]



#define ANALOG_TEMPERATURE_SERVICE_UUID                          [CBUUID UUIDWithString:@"00040030-0000-1000-8000-00805f9b0131"]
#define TEMPERATURE_ANALOG_SENSOR_CHARACTERISTIC_UUID            [CBUUID UUIDWithString:@"00040031-0000-1000-8000-00805f9b0131"]
#define TEMPERATURE_SENSOR_SCAN_INTERVAL_CHARACTERISTIC_UUID     [CBUUID UUIDWithString:@"00040032-0000-1000-8000-00805f9b0131"]
#define TEMPERATURE_READING_CHARACTERISTIC_UUID                  [CBUUID UUIDWithString:@"00040033-0000-1000-8000-00805f9b0131"]


#define CUSTOM_BOOT_LOADER_SERVICE_UUID          [CBUUID UUIDWithString:@"00060000-F8CE-11E4-ABF4-0002A5D5C51B"]
#define BOOT_LOADER_CHARACTERISTIC_UUID          [CBUUID UUIDWithString:@"00060001-F8CE-11E4-ABF4-0002A5D5C51B"]

#define COMMAND_START_BYTE      0x01
#define COMMAND_END_BYTE        0x17
//Bootloader command codes

#define VERIFY_CHECKSUM         0x31
#define GET_FLASH_SIZE          0x32
#define GET_APP_STATUS          0x33
#define SYNC                    0x35
#define SET_ACTIVE_APP          0x36
#define SEND_DATA               0x37
#define ENTER_BOOTLOADER        0x38
#define PROGRAM_ROW             0x39
#define VERIFY_ROW              0x3A
#define EXIT_BOOTLOADER         0x3B
//Verify checksum for the app is valid (CYACD2)
#define VERIFY_APP              0x31
//Program single data row (CYACD2)
#define PROGRAM_DATA            0x49
//Set app metadata in bootloader SDK (CYACD2)
#define SET_APP_METADATA        0x4C
//Set encryption initial vector (CYACD2)
#define SET_EIV                 0x4D

//Bulletproof OTAFU
#define POST_SYNC_ENTER_BOOTLOADER  0xFF

// Bootloader status/Error codes

#define SUCCESS                     0x00
#define ERR_FILE                    0x01
#define ERR_EOF                     0x02
#define ERR_LENGTH                  0x03
#define ERR_DATA                    0x04
#define ERR_COMMAND                 0x05
#define ERR_DEVICE                  0x06
#define ERR_VERSION                 0x07
#define ERR_CHECKSUM                0x08
#define ERR_ARRAY                   0x09
#define ERR_ROW                     0x0A
#define ERR_BOOTLOADER              0x0B
#define ERR_APPLICATION             0x0C
#define ERR_ACTIVE                  0x0D
#define ERR_UNKNOWN                 0x0F
#define ERR_ABORT                   0xFF

#define CYRET_ERR_FILE              @"CYRET_ERR_FILE"
#define CYRET_ERR_EOF               @"CYRET_ERR_EOF"
#define CYRET_ERR_LENGTH            @"CYRET_ERR_LENGTH"
#define CYRET_ERR_DATA              @"CYRET_ERR_DATA"
#define CYRET_ERR_COMMAND           @"CYRET_ERR_COMMAND"
#define CYRET_ERR_DEVICE            @"CYRET_ERR_DEVICE"
#define CYRET_ERR_VERSION           @"CYRET_ERR_VERSION"
#define CYRET_ERR_CHECKSUM          @"CYRET_ERR_CHECKSUM"
#define CYRET_ERR_ARRAY             @"CYRET_ERR_ARRAY"
#define CYRET_ERR_ROW               @"CYRET_ERR_ROW"
#define CYRET_ERR_BOOTLOADER        @"CYRET_ERR_BOOTLOADER"
#define CYRET_ERR_APPLICATION       @"CYRET_ERR_APPLICATION"
#define CYRET_ERR_ACTIVE            @"CYRET_ERR_ACTIVE"
#define CYRET_ERR_UNKNOWN           @"CYRET_ERR_UNKNOWN"
#define CYRET_ERR_ABORT             @"CYRET_ERR_ABORT"

#define FLASH_ARRAY_ID      @"flashArrayID"
#define FLASH_ROW_NUMBER    @"flashRowNumber"

#define CHECKSUM_TYPE_SUMMATION     0
#define CHECKSUM_TYPE_CRC           1
#define CHECK_SUM                   @"checkSum"
#define CRC_16                      @"crc_16"
#define ROW_DATA                    @"rowData"
#define ACTIVE_APP                  @"activeApp"
#define SECURITY_KEY                @"securityKey"
#define SECURITY_KEY_NUM_BYTES      6

#define BLOOD_PRESSURE_UNIT_mmHg    @"mmHg"
#define BLOOD_PRESSURE_UNIT_kPa     @"kPa"

/*Carousel View Strings*/
#pragma mark - Carousel View

#define SERVICES @"Services"
#define GENERIC_ACCESS_SERVICE_UUID  @"00001800-0000-1000-8000-00805f9b34fb"

#define k_SERVICE_IMAGE_NAME_KEY    @"Service_Image"
#define k_SERVICE_NAME_KEY          @"Service_Name"


#define DEFAULT_FONT_BOLD               @"Roboto-Bold"
#define DEFAULT_FONT                    @"Roboto"

#define HRM_VIEW_SB_ID                  @"HRMId"
#define RSC_VIEW_SB_ID                  @"RSCID"
#define CSC_VIEW_SB_ID                  @"CSCId"
#define DEVICE_INFO_VIEW_SB_ID          @"DeviceInfoID"
#define GLUCOSE_VIEW_SB_ID              @"glucoseVCID"
#define BP_VIEW_SB_ID                   @"BloodPressureID"
#define CAPSENSE_VIEW_SB_ID             @"CapsenseRootID"
#define CAPSENSE_BTN_VIEW_SB_ID         @"CapsenseButtonID"
#define PROXIMITY_VIEW_SB_ID            @"proximityVCId"
#define CAPSENSE_SLIDER_VIEW_SB_ID      @"sliderVCId"
#define RGB_VIEW_SB_ID                  @"RGBViewID"
#define HEALTH_THERMO_VIEW_SB_ID        @"HealthThermometerID"
#define BATTERY_VIEW_SB_ID              @"BatteryServiceID"
#define FIND_ME_VIEW_SB_ID              @"findMeID"
#define SENSOR_HUB_VIEW_SB_ID           @"sensorHubID"
#define GATTDB_VIEW_SB_ID               @"ServicesID"
#define FILE_SEL_VIEW_SB_ID             @"FileSelectionID"


/* Glucose profile related strings */

#define RESERVED_FOR_FUTURE_USE     @"Reserved for future use"
#define CAPILLARY_WHOLE_BLOOD       @"Capillary Whole blood"
#define CAPILLARY_PLASMA            @"Capillary Plasma"
#define VENOUS_WHOLE_BLOOD          @"Venous Whole blood"
#define VENOUS_PLASMA               @"Venous Plasma"
#define ARTERIAL_WHOLE_BLOOD        @"Arterial Whole blood"
#define ARTERIAL_PLASMA             @"Arterial Plasma"
#define UNDETERMINED_WHOLE_BLOOD    @"Undetermined Whole blood"
#define UNDETERMINED_PLASMA         @"Undetermined Plasma"
#define INTERSTITIAL_FLUID          @"Interstitial Fluid (ISF)"
#define CONTROL_SOLUTION            @"Control Solution"

// Glucose dictionary keys

#define BASE_TIME               @"time"
#define CONCENTRATION_UNIT      @"concentrationUnit"
#define CONCENTRATION_VALUE     @"concentrationValue"
#define SAMPLE_LOCATION         @"sampleLocation"
#define TYPE                    @"type"
#define CONTEXT_INFO_PRESENT    @"contextInformationPresent"
#define SEQUENCE_NUMBER         @"sequenceNumber"

// Glucose measurement context characteristic values

#define CARBOHYDARATE_ID        @"Carbohydrate ID"
#define CARBOHYDARATE           @"Carbohydrate"
#define MEAL                    @"Meal"
#define TESTER                  @"Tester"
#define HEALTH                  @"Health"
#define EXERCISE_DURATION       @"Exercise Duration"
#define EXERCISE_INTENSITY      @"Exercise Intensity"
#define MEDICATION_ID           @"Medication ID"
#define MEDICATION              @"Medication"
#define HBA1C                   @"HbA1c"

// Glucose locaton

#define FINGER                  @"Finger"
#define ALTERNATE_SITE_TEST     @"Alternate Site Test (AST)"
#define LOCATION_UNAVAILABLE    @"Sample Location value not available"

// Glucose - CarbohydrateID

#define BRAEKFAST               @"Breakfast"
#define LUNCH                   @"Lunch"
#define DINNER                  @"Dinner"
#define SNACK                   @"Snack"
#define DRINK                   @"Drink"
#define SUPPER                  @"Supper"
#define BRUNCH                  @"Brunch"

// Glucose - Meal

#define PREPRANDIAL             @"Preprandial (before meal)"
#define POSTPRANDIAL            @"Postprandial (after meal)"
#define FASTING                 @"Fasting"
#define CASUAL                  @"Casual (snacks, drinks, etc.)"
#define BEDTIME                 @"Bedtime"


// Clucose - Tester

#define SELF                        @"Self"
#define HEALTH_CARE_PROFESSIONAL    @"Health Care Professional"
#define LAB_TEST                    @"Lab test"
#define TESTER_VALUE_NOT_AVAILABLE  @"Tester value not available"


// Glucose - Health

#define MINOR_HEALTH_ISSUES         @"Minor health issues"
#define MAJOR_HEALTH_ISSUES         @"Minor health issues"
#define DURING_MENSES               @"During menses"
#define UNDER_STRESS                @"During menses"
#define NO_HEALTH_ISSUE             @"No health issues"
#define HEALTH_VALUE_NOT_AVAILABLE  @"Health value not available"

// Glucose - Exercise duration

#define OVERRUN                     @"overrun"

// Glucose - Medication ID

#define RAPID_ACTING_INSULIN        @"Rapid acting insulin"
#define SHORT_ACTING_INSULIN        @"Short acting insulin"
#define INTERMEDIETE_ACTING_INSULIN @"Intermediate acting insulin"
#define LONG_ACTING_INSULIN         @"Long acting insulin"
#define PRE_MIXED_INSULIN           @"Pre-mixed insulin"


/* Thermometer profile related strings */

// Location

#define ARMPIT                      @"Armpit"
#define BODY_GENERAL                @"Body (general)"
#define EAR_LOBE                    @"Ear (usually ear lobe)"
#define GASTRO_INTENSTINAL_TRACT    @"Gastro-intenstinal Tract"
#define MOUTH                       @"Mouth"
#define RECTUM                      @"Rectum"
#define TOE                         @"Toe"
#define TYMPANUM_EAR_DRUM           @"Tympanum (ear drum)"

/* Heart rate */

// Body location
#define OTHER         @"Other"
#define CHEST         @"Chest"
#define WRIST         @"Wrist"
#define FINGER        @"Finger"
#define HAND          @"Hand"
#define FOOT          @"Foot"
#define LOCATION_NA   @"Body Location:\nN/A"
#define EAR           @"Ear\n(usually ear lobe)"

// Sensor Contact Status bits (bits 1 and 2) of the Flags field of the Heart Rate Measurement characteristic
#define SENSOR_CONTACT_NOT_SUPPORTED    @"Not supported"
#define SENSOR_CONTACT_NOT_DETECTED     @"Not detected"
#define SENSOR_CONTACT_DETECTED         @"Detected"


/* Device information strings */

#define MANUFACTURER_NAME                       @"Manufacturer Name"
#define MODEL_NUMBER                            @"Model Number"
#define SERIAL_NUMBER                           @"Serial Number"
#define HARDWARE_REVISION                       @"Hardware Revision"
#define FIRMWARE_REVISION                       @"Firmware Revision"
#define SOFTWARE_REVISION                       @"Software Revision"
#define SYSTEM_ID                               @"System ID"
#define REGULATORY_CERTIFICATION_DATA_LIST      @"Regulatory Certification Data List"
#define PNP_ID                                  @"PnP ID"


#define BACK_BUTTON_IMAGE       @"backButton"


/* characteristic properties*/

#define READ        @"Read"
#define WRITE       @"Write"
#define NOTIFY      @"Notify"
#define INDICATE    @"Indicate"


/* log strings */

#define CONNECTION_REQUEST          @"Connection request sent"
#define CONNECTION_ESTABLISH        @"Connection established"
#define PAIRING_REQUEST             @"Pairing request sent"
#define PAIRING_RQUEST_RECEIVED     @"Pairing request received"
#define PAIRED                      @"Paired"
#define UNPAIRED                    @"Unpaired"
#define SERVICE_DISCOVERY_REQUEST   @"Service discovery request sent"
#define SERVICE_DISCOVERY_STATUS    @"Service discovery status "
#define DISCONNECTION_REQUEST       @"Disconnection request sent"
#define DISCONNECTED                @"Disconnected"

#define SERVICE_DISCOVERED          @"Success"
#define SERVICE_DISCOVERY_ERROR     @"Service discovery request failed with error : "

// BLE operations

#define WRITE_REQUEST               @"Write request sent with value "
#define WRITE_REQUEST_STATUS        @"Write request status "
#define WRITE_SUCCESS               @"Success"
#define WRITE_ERROR                 @"Failed with error : "

#define START_NOTIFY                @"Start notification request sent"
#define STOP_NOTIFY                 @"Stop notification request sent"
#define NOTIFY_RESPONSE             @"Notification received with value "

#define READ_REQUEST                @"Read request sent"
#define READ_RESPONSE               @"Read response received with value "
#define READ_ERROR                  @"Failed with error : "


#define START_INDICATE              @"Start indicate request sent"
#define STOP_INDICATE               @"Stop indicate request sent"
#define INDICATE_RESPONSE           @"Indicate response received with value "





#define DATA_SEPERATOR      @"##"

/* Date formats */

#define DATE_FORMAT     @"dd-MMM-yyyy"
#define TIME_FORMAT     @"HH:mm:ss.SSS"

/* Device Detection Macros */
#pragma mark - Device detection macros

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define IPAD_PORTRAIT_SCREEN_WIDTH   768.0

/* OTA Upgrade */
#pragma mark - OTA Upgrade

#define UPGRADE_BTN_TITLE_NEXT                      @"NEXT"
#define UPGRADE_BTN_TITLE_UPGRADE                   @"UPGRADE"

/* Descriptor */

// Descriptor names

#define CHARACTERISTIC_EXTENDED_PROPERTIES          @"Characteristic Extended Properties"
#define CHARACTERISTIC_USER_DESCRIPTION             @"Characteristic User Description"
#define CLIENT_CHARACTERISTIC_CONFIG                @"Client Characteristic Configuration"
#define SERVER_CHARACTERISTIC_CONFIG                @"Server Characteristic Configuration"
#define CHARACTERISTIC_PRESENTATION_FORMAT          @"Characteristic Presentation Format"
#define CHARACTERISTIC_AGGREGATE_FORMAT             @"Characteristic Aggregate Format"
#define VALID_RANGE                                 @"Valid Range"
#define EXTERNAL_REPORT_REFERENCE                   @"External Report Reference"
#define REPORT_REFERENCE                            @"Report Reference"
#define ENVIRONMENTAL_SENSING_CONFIG                @"Environmental Sensing Configuration"
#define ENVIRONMENTAL_SENSING_MEASUREMENT           @"Environmental Sensing Measurement"
#define ENVIRONMENTAL_SENSING_TRIGGER_SETTING       @"Environmental Sensing Trigger Setting"

// Characteristic presentation format descriptor

#define NOT_SPECIFIED                       @"not specified"
#define BLUETOOTH_SIG_ASSIGNED_NUMBERS      @"Bluetooth SIG Assigned Numbers"

// Descriptor value information

#define RELIABLE_WRITE_ENABLED              @"Reliable Write enabled"
#define RELIABLE_WRITE_DISABLED             @"Reliable Write disabled"

#define WRITABLE_AUXILARIES_ENABLED         @"Writable Auxiliaries enabled"
#define WRITABLE_AUXILARIES_DISABLED        @"Writable Auxiliaries disabled"

#define INDICATE_ENABLED                @"Indications enabled"
#define INDICATE_DISABLED               @"Indications disabled"

#define NOTIFY_ENABLED                  @"Notifications enabled"
#define NOTIFY_DISABLED                 @"Notifications disabled"

#define BROADCAST_ENABLED               @"Broadcasts enabled"
#define BOADCAST_DISABLED               @"Broadcasts disabled"

#define INDICATE_AND_NOTIFY_DISABLED    @"Both indications and notifications disabled"

/* Graph labels */

#define ACCELEROMETER                   @"Accelerometer"
#define TIME                            @"Time (s)"
#define TEMPERATURE                     @"Temperature"
#define PRESSURE                        @"Pressure"
#define PRESSURE_YLABEL                 @"Pressure (kPa)"

#define CYCLING_GRAPH_HEADER            @"Cadence vs Time"
#define CYCLING_GRAPH_YLABEL            @"Cadence (rpm)"

#define TEMPERATURE_GRAPH_HEADER        @"Temperature vs Time"
#define TEMPERATURE_YLABEL              @"Temperature(°C)"

#define HEART_RATE_GRAPH_HEADER         @"Heart Rate vs Time"
#define HEART_RATE_YLABEL               @"Heart Rate (bpm)"

#define RSC_GRAPH_HEADER                @"Instantaneous Speed vs Time"
#define RSC_GRAPH_YLABEL                @"Instantaneous Speed (km/h)"


/* File parsing alerts */

#define FILE_FORMAT_ERROR           @"FileFormatError"
#define PARSING_ERROR               @"ParsingError"
#define FILE_EMPTY_ERROR            @"FileEmpty"

/* Sensor hub */

#define AVERAGE     @"Average"
#define MEDIUM      @"Medium"
#define CUSTOM      @"Custom"
#define NONE        @"None"

/* Find me and proximity*/

#define NO_ALERT                @"No Alert"
#define MILD_ALERT              @"Mild Alert"
#define HIGH_ALERT              @"High Alert"
#define SELECT                  @"Select"

/*Navigation Bar Titles*/
#pragma mark - Navigation Bar Titles


#define FIRMWARE_UPGRADE            @"OTA Firmware Upgrade"
#define SENSOR_HUB                  @"Sensor Hub"
#define ABOUT_US                    @"About"
#define CONTACT_US                  @"Contact Us"
#define DEVICES                     @"Devices"
#define LOGGER                      @"Data Logger"
#define HOME                        @"Home"
#define GATT_DB                     @"GATT DB"
#define DATA_LOGGER                 @"Data Logger"
#define BATTERY_INFORMATION         @"Battery Service"
#define BP                          @"Blood Pressure"
#define CAPSENSE                    @"CAPSENSE™"
#define CAPSENSE_SELECTION          @"CAPSENSE™ Selection"
#define CSC                         @"Cycling Speed and Cadence"
#define DEVICE_INFO                 @"Device Information"
#define FIND_ME                     @"Find Me"
#define PROXIMITY                   @"Proximity"
#define GLUCOSE                     @"Glucose"
#define THERMOMETER                 @"Health Thermometer"
#define HEART_RATE_MEASUREMENT      @"Heart Rate"
#define RGB_LED                     @"RGB LED"
#define RSC                         @"Running Speed and Cadence"
#define BLE_DEVICE                  @"Devices"
#define GLUCOSE_CONTEXT             @"Glucose Measurement Context"


#define LOCALIZEDSTRING(string) NSLocalizedString(string, nil)

#define PRODUCT_ID          @"ProductID"
#define APP_ID              @"AppID"
#define APP_META_APP_START  @"APP_META_APP_START"
#define APP_META_APP_SIZE   @"APP_META_APP_SIZE"
#define ADDRESS             @"Address"
#define CRC_32              @"CRC32"

typedef NS_ENUM(NSUInteger, iFileVersionType)
{
    iFileVersionTypeCYACD = 0,
    iFileVersionTypeCYACD2
};

typedef NS_ENUM(NSInteger, ActiveApp) {
    NoChange = -1, Image1 = 0, Image2 = 1
};
