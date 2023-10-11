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

#import "CyclingSpeedAndCadenceVC.h"
#import "CSCModel.h"
#import "Utilities.h"
#import "MyLineChart.h"
#import "UIView+Toast.h"
#import "UIAlertController+Additions.h"

#define WEIGHT_TEXTFIELD_TAG        100
#define WHEEL_RADIUS_TEXTFIELD_TAG  101

/*!
 *  @class CyclingSpeedAndCadenceVC
 *
 *  @discussion Class to handle the user interactions and UI updates for cycling speeed and cadence service
 *
 */
@interface CyclingSpeedAndCadenceVC ()<UITextFieldDelegate, lineChartDelegate>
{
    CSCModel *mCSCModel;
    NSTimer *timeValueUpdationTimer;
    NSDate *startTime ;
    int timerValue;

    BOOL isCharDiscovered;    // Varieble to determine whether the required characteristic is found

    KLCPopup* kPopup;
    MyLineChart *myChart;
    NSMutableArray *rpmDataArray;
    NSMutableArray *timeDataArray;

    NSTimeInterval previousTimeInterval;
    float xAxisTimeInterval;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;

/* UI Label datafields */

@property (weak, nonatomic) IBOutlet UILabel *wheelRPMLabel;
@property (weak, nonatomic) IBOutlet UILabel *wheelRPMUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *coveredDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *coveredDistanceUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *burnedCaloriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *burnedCaloriesUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UITextField *userWeightTextField;
@property (weak, nonatomic) IBOutlet UITextField *wheelRadiusTextField;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation CyclingSpeedAndCadenceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    rpmDataArray = [NSMutableArray array];
    timeDataArray = [NSMutableArray array];
    [self initializeView];

    // Initialize CSC model
    [self initCSCModel];
    [self addDoneButton];

    previousTimeInterval = 0;
    xAxisTimeInterval = 1.0;
    timerValue = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[super navBarTitleLabel] setText:CSC];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if (![self.navigationController.viewControllers containsObject:self])
    {
        [mCSCModel stopUpdate];    // stop receiving characteristic value when the user exits the screen
        [kPopup dismiss:YES];      // Remove graph pop up
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
 *  @method initializeView
 *
 *  @discussion Method to change image size for Ipad.
 *
 */
-(void) initializeView
{
    if (IS_IPAD)
    {
//        _contentViewHeightConstraint.constant = self.view.frame.size.height - (NAV_BAR_HEIGHT + STATUS_BAR_HEIGHT)
//        ;
//        [self.view layoutIfNeeded];
    }
    _coveredDistanceLabel.text = @"";
    _coveredDistanceUnitLabel.text = @"";
    [_burnedCaloriesUnitLabel setHidden:YES];
    [_wheelRPMUnitLabel setHidden:YES];
}

/*!
 *  @method initCSCModel
 *
 *  @discussion Method to Discovers the specified characteristics of a service.
 *
 */
-(void) initCSCModel
{
    if (!mCSCModel) {
        mCSCModel = [[CSCModel alloc] init];
    }

    __weak __typeof(self) wself = self;
    [mCSCModel startDiscoverChar:^(BOOL success, NSError *error) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            if (success) {
                // Set flag if the required characteristic is found
                sself->isCharDiscovered = success;
            }
        }
    }];
}

/*!
 *  @method startUpdateCharacteristic
 *
 *  @discussion Method to assign completion handler to get call back once the block has completed execution.
 *
 */
-(void) startUpdateCharacteristic
{
    __weak __typeof(self) wself = self;
    [mCSCModel updateCharacteristicWithHandler:^(BOOL success, NSError *error)
     {
        __strong __typeof(self) sself = wself;
        if (sself) {
            // checking whether timer used for ellapsed time calculation exist
            if (success && sself->timeValueUpdationTimer)            {
                [sself updateUI];
            }
        }
    }];
}

/*!
 *  @method updateUI
 *
 *  @discussion Method to Update UI when the characteristic’s value changes.
 *
 */
-(void) updateUI
{
    @synchronized(mCSCModel){

        // Calculate and display distance, RPM and calories burnt
        [self findDistance];
        [self updateRPM];
    }
}

/*!
 *  @method startCountingTime:
 *
 *  @discussion Method to handle start and stop receiving characteristic value
 *
 */
