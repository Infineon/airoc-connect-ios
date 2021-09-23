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

#import "RunningSpeedAndCadenceVC.h"
#import "RSCModel.h"
#import "MyLineChart.h"
#import "Utilities.h"
#import "LoggerHandler.h"
#import "UIView+Toast.h"
#import "UIAlertController+Additions.h"

/*!
 *  @class RunningSpeedAndCadenceVC
 *
 *  @discussion Class to handle user interactions and UI updation for running speed and cadence service
 *
 */
@interface RunningSpeedAndCadenceVC ()<UITextFieldDelegate,lineChartDelegate>
{
    RSCModel *mRSCModel;
    NSTimer *timeUpdationTimer;
    NSDate * startTime ;
    
    KLCPopup* kPopup;
    MyLineChart *myChart;
    BOOL isCharacteristicsFound, isStartTimeSet;
    NSMutableArray *rscDataArray;
    NSMutableArray *timeDataArray;
    
    int timerValue;
    NSTimeInterval previousTimeInterval;
    float xAxisTimeInterval;
    UIDeviceOrientation devicesOrientation;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *runImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *flameImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speedImageViewHeightConstraint;

/* Datafields */
@property (weak, nonatomic) IBOutlet UITextField *weightTextField;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgSpeedUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *burntCaloriesAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *burntCaloriesUnitLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation RunningSpeedAndCadenceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    rscDataArray = [NSMutableArray array];
    timeDataArray = [NSMutableArray array];
    // Do any additional setup after loading the view.
    [self initializeView];
    
    //Initialize model
    [self initRSCModel];
    [self addDoneButton];
    
    previousTimeInterval = 0;
    xAxisTimeInterval = 1.0;
    isStartTimeSet = NO;
    devicesOrientation = [UIDevice currentDevice].orientation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[super navBarTitleLabel] setText:RSC];
}


-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (![self.navigationController.viewControllers containsObject:self])
    {
        [mRSCModel stopUpdate];  //  Stop receiving characteristic value when the user exits the screen
        [kPopup dismiss:YES];   // Remove the graph pop up if present when the user exits the screen
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
 *  @discussion Method to optimize the UI for Ipad screens.
 *
 */
-(void) initializeView
{
    [_burntCaloriesUnitLabel setHidden:YES];
    [_avgSpeedUnitLabel setHidden:YES];
    [_distanceUnitLabel setHidden:YES];
    [_distanceValueLabel setHidden:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // Change image size for Ipad
        _runImageViewHeightConstraint.constant += DEFAULT_SIZE_NORMALISATION_CONSTANT_FOR_IPAD;
        _flameImageViewHeightConstraint.constant += DEFAULT_SIZE_NORMALISATION_CONSTANT_FOR_IPAD;
        _speedImageViewHeightConstraint.constant += DEFAULT_SIZE_NORMALISATION_CONSTANT_FOR_IPAD;
        [self.view layoutIfNeeded];
    }
}

/*!
 *  @method initRSCModel
 *
 *  @discussion Method to Discover the specified characteristics of a service.
 *
 */
-(void)initRSCModel
{
    mRSCModel = [[RSCModel alloc] init];
    __weak __typeof(self) wself = self;
    [mRSCModel startDiscoverChar:^(BOOL success, NSError *error) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            if(success) {
                // Get characteristic value if the characteristic is successfully found
                sself->isCharacteristicsFound = YES;
            }
        }
    }];
}

/*!
 *  @method startUpdateChar
 *
 *  @discussion Method to assign completion handler to get call back once the block has completed execution.
 *
 */
-(void)startUpdateChar
{
    __weak __typeof(self) wself = self;
    [mRSCModel updateCharacteristicWithHandler:^(BOOL success, NSError *error) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            // checking whether the timer exist
            if (success && sself->timeUpdationTimer) {
                @synchronized(sself->mRSCModel) {
                    // Update and log the data received
                    [sself updateRSC];
                    [sself UpdateRSCWithChangeInTime];
                }
            }
        }
    }];
}

/*!
 *  @method updateRSC
 *
 *  @discussion Method to Update UI when the characteristic’s value changes.
 *
 */
