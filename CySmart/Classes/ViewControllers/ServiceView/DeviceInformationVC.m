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

#import "DeviceInformationVC.h"
#import "DeviceInformationTableViewCell.h"
#import "DevieInformationModel.h"
#import "Constants.h"

#define deviceInfoCharacteristicsArray [NSArray arrayWithObjects:MANUFACTURER_NAME,MODEL_NUMBER,SERIAL_NUMBER,HARDWARE_REVISION,FIRMWARE_REVISION,SOFTWARE_REVISION,SYSTEM_ID,REGULATORY_CERTIFICATION_DATA_LIST,PNP_ID,nil]

/*!
 *  @class DeviceInformationVC
 *
 *  @discussion  Class to handle the user interactions and UI updates for device information service  
 *
 */

@interface DeviceInformationVC ()<UITableViewDataSource,UITableViewDelegate>
{
    DevieInformationModel *deviceInfoModel;
}
@property (weak, nonatomic) IBOutlet UITableView *deviceInfoTableView;

@end

@implementation DeviceInformationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _deviceInfoTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Initialize device information model
    [self initModel];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[super navBarTitleLabel] setText:DEVICE_INFO];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*!
 *  @method initModel
 *
 *  @discussion Method to Discover the specified characteristic of a service.
 *
 */
-(void) initModel
{
    deviceInfoModel = [[DevieInformationModel alloc] init];
    __weak __typeof(self) wself = self;
    [deviceInfoModel startDiscoverChar:^(BOOL success, NSError *error) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            if (success) {
                @synchronized(sself->deviceInfoModel) {
                    // Get the characteristic value if the required characteristic is found
                    [sself updateUI];
                }
            }
        }
    }];
}

/*!
 *  @method updateUI
 *
 *  @discussion Method to update UI with the characteristic value.
 *
 */
-(void) updateUI
{
    __weak __typeof(self) wself = self;
    [deviceInfoModel discoverCharacteristicValues:^(BOOL success, NSError *error) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            if (success) {
                // Reload table view with the data received
                [sself.deviceInfoTableView reloadData];
            }
        }
    }];
}

#pragma mark - TableView data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return deviceInfoCharacteristicsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceInformationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceInfoCell"];
    
    if (cell == nil)
    {
        cell = [[DeviceInformationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"deviceInfoCell"];
    }
    NSString *deviceCharaName = [deviceInfoCharacteristicsArray objectAtIndex:[indexPath row]];
    cell.deviceCharacteristicNameLabel.text = deviceCharaName;
    
    if ([deviceInfoModel.deviceInfoCharValueDictionary objectForKey:deviceCharaName] != nil)
    {
        cell.deviceCharacteristicValueLabel.text = [deviceInfoModel.deviceInfoCharValueDictionary objectForKey:deviceCharaName];
    }
        
    return cell;
}


@end
