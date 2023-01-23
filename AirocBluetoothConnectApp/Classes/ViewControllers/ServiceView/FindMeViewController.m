/*
 * Copyright 2014-2022, Cypress Semiconductor Corporation (an Infineon company) or
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

#import "FindMeViewController.h"
#import "FindMeModel.h"
#import "UIView+Toast.h"
#import "UIAlertController+Additions.h"

#define LINKLOSS_ALERT_ACTIONSHEET  101
#define IMMEDIATE_ALERT_ACTIONSHEET 102

/*!
 *  @class Class FindMeViewController
 *
 *  @discussion Class to handle the user interactions and UI updates for linkloss, immediete alert and transmission power services
 *
 */
@interface FindMeViewController ()<AlertControllerDelegate>
{
    FindMeModel *mFindMeModel;
    UIAlertController *linkLossAlertOptionActionSheet;
    UIAlertController *immediateAlertOptionActionSheet;
    float whiteCircleRefHeight;
}

/*  Selection Buttons */
@property (weak, nonatomic) IBOutlet UIButton *linkLossAlertSelectionButton;
@property (weak, nonatomic) IBOutlet UIButton *ImmediateAlertSelectionButton;

/*  Data field  */
@property (weak, nonatomic) IBOutlet UILabel *transmissionPowerLevelValue;

/*  View outlets  */
@property (weak, nonatomic) IBOutlet UIView *linkLossView;
@property (weak, nonatomic) IBOutlet UIView *immediateALertView;
@property (weak, nonatomic) IBOutlet UIView *transmissionPowerLevelView;

/*  Constraint outlets */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *findMeBlueCircleHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *findMeWhiteCircleHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *immediateAlertViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkLossViewHeightConstraint;

@end

@implementation FindMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    
    // Initialize find me model
    [self initFindMeModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[super navBarTitleLabel] setText:PROXIMITY];
    for (CBService *service in _servicesArray) {
        if ([service.UUID isEqual:IMMEDIATE_ALERT_SERVICE_UUID]) {
            [[super navBarTitleLabel] setText:FIND_ME];
        }
    }
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        // stop receiving characteristic value when the user exits the screen
        [mFindMeModel stopUpdate];
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

/*!
 *  @method initView
 *
 *  @discussion Method to initialize the view properties.
 *
 */
-(void) initView {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _findMeBlueCircleHeightConstraint.constant += DEFAULT_SIZE_NORMALISATION_CONSTANT_FOR_IPAD;
        _findMeWhiteCircleHeightConstraint.constant += DEFAULT_SIZE_NORMALISATION_CONSTANT_FOR_IPAD;
        [self.view layoutIfNeeded];
    }
    whiteCircleRefHeight = _findMeWhiteCircleHeightConstraint.constant;
    
    // Set border color for the labels
    _linkLossAlertSelectionButton.layer.borderColor = [UIColor blueColor].CGColor;
    _linkLossAlertSelectionButton.layer.borderWidth = 1.0;
    
    _ImmediateAlertSelectionButton.layer.borderColor = [UIColor blueColor].CGColor;
    _ImmediateAlertSelectionButton.layer.borderWidth = 1.0;
    
    // Hiding the views initially
    _transmissionPowerLevelView.hidden = YES;
    _immediateAlertViewHeightConstraint.constant = 0;
    _linkLossViewHeightConstraint.constant = 0;
}

/*!
 *  @method initFindMeModel
 *
 *  @discussion Method to Discover the specified characteristic of a service.
 *
 */
-(void) initFindMeModel {
    if (!mFindMeModel) {
        mFindMeModel = [[FindMeModel alloc] init];
    }
    // Find the required characteristic for each service
    if (_servicesArray.count > 0) {
        for (CBService *service  in _servicesArray) {
            [mFindMeModel startDiscoverCharacteristicsForService:service withCompletionHandler:^(CBService *foundService,BOOL success, NSError *error) {
                if (success) {
                    // Get the characteristic value if successfully found out
                    [self updateFindMeUIForServiceWithUUID:foundService.UUID];
                }
            }];
        }
    }
}

