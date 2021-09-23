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

#import "CapsenseButtonVC.h"
#import "Constants.h"
#import "CapsenseButtonCollectionViewCell.h"

#define ACTIVE_STATE_CHECK_VALUE    0x01
#define BLUE_CAPSENSE_BUTTON_IMAGE  @"blue_capsense_button"
#define GREEN_CAPSENSE_BUTTON_IMAGE @"green_capsense_button"
#define RED_CAPSENSE_BUTTON_IMAGE   @"red_capsense_button"


/*!
 *  @class CapsenseButtonVC
 *
 *  @discussion Class to handle the UI updates with capsense button service
 *
 */
@interface CapsenseButtonVC ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    // Model to handle the service and characteristics
    capsenseModel *capsenseButtonModel;
}
@property (weak, nonatomic) IBOutlet UICollectionView *capsenseButtonCollectionView;

@end

@implementation CapsenseButtonVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialize the model
    [self initCapsenseModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[super navBarTitleLabel] setText:CAPSENSE];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (![self.navigationController.viewControllers containsObject:self]) {
        // Stop characteristic value update when the user exits screen
        [capsenseButtonModel stopUpdate];
    }
}

/*!
 *  @method initCapsenseModel
 *
 *  @discussion Discovers the specified characteristics of a service.
 *
 */
-(void) initCapsenseModel
{
    if (!capsenseButtonModel) {
        capsenseButtonModel = [[capsenseModel alloc] init];
    }
    
    [capsenseButtonModel startDiscoverCharacteristicWithUUID:_capsenseButtonCharacteristicUUID completionHandler:^(BOOL success, CBService *service, NSError *error) {
        // Get characteristic value if found successfully
        if (success) {
            [self startUpdateCapsenseButtonChar];
        }
    }];
}

/*!
 *  @method startUpdateCapsenseButtonChar
 *
 *  @discussion Method to update the characteristic value.
 *
 */
-(void) startUpdateCapsenseButtonChar
{
    __weak __typeof(self) wself = self;
    [capsenseButtonModel updateCharacteristicWithHandler:^(BOOL success, NSError *error) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            if (success) {
                @synchronized(sself->capsenseButtonModel) {
                    // reload the collection view with the capsense button number and state
                    [sself.capsenseButtonCollectionView reloadData];
                }
            }
        }
    }];
}

/*!
 *  @method senseButtonAtPosition:shouldSetActive:
 *
 *  @discussion Method that returns the button state by checking the status flag
 *
 */
-(BOOL) capsenseButtonAtPosition:(int)buttonPosition shouldSetActive:(uint8_t) statusFlag
{
    uint8_t testValue = ACTIVE_STATE_CHECK_VALUE;
    
    testValue = testValue << buttonPosition; // shift the value upto the button position
    
    // check the state of button at the current  position
    if (statusFlag & testValue) {
        return YES;
    }
    return NO;
}

#pragma mark - collection view delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return capsenseButtonModel.capsenseButtonCount;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"capsenseButtonCellID";
    
    CapsenseButtonCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[CapsenseButtonCollectionViewCell alloc] init];
    }
    
    if ([indexPath row] > 7) {
        // checking and assigning images for capsense button according to the button active state
        if ([self capsenseButtonAtPosition:(int)([indexPath row]-8) shouldSetActive:capsenseButtonModel.capsenseButtonStatus2]) {
            cell.capsenseButtonImageView.image = [UIImage imageNamed:GREEN_CAPSENSE_BUTTON_IMAGE];
        } else {
            cell.capsenseButtonImageView.image = [UIImage imageNamed:BLUE_CAPSENSE_BUTTON_IMAGE];
        }
    } else {
        // checking and assigning images for capsense button according to the button active state
        if ([self capsenseButtonAtPosition:(int)[indexPath row] shouldSetActive:capsenseButtonModel.capsenseButtonStatus1]) {
            cell.capsenseButtonImageView.image = [UIImage imageNamed:GREEN_CAPSENSE_BUTTON_IMAGE];
        } else {
            cell.capsenseButtonImageView.image = [UIImage imageNamed:BLUE_CAPSENSE_BUTTON_IMAGE];
        }
    }
    
    // Assigning the button number
    cell.capsenseButtonNumberLabel.text = [NSString stringWithFormat:@"%d",(int)[indexPath row]+1];
    
    return cell;
}

@end
