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

#import "HeartRateMesurementVC.h"
#import "HRMModel.h"
#import "MyLineChart.h"
#import "LoggerHandler.h"
#import "Utilities.h"
#import "UIAlertController+Additions.h"

/*!
 *  @class HeartRateMesurementVC
 *
 *  @discussion Class to upadate UI and user interactions for heart rate measurement service
 *
 */
@interface HeartRateMesurementVC ()<lineChartDelegate> {
    HRMModel *hrmModel;
    MyLineChart *myChart;
    NSMutableArray *hrmDataArray;
    NSMutableArray *timeDataArray;
    KLCPopup *kPopup;
    NSDate *startTime;
    NSTimeInterval previousTimeInterval;
    float xAxisTimeInterval, heartImageHeight, heartImageWidth;
    UIDeviceOrientation devicesOrientation;
}

/* Data fields */
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *expendedEnergyLabel;
@property (weak, nonatomic) IBOutlet UILabel *RRIntervalLabel;
@property (weak, nonatomic) IBOutlet UIView *heartView; // Parent of heartImageView
@property (weak, nonatomic) IBOutlet UIImageView *heartImageView;
@property (weak, nonatomic) IBOutlet UILabel *sensorLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorContactLabel;

/* Constraint outlets to handle the images */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heartImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heartImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *flameImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ecgGraphImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heartRateLabelLeadingConstraint;

@end

@implementation HeartRateMesurementVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializeView];
    
    // Start the heart image animation when the user enters the screen
    [self animateHeartImage];
    
    // Initialize model
    [self initHRMModel];
    
    hrmDataArray = [NSMutableArray array];
    timeDataArray = [NSMutableArray array];
    
    // Initialize time
    startTime = [NSDate date];
    
    previousTimeInterval = 0;
    xAxisTimeInterval = 1.0;
    devicesOrientation = [UIDevice currentDevice].orientation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[super navBarTitleLabel] setText:HEART_RATE_MEASUREMENT];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    if (![self.navigationController.viewControllers containsObject:self]) {
        [hrmModel stopUpdate]; //   Stop receiving characteristic value when the user exits the screen
        [kPopup dismiss:YES];
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
 *  @method initHrmModel
 *
 *  @discussion Method to Discover the specified characteristics of a service.
 *
 */
-(void)initHRMModel {
    hrmModel = [[HRMModel alloc] init];
    [hrmModel discoverCharacteristicsWithHandler:^(BOOL success, NSError *error) {
        if(success) {
            // Get the characteristic value if the characteristic is found successfully
            [self subscribeToCharacteristicUpdates];
        }
    }];
}

/*!
 *  @method startUpdateChar
 *
 *  @discussion Method to get the value of specified characteristic.
 *
 */
-(void)subscribeToCharacteristicUpdates {
    // Establish the weak self reference
    __weak typeof(self) weakSelf = self;
    [hrmModel setCharacteristicUpdateHandler:^(BOOL success, NSError *error) {
        // Establish the strong self reference
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            @synchronized(strongSelf->hrmModel) {
                // Handle the characteristic values if successfully received
                [strongSelf updateHRM];
            }
        }
    }];
}

/*!
 *  @method initializeView
 *
 *  @discussion Method to optimize the UI for Ipad screens.
 *
 */
-(void) initializeView {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Change the image size
        _flameImageHeightConstraint.constant +=  DEFAULT_SIZE_NORMALISATION_CONSTANT_FOR_IPAD;
        _ecgGraphImageHeightConstraint.constant += DEFAULT_SIZE_NORMALISATION_CONSTANT_FOR_IPAD ;
        _heartImageHeightConstraint.constant += DEFAULT_SIZE_NORMALISATION_CONSTANT_FOR_IPAD;
        _heartImageWidthConstraint.constant += DEFAULT_SIZE_NORMALISATION_CONSTANT_FOR_IPAD;
        _heartRateLabelLeadingConstraint.constant += DEFAULT_SIZE_NORMALISATION_CONSTANT_FOR_IPAD;
        [self.view layoutIfNeeded];
    }
    heartImageWidth = _heartImageWidthConstraint.constant;
    heartImageHeight = _heartImageHeightConstraint.constant;
}

/*!
 *  @method animateHeartImage
 *
 *  @discussion Method to handle the animation of heart image.
 *
 */
-(void) animateHeartImage {
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:2
                          delay:1.0
                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                     animations:^{
        __strong typeof(self) sself = wself;
        if (sself) {
            sself.heartImageWidthConstraint.constant = sself->heartImageWidth / 2;
            sself.heartImageHeightConstraint.constant = sself->heartImageHeight / 2;
            [sself.heartImageView setNeedsLayout];
            [sself.heartImageView layoutIfNeeded];
        }
    } completion:^(BOOL finished) {
        //NOOP
    }];
}

/*!
 *  @method updateHRM
 *
 *  @discussion Method to Update UI related to characteristic
 *
 */