/*!
 *  @method updateFindMeUIForServiceWithUUID:
 *
 *  @discussion Method to show the respecive views with the services present
 *
 */
-(void) updateFindMeUIForServiceWithUUID:(CBUUID *)serviceUUID {
    // Check whether the service is present
    if ([serviceUUID isEqual:TRANSMISSION_POWER_SERVICE] && mFindMeModel.isTransmissionPowerPresent) {
        _transmissionPowerLevelView.hidden = NO;
        [self readValueForTransmissionPower];
    }
    if ([serviceUUID isEqual:LINK_LOSS_SERVICE_UUID] && mFindMeModel.isLinkLossServicePresent) {
        _linkLossViewHeightConstraint.constant = 100.0f;
        [_linkLossAlertSelectionButton setTitle:SELECT forState:UIControlStateNormal];
    }
    if ([serviceUUID isEqual:IMMEDIATE_ALERT_SERVICE_UUID] && mFindMeModel.isImmediateAlertServicePresent) {
        _immediateAlertViewHeightConstraint.constant = 100.0f;
        [_ImmediateAlertSelectionButton setTitle:SELECT forState:UIControlStateNormal];
    }
    [self.view layoutIfNeeded];
}

/*  Button actions */
- (IBAction)selectButtonClickedForLinkLossAlert:(UIButton *)sender {
    [self showActionSheet:&linkLossAlertOptionActionSheet withTag:LINKLOSS_ALERT_ACTIONSHEET sourceView:sender sourceRect:sender.bounds];
}

- (IBAction)selectButtonClickedForImmedieteAlert:(UIButton *)sender {
    [self showActionSheet:&immediateAlertOptionActionSheet withTag:IMMEDIATE_ALERT_ACTIONSHEET sourceView:sender sourceRect:sender.bounds];
}

- (void)showActionSheet:(UIAlertController * __strong *)actionSheet withTag:(NSUInteger)tag sourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect {
    // Show selection options
    *actionSheet = nil; // Without setting to null crashes on iPad
    *actionSheet = [UIAlertController actionSheetWithTitle:nil sourceView:sourceView sourceRect:sourceRect delegate:self cancelButtonTitle:OPT_CANCEL destructiveButtonTitle:nil otherButtonTitles:NO_ALERT, MILD_ALERT, HIGH_ALERT, nil];
    (*actionSheet).tag = tag;
    [*actionSheet presentInParent:self];
}

/*!
 *  @method writeValueForLinkLossWith:
 *
 *  @discussion Method to write the link loss characteristic value to the device
 *
 */
-(void) writeValueForLinkLossWith:(enum alertOptions)option WithAlert:(NSString *)alert {
    [mFindMeModel updateLinkLossCharacteristicValue:option WithHandler:^(BOOL success, NSError *error) {
        NSString *message = @"";
        if (success) {
            message = [NSString stringWithFormat:LOCALIZEDSTRING(@"dataWriteSuccessMessage"),alert];
        } else {
            message = LOCALIZEDSTRING(@"dataWriteErrorMessage");
        }
        // Show whether the write was success or not
        [self.view makeToast:message];
    }];
}

/*!
 *  @method writeValueForImmediateAlertWith:
 *
 *  @discussion Method to write the ImmediateAlert characteristic value to the device
 *
 */
-(void) writeValueForImmediateAlertWith:(enum alertOptions)option withAlert:(NSString *)alert {
    [mFindMeModel updateImmedieteALertCharacteristicValue:option withHandler:^(BOOL success, NSError *error) {
        if (success) {
            NSString *message = @"";
            if (success) {
                message = [NSString stringWithFormat:LOCALIZEDSTRING(@"dataWriteSuccessMessage"),alert];
            } else {
                message = LOCALIZEDSTRING(@"dataWriteErrorMessage");
            }
            // Show whether the write was success or not
            [self.view makeToast:message];
        }
    }];
}

/*!
 *  @method readValueForTransmissionPower
 *
 *  @discussion Method to read the power value and handle animation
 *
 */