-(void)updateRSC
{
    // Update distance field
    float distanceInKM = [Utilities meterToKM:mRSCModel.TotalDistance];
    _distanceValueLabel.text = [NSString stringWithFormat:@"%0.2f",distanceInKM];
}

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
    myChart.graphTitleLabel.text = RSC_GRAPH_HEADER;
    [myChart addXLabel:TIME yLabel:RSC_GRAPH_YLABEL];
    myChart.delegate = self;
    if([timeDataArray count])
    {
        [self checkGraphPointsCount];
        [myChart updateLineGraph:timeDataArray Y:rscDataArray ];
        
        KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,
                                                   KLCPopupVerticalLayoutBottom);
        
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
    
    if (rscDataArray.count > MAX_GRAPH_POINTS) {
        rscDataArray = [[rscDataArray subarrayWithRange:NSMakeRange(rscDataArray.count - MAX_GRAPH_POINTS,MAX_GRAPH_POINTS)] mutableCopy];
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
 *  @method startCountingTime:
 *
 *  @discussion Method to handle starting and stopping of timer
 *
 */
- (IBAction)startCountingTime:(UIButton *)sender
{
    if (!sender.selected)
    {
        // Check whether the weight is entered by the user
        
        if([_weightTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        {
            [self.view makeToast:LOCALIZEDSTRING(@"emptyWeightFieldWarning")];
        }else if ([_weightTextField.text floatValue] < 1){
            [self.view makeToast:LOCALIZEDSTRING(@"minWeightWarning")];
        }else if([_weightTextField.text floatValue] > 200){
            [self.view makeToast:LOCALIZEDSTRING(@"maxWeightWarning")];
        }
        [_burntCaloriesUnitLabel setHidden:NO];
        [_avgSpeedUnitLabel setHidden:NO];
        [_distanceUnitLabel setHidden:NO];
        [_distanceValueLabel setHidden:NO];
        
        [_weightTextField resignFirstResponder];
        
        if (isCharacteristicsFound)
        {
            [self startUpdateChar];
            
            if (!isStartTimeSet)
            {
                startTime = [NSDate date];
                isStartTimeSet = YES;
            }
            
            timerValue = 0;
            // Initialize the time
            timeUpdationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];
            sender.selected = YES;
        }
        
    }
    else
    {
        if (timeUpdationTimer)
        {
            [timeUpdationTimer invalidate];
        }
        [mRSCModel stopUpdate];
        sender.selected = NO;
    }
}

/*!
 *  @method UpdateRSCWithChangeInTime
 *
 *  @discussion Method to Update UI related to characteristic
 *
 */
-(void) UpdateRSCWithChangeInTime
{
    // Calculate and update average speed
    
    _avgSpeedLabel.text = [NSString stringWithFormat:@"%0.2f",mRSCModel.InstantaneousSpeed];
    
    // Handle the speed value to update the graph
    if(mRSCModel.InstantaneousSpeed)
    {
        NSTimeInterval timeInterval = fabs([startTime timeIntervalSinceNow]);
        [timeDataArray addObject:@(timeInterval)];
        
        if (previousTimeInterval == 0)
        {
            previousTimeInterval = timeInterval;
        }
        
        if (timeInterval > previousTimeInterval)
        {
            xAxisTimeInterval = timeInterval - previousTimeInterval;
        }
        
        [rscDataArray addObject:@(mRSCModel.InstantaneousSpeed)];
        if(myChart && kPopup.isShowing)
        {
            [self checkGraphPointsCount];
            [myChart updateLineGraph:timeDataArray Y:rscDataArray ];
            [myChart setXaxisScaleWithValue:nearbyintf(xAxisTimeInterval)];
        }
        previousTimeInterval = timeInterval;
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
    
    float userWeight = [[_weightTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0 ? [_weightTextField.text floatValue] : 0.0f;
    float burntCaloriesAmount = 0;
    if (userWeight >0)
    {
        
        float time = (float)(timerValue / 60.0);
        burntCaloriesAmount = (float)(time * userWeight * 8.0)/ 1000;
    }
    _burntCaloriesAmountLabel.text = [NSString stringWithFormat:@"%0.4f",burntCaloriesAmount];
}

#pragma mark - UITextField delegate

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (_startButton.selected)
    {
        return NO;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
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
    return YES;
}

#pragma mark - Utility Methods

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
    _weightTextField.inputAccessoryView = keyboardToolbar;
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
            UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
            BOOL rotated = [sself didDeviceRotate:orientation];
            [sself setDeviceOrientation:orientation];
            
            // if (IS_IPAD && kPopup.isShowing && [UIDevice currentDevice].orientation != UIDeviceOrientationFaceUp) {
            if (IS_IPAD && sself->kPopup.isShowing && rotated) {
                [sself->kPopup dismiss:NO];
                [sself showGraphPopUp:nil];
            }
        }
    } completion:nil];
}

-(void)setDeviceOrientation:(UIDeviceOrientation) currentOrientation {
    switch(currentOrientation) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            devicesOrientation = currentOrientation;
            break;
        default:
            // Ignoring
            break;
    }
}

-(BOOL)didDeviceRotate:(UIDeviceOrientation)currentOrientation {
    BOOL rotated = NO;
    switch(currentOrientation) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            rotated = devicesOrientation != currentOrientation;
            break;
        default:
            // Ignoring
            break;
    }
    return rotated;
}

@end