- (IBAction)startCountingTime:(UIButton *)sender
{
    if (!sender.selected)
    {
        NSString *toastMessage = @"";

        // Checking weight textfield

        if([_userWeightTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0){
            toastMessage = LOCALIZEDSTRING(@"emptyWeightFieldWarning");
        }else if ([_userWeightTextField.text floatValue] < 1){
            toastMessage = LOCALIZEDSTRING(@"minWeightWarning");
        }else if([_userWeightTextField.text floatValue] > 200){
            toastMessage = LOCALIZEDSTRING(@"maxWeightWarning");
        }


        if (![toastMessage isEqualToString:@""]) {
            toastMessage = [toastMessage stringByAppendingString:@"\n"];
        }

        // Checking wheel radius textfield

        if ([_wheelRadiusTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
            toastMessage = [toastMessage stringByAppendingString:LOCALIZEDSTRING(@"emptyRadiusFieldWarning")];
        }else if ([_wheelRadiusTextField.text integerValue] < 300){
            toastMessage = [toastMessage stringByAppendingString:LOCALIZEDSTRING(@"minRadiusWarning")];
        }else if ([_wheelRadiusTextField.text integerValue] > 725){
            toastMessage = [toastMessage stringByAppendingString:LOCALIZEDSTRING(@"maxRadiusWarning")];
        }

        if (![toastMessage isEqualToString:@""]) {
            [self.view makeToast:toastMessage];
        }

        [_burnedCaloriesUnitLabel setHidden:NO];
        [_wheelRPMUnitLabel setHidden:NO];

        if(isCharDiscovered)
        {
            int wheelRadius = [_wheelRadiusTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0?[_wheelRadiusTextField.text intValue]:0;
            mCSCModel.wheelRadius = wheelRadius;

            [self startUpdateCharacteristic];

            // Remove keyboard
            if ([_userWeightTextField isFirstResponder]) {
                [_userWeightTextField resignFirstResponder];
            }

            if ([_wheelRadiusTextField isFirstResponder]) {
                [_wheelRadiusTextField resignFirstResponder];
            }

            // Reset time
            startTime = [NSDate date];
            timerValue = 0;

            // Reset graph
            [timeDataArray removeAllObjects];

            timeValueUpdationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];
            sender.selected = YES;
        }

    }
    else
    {
        if (timeValueUpdationTimer)
        {
            [timeValueUpdationTimer invalidate];
        }
        sender.selected = NO;
        [mCSCModel stopUpdate];
    }
}

/*!
 *  @method updateTimeLabel
 *
 *  @discussion Method to show the ellapsed time
 *
 */
-(void)updateTimeLabel
{
    timerValue++;
    _timeLabel.text =  [Utilities timeInFormat:timerValue];

    // Calculate and update Calories burnt
    float userWeight = [[_userWeightTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0 ? [_userWeightTextField.text floatValue] : 0.0f;
    float burntCaloriesAmount = 0;
    if (userWeight >0)
    {
        float time = (float)(timerValue / 60.0);
        burntCaloriesAmount = (time * userWeight * 8.0)/ 1000;
    }
    _burnedCaloriesLabel.text = [NSString stringWithFormat:@"%0.4f",burntCaloriesAmount];
}

/*!
 *  @method findDistance
 *
 *  @discussion Method to show the distance covered
 *
 */
-(void)findDistance
{
    // Check the unit in which the distance should be shown
    if(mCSCModel.coveredDistance < 1000)
    {
        _coveredDistanceLabel.text = [NSString stringWithFormat:@"%0.2f",mCSCModel.coveredDistance];
        _coveredDistanceUnitLabel.text = @"m";
    }
    else
    {
        _coveredDistanceLabel.text = [NSString stringWithFormat:@"%0.2f",[Utilities meterToKM:mCSCModel.coveredDistance]];
        _coveredDistanceUnitLabel.text = @"km";
    }
}

/*!
 *  @method updateRPM
 *
 *  @discussion Method to update wheel RPM
 *
 */
-(void)updateRPM
{
    if (mCSCModel.cadence > 0)
    {
        _wheelRPMLabel.text = [NSString stringWithFormat:@"%d",mCSCModel.cadence];
        // Handle graph
        if(mCSCModel.cadence == INFINITY || mCSCModel.cadence == NAN)
        {
        }
        else
        {
            [rpmDataArray addObject:@(mCSCModel.cadence)];

            NSTimeInterval timeInterval = fabs([startTime timeIntervalSinceNow]);

            if (previousTimeInterval == 0)
            {
                previousTimeInterval = timeInterval;
            }

            if (timeInterval > previousTimeInterval)
            {
                xAxisTimeInterval = timeInterval - previousTimeInterval;
            }

            [timeDataArray addObject:@(timeInterval)];

            if(myChart && kPopup.isShowing)
            {
                [self checkGraphPointsCount];
                [myChart updateLineGraph:timeDataArray Y:rpmDataArray];
                [myChart setXaxisScaleWithValue:nearbyintf(xAxisTimeInterval)];
            }
            previousTimeInterval = timeInterval;
        }
    }
}

#pragma mark - UITextfield Delegate Methods

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (_startButton.selected)
    {
        return NO;
    }
    return YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == WEIGHT_TEXTFIELD_TAG) {

        if ([string isEqualToString:@""]) {
            return YES;
        }else if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound){

            if ([string isEqualToString:@"." ] && [textField.text rangeOfString:@"."].length == 0 && textField.text.length <= 3) {
                return YES;
            }
            return NO;

        }else{

            if ([textField.text rangeOfString:@"."].length > 0 && ![textField.text hasSuffix:@"."]) {
                return NO;
            }

            if ([textField.text rangeOfString:@"."].length == 0 && textField.text.length == 3) {
                return NO;
            }
        }
    }
    else if (textField.tag == WHEEL_RADIUS_TEXTFIELD_TAG)
    {
        if ([string isEqualToString:@""]) {
            return YES;
        }else if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound){
            return NO;
        }else if (textField.text.length >= 3){
            return NO;
        }
    }

    return YES;
}