-(void) readValueForTransmissionPower {
    __weak __typeof(self) wself = self;
    [mFindMeModel updateProximityCharacteristicWithHandler:^(BOOL success, NSError *error) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            if (success) {
                @synchronized(sself->mFindMeModel) {
                    sself.transmissionPowerLevelValue.text = [NSString stringWithFormat:@"%0.f", sself->mFindMeModel.transmissionPowerValue];
                    
                    // Calculating the constraint value
                    float tempValue = sself->mFindMeModel.transmissionPowerValue + 80;
                    
                    if (tempValue <0) {
                        tempValue = tempValue * -1;
                    }
                    
                    // White circle animation
                    float constraintValue = tempValue * (sself->whiteCircleRefHeight/100);
                    sself.findMeWhiteCircleHeightConstraint.constant = constraintValue;
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        [self.view layoutIfNeeded];
                    }];
                }
            }
        }
    }];
}

#pragma mark - AlertControllerDelegate Methods

-(void) alertController:(nonnull UIAlertController *)alertController clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Identify the actionsheet related to which service
    if (alertController.tag == LINKLOSS_ALERT_ACTIONSHEET) {
        // Checking the selected alert and writing the corresponding value to the device
        if (buttonIndex == alertController.firstOtherButtonIndex + kAlertNone) {
            [_linkLossAlertSelectionButton setTitle:NO_ALERT forState:UIControlStateNormal];
            [self writeValueForLinkLossWith:kAlertNone WithAlert:NO_ALERT];
        } else if (buttonIndex == alertController.firstOtherButtonIndex + kAlertMild) {
            [_linkLossAlertSelectionButton setTitle:MILD_ALERT forState:UIControlStateNormal];
            [self writeValueForLinkLossWith:kAlertMild WithAlert:MILD_ALERT];
        } else if (buttonIndex == alertController.firstOtherButtonIndex + kAlertHigh) {
            [_linkLossAlertSelectionButton setTitle:HIGH_ALERT forState:UIControlStateNormal];
            [self writeValueForLinkLossWith:kAlertHigh WithAlert:HIGH_ALERT];
        }
        [_linkLossAlertSelectionButton layoutIfNeeded];
        linkLossAlertOptionActionSheet = nil;
    }
    if (alertController.tag == IMMEDIATE_ALERT_ACTIONSHEET) {
        // Checking the selected alert and writing the corresponding value to the device
        if (buttonIndex == alertController.firstOtherButtonIndex + kAlertNone) {
            [_ImmediateAlertSelectionButton setTitle:NO_ALERT forState:UIControlStateNormal];
            [self writeValueForImmediateAlertWith:kAlertNone withAlert:NO_ALERT];
        } else if (buttonIndex == alertController.firstOtherButtonIndex + kAlertMild) {
            [_ImmediateAlertSelectionButton setTitle:MILD_ALERT forState:UIControlStateNormal];
            [self writeValueForImmediateAlertWith:kAlertMild withAlert:MILD_ALERT];
        } else if (buttonIndex == alertController.firstOtherButtonIndex + kAlertHigh) {
            [_ImmediateAlertSelectionButton setTitle:HIGH_ALERT forState:UIControlStateNormal];
            [self writeValueForImmediateAlertWith:kAlertHigh withAlert:HIGH_ALERT];
        }
        [_ImmediateAlertSelectionButton layoutIfNeeded];
        immediateAlertOptionActionSheet = nil;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    __weak __typeof(self) wself = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            if (sself->linkLossAlertOptionActionSheet) {
                [sself->linkLossAlertOptionActionSheet dismissViewControllerAnimated:NO completion:nil];
                [self showActionSheet:&sself->linkLossAlertOptionActionSheet withTag:LINKLOSS_ALERT_ACTIONSHEET sourceView:sself.linkLossAlertSelectionButton sourceRect:sself.linkLossAlertSelectionButton.bounds];
            }
            if (sself->immediateAlertOptionActionSheet) {
                [sself->immediateAlertOptionActionSheet dismissViewControllerAnimated:NO completion:nil];
                [self showActionSheet:&sself->immediateAlertOptionActionSheet withTag:IMMEDIATE_ALERT_ACTIONSHEET sourceView:sself.ImmediateAlertSelectionButton sourceRect:sself.ImmediateAlertSelectionButton.bounds];
            }
        }
    } completion:nil];
}

@end
