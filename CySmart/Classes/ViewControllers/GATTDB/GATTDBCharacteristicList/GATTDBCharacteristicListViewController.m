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

#import "GATTDBCharacteristicListViewController.h"
#import "CharacteristicListTableViewCell.h"
#import "CyCBManager.h"
#import "ResourceHandler.h"

#define CHARACTERISTIC_SEGUE            @"CharacteristicsListSegue"
#define CHARACTERISTIC_CELL_IDENTIFIER  @"CharacteristicListCell"

/*!
 *  @class GATTDBCharacteristicListViewController
 *
 *  @discussion Class to handle the characteristic list
 *
 */
@interface GATTDBCharacteristicListViewController ()<UITableViewDataSource,UITableViewDelegate,cbCharacteristicManagerDelegate>
{
    NSArray *characteristicArray;
}
@property (weak, nonatomic) IBOutlet UITableView *characteristicListTableView;

@end

@implementation GATTDBCharacteristicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getcharcteristicsForService:[[CyCBManager sharedManager] myService]];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[super navBarTitleLabel] setText:GATT_DB];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -TableView Datasource


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return characteristicArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CharacteristicListTableViewCell *currentCell=[tableView dequeueReusableCellWithIdentifier:CHARACTERISTIC_CELL_IDENTIFIER];
    
    if (currentCell == nil)
    {
        currentCell = [[CharacteristicListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CHARACTERISTIC_CELL_IDENTIFIER];
    }
    
    /* Display characteristic name and properties  */
    CBCharacteristic *characteristic = [characteristicArray objectAtIndex:[indexPath row]];
    NSString *characteristicName = [ResourceHandler getCharacteristicNameForUUID:characteristic.UUID];
    [currentCell setCharacteristicName:characteristicName andProperties:[self getPropertiesForCharacteristic:characteristic]];
    
    return currentCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

/*!
 *  @method tableView: willDisplayCell: forRowAtIndexPath:
 *
 *  @discussion Method to set the cell properties
 *
 */

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*  set cell background */
    UIImageView *cellBGImageView=[[UIImageView alloc]initWithFrame:cell.bounds];
    [cellBGImageView setImage:[UIImage imageNamed:CELL_BG_IMAGE]];
    cell.backgroundView=cellBGImageView;
    
}

#pragma mark - TableView Delegates

/*!
 *  @method tableView: didSelectRowAtIndexPath:
 *
 *  @discussion Method to handle the selection of a characteristic
 *
 */

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[CyCBManager sharedManager] setMyCharacteristic:[characteristicArray objectAtIndex:[indexPath row]]];
    [[CyCBManager sharedManager] setCharacteristicProperties:[self getPropertiesForCharacteristic:[characteristicArray objectAtIndex:[indexPath row]]]];
    
    [self performSegueWithIdentifier:CHARACTERISTIC_SEGUE sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*!
 *  @method getcharcteristicsForService:
 *
 *  @discussion Method to initiate discovering characteristics for service
 *
 */

-(void) getcharcteristicsForService:(CBService *)service
{
    [[CyCBManager sharedManager] setCbCharacteristicDelegate:self];
    [[[CyCBManager sharedManager] myPeripheral] discoverCharacteristics:nil forService:service];
}

/*!
 *  @method getPropertiesForCharacteristic:
 *
 *  @discussion Method to get the properties for characteristic
 *
 */
-(NSMutableArray *) getPropertiesForCharacteristic:(CBCharacteristic *)characteristic {
    
    NSMutableArray *propertyList = [NSMutableArray array];
    
    if ((characteristic.properties & CBCharacteristicPropertyRead) != 0) {
        [propertyList addObject:READ];
    }
    if (((characteristic.properties & CBCharacteristicPropertyWrite) != 0) || ((characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0) ) {
       [propertyList addObject:WRITE];;
    }
    if ((characteristic.properties & CBCharacteristicPropertyNotify) != 0) {
       [propertyList addObject:NOTIFY];;
    }
    if ((characteristic.properties & CBCharacteristicPropertyIndicate) != 0) {
       [propertyList addObject:INDICATE];;
    }
    
    return propertyList;
}



#pragma mark - CBCharacteristicManagerDelegate Methods

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[[CyCBManager sharedManager] myService].UUID])
         {
             characteristicArray = [service.characteristics copy];
             [_characteristicListTableView reloadData];
         }
}




@end