-(void)updateHRM {
    // Update datafields
    _heartRateLabel.text = [NSString stringWithFormat:@"%ld",(long)hrmModel.bpmValue];
    if (hrmModel.sensorLocation) { // Body Sensor Location characteristic is optional
        _sensorLocationLabel.text = hrmModel.sensorLocation;
    }
    _sensorContactLabel.text = hrmModel.sensorContact;
    _RRIntervalLabel.text = hrmModel.RRinterval;
    _expendedEnergyLabel.text = hrmModel.energyExpended;
    
    // Handle the characteristic values to update graph
    if(hrmModel.bpmValue) {
        NSTimeInterval timeInterval = fabs([startTime timeIntervalSinceNow]);
        
        if (previousTimeInterval == 0) {
            previousTimeInterval = timeInterval;
        }
        
        if (timeInterval > previousTimeInterval) {
            xAxisTimeInterval = timeInterval - previousTimeInterval;
        }
        
        [timeDataArray addObject:@(timeInterval)];
        [hrmDataArray addObject:@(hrmModel.bpmValue)];
        
        if(myChart && kPopup.isShowing) {
            [self checkGraphPointsCount];
            [myChart updateLineGraph:timeDataArray Y:hrmDataArray ];
            [myChart setXaxisScaleWithValue:nearbyintf(xAxisTimeInterval)];
        }
        previousTimeInterval = timeInterval;
    }
}

/*!
 *  @method shareScreen:
 *
 *  @discussion Method to share the screen
 *
 */
-(void)shareScreen:(id)sender {
    UIImage *screenShot = [Utilities captureScreenShot];
    [kPopup dismiss:YES];
    
    CGRect rect = [(UIButton *)sender frame];
    CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y + (self.view.frame.size.height/2), rect.size.width, rect.size.height);
    [self showActivityPopover:[self saveImage:screenShot] rect:newRect excludedActivities:nil];
}


/*!
 *  @method showGraphPopUp:
 *
 *  @discussion Method to show Graph .
 *
 */
-(IBAction)showGraphPopUp:(id)sender {
    if(myChart) {
        myChart = nil;
    }
    myChart =[[MyLineChart alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2.0)];
    myChart.graphTitleLabel.text = HEART_RATE_GRAPH_HEADER;
    [myChart addXLabel:TIME yLabel:HEART_RATE_YLABEL];
    myChart.delegate = self;
    
    if([timeDataArray count]) {
        [self checkGraphPointsCount];
        [myChart updateLineGraph:timeDataArray Y:hrmDataArray ];
        
        KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,
                                                   KLCPopupVerticalLayoutBottom);
        if(kPopup) {
            kPopup =  nil;
        }
        kPopup = [KLCPopup popupWithContentView:myChart
                                       showType:KLCPopupShowTypeBounceIn
                                    dismissType:KLCPopupDismissTypeBounceOut
                                       maskType:KLCPopupMaskTypeDimmed
                       dismissOnBackgroundTouch:YES
                          dismissOnContentTouch:NO];
        [kPopup showWithLayout:layout];
    } else {
        [[UIAlertController alertWithTitle:APP_NAME message:LOCALIZEDSTRING(@"graphDataNotAvailableAlert")] presentInParent:nil];
    }
}

/*!
 *  @method checkGraphPointsCount
 *
 *  @discussion Method to check the graph plot points
 *
 */
-(void) checkGraphPointsCount {
    if (timeDataArray.count > MAX_GRAPH_POINTS) {
        timeDataArray = [[timeDataArray subarrayWithRange:NSMakeRange(timeDataArray.count - MAX_GRAPH_POINTS,MAX_GRAPH_POINTS)] mutableCopy];
        myChart.chartView.setXmin = YES;
    } else {
        myChart.chartView.setXmin = NO;
    }
    
    if (hrmDataArray.count > MAX_GRAPH_POINTS) {
        hrmDataArray = [[hrmDataArray subarrayWithRange:NSMakeRange( hrmDataArray.count - MAX_GRAPH_POINTS,MAX_GRAPH_POINTS)] mutableCopy];
    }
}

/*!
 *  @method applicationDidEnterForeground:
 *
 *  @discussion Method to handle the heart image animation while application enter in foreground.
 *
 */
-(void)applicationDidEnterForeground:(NSNotification *) notification {
    [self animateHeartImage];
}


/*!
 *  @method applicationDidEnterBackground:
 *
 *  @discussion Method to handle heart image animation while the app goes to background
 *
 */
-(void)applicationDidEnterBackground:(NSNotification *) notification {
    _heartImageHeightConstraint.constant = heartImageHeight;
    _heartImageWidthConstraint.constant = heartImageWidth;
    [_heartImageView.layer removeAllAnimations];
    [self.view layoutIfNeeded];
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
            
            //    if (IS_IPAD && kPopup.isShowing && [UIDevice currentDevice].orientation != UIDeviceOrientationFaceUp) {
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