#pragma mark - Utility Methods

/*!
 *  @method showGraphPopUp:
 *
 *  @discussion Method to show Graph .
 *
 */
-(IBAction)showGraphPopUp:(id)sender
{
    if (myChart) {
        myChart = nil;
    }
    myChart =[[MyLineChart alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2.0)];
    myChart.graphTitleLabel.text = CYCLING_GRAPH_HEADER;
    [myChart addXLabel:TIME yLabel:CYCLING_GRAPH_YLABEL];
    myChart.delegate = self;

    if([timeDataArray count])
    {
        [self checkGraphPointsCount];
        [myChart updateLineGraph:timeDataArray Y:rpmDataArray];

        KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,
                                                   KLCPopupVerticalLayoutCenter);

        kPopup = [KLCPopup popupWithContentView:myChart
                                       showType:KLCPopupShowTypeBounceIn
                                    dismissType:KLCPopupDismissTypeBounceOut
                                       maskType:KLCPopupMaskTypeDimmed
                       dismissOnBackgroundTouch:YES
                          dismissOnContentTouch:NO];
        [kPopup showWithLayout:layout];
    }
    else
        [[UIAlertController alertWithTitle:APP_NAME message:LOCALIZEDSTRING(@"graphDataNotAvailableAlert")] presentInParent:nil];

}

/*!
 *  @method checkGraphPointsCount
 *
 *  @discussion Method to check the graph plot points
 *
 */
-(void) checkGraphPointsCount{

    if (timeDataArray.count > MAX_GRAPH_POINTS) {
        timeDataArray = [[timeDataArray subarrayWithRange:NSMakeRange(timeDataArray.count - MAX_GRAPH_POINTS,MAX_GRAPH_POINTS)] mutableCopy];
        myChart.chartView.setXmin = YES;
    }else{
        myChart.chartView.setXmin = NO;
    }

    if (rpmDataArray.count > MAX_GRAPH_POINTS) {
        rpmDataArray = [[rpmDataArray subarrayWithRange:NSMakeRange(rpmDataArray.count - MAX_GRAPH_POINTS,MAX_GRAPH_POINTS)] mutableCopy];
    }
}

/*!
 *  @method shareScreen:
 *
 *  @discussion Method to share the screen
 *
 */
-(void)shareScreen:(id)sender
{
    UIImage *screenShot = [Utilities captureScreenShot];
    [kPopup dismiss:YES];

    CGRect rect = [(UIButton *)sender frame];

    CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y + (self.view.frame.size.height/2), rect.size.width, rect.size.height);
    [self showActivityPopover:[self saveImage:screenShot] rect:newRect excludedActivities:nil];
}


/*!
 *  @method addDoneButton:
 *
 *  @discussion Method to add a done button on top of the keyboard when displayed
 *
 */
- (void)addDoneButton {
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(doneButtonPressed)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    _userWeightTextField.inputAccessoryView = keyboardToolbar;
    _wheelRadiusTextField.inputAccessoryView = keyboardToolbar;
}

/*!
 *  @method addDoneButton:
 *
 *  @discussion Method to get notified when the custom done button on top of keyboard is tapped
 *
 */
- (void)doneButtonPressed {
    [self.view endEditing:YES];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    __weak __typeof(self) wself = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            if (IS_IPAD && sself->kPopup.isShowing && [UIDevice currentDevice].orientation != UIDeviceOrientationFaceUp) {
                [sself->kPopup dismiss:NO];
                [sself showGraphPopUp:nil];
            }
        }
    } completion:nil];
}

@end
