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

#import "SensorHubViewController.h"
#import "CyCBManager.h"
#import "AccelerometerModel.h"
#import "TemperatureModel.h"
#import "BatteryServiceModel.h"
#import "BarometerModel.h"
#import "DropDownView.h"
#import "MyLineChart.h"
#import "SensorHubModel.h"
#import "FindMeModel.h"

/*!
 *  @class SensorHubViewController
 *
 *  @discussion Class to handle the user interaction and UI update for sensor hub
 *
 */
@interface SensorHubViewController () <DropDownDelegate, UITextViewDelegate,BatteryCharacteristicDelegate>
{
    IBOutlet UIScrollView * scrollView;
    CGFloat scrollViewContentSizeHeight;
    
    NSArray * filterConfigOptionsArray;
    
    BOOL isAccellerometerFilterConfigClicked, isPressureFilterConfigClicked;
    IBOutlet UIButton * accellerometerFilterConfigBtn;
    IBOutlet UIButton * pressureFilterConfigBtn;
    
    //UILabel Outlets for displaying reading values
    IBOutlet UILabel * accellermeterReadingXValueLbl;
    IBOutlet UILabel * accellermeterReadingYValueLbl;
    IBOutlet UILabel * accellermeterReadingZValueLbl;
    IBOutlet UITextField * accelerometerSensorScanIntervalTxtFld;
    IBOutlet UILabel * accelerometerSensorTypeValueLbl;
    
    IBOutlet UILabel * temperatureReadingValueLbl;
    IBOutlet UITextField * temperatureSensorScanIntervalTxtFld;
    IBOutlet UILabel * temperatureSensorTypeValueLbl;
    
    IBOutlet UILabel * batteryReadingValueLbl;
    
    IBOutlet UILabel * pressureReadingValueLbl;
    IBOutlet UITextField * pressureSensorScanIntervalTxtFld;
    IBOutlet UILabel * pressureSensorTypeValueLbl;
    IBOutlet UITextField * pressureThresholdTxtFld;
    
    //Outlets of Graph displaying UIViews
    IBOutlet UIView * accellerometerGraphView;
    IBOutlet UIView * temperatureGraphView;
    IBOutlet UIView * pressureGraphView;
    
    /* Variables, Constraints and Constants to control the View expanding and collapsing */
    
#define GRAPH_VIEW_HEIGHT                       250.0f
#define ACCELLEROMETER_PROPERTIES_VIEW_HEIGHT   140.0f
#define TEMPERATURE_PROPERTIES_VIEW_HEIGHT      100.0f
#define PRESSURE_PROPERTIES_VIEW_HEIGHT         180.0f
#define INITIAL_CONTENT_SIZE_HEIGHT             935.0f
    
#define ACCELLEROMETER_VIEW_HEIGHT              280.0f
#define TEMPERATURE_VIEW_HEIGHT                 170.0f
#define PRESSURE_VIEW_HEIGHT                    280.0f
    
    IBOutlet NSLayoutConstraint * graphViewOfAccelerometer_HeightConstraint;
    IBOutlet NSLayoutConstraint * graphViewOfTemperature_HeightConstraint;
    IBOutlet NSLayoutConstraint * graphViewOfPressure_HeightConstraint;
    
    IBOutlet NSLayoutConstraint * propertiesViewOfAccelerometer_HeightConstraint;
    IBOutlet NSLayoutConstraint * propertiesViewOfTemperature_HeightConstraint;
    IBOutlet NSLayoutConstraint * propertiesViewOfPressure_HeightConstraint;
    
    IBOutlet NSLayoutConstraint * accellerometerViewHeightConstraint;
    IBOutlet NSLayoutConstraint * temperatureViewHeightConstraint;
    IBOutlet NSLayoutConstraint * pressureViewHeightConstraint;
    
    IBOutlet NSLayoutConstraint * parentViewHeightConstraint;
    
    IBOutlet NSLayoutConstraint * scrollViewBottomConstraint;
    
    AccelerometerModel *mAccelerometerModel;
    TemperatureModel *mTemperatureModel;
    BatteryServiceModel *mBatteryModel;
    SensorHubModel *mSensorHubModel;
    FindMeModel *mfindMeModel;
    
    BOOL isAccelerometerCharacteristicsdiscovered, isTemperatureCharacteristicsdiscovered, isBarometerCharacteristicsdiscovered;
    
    MyLineChart *pressureChart, *temperatureChart, *accelerometerGraph;
    BOOL isPressureChartVisible, isTemperatureChartVisible, isAccelerometerGraphVisible;
    
    NSMutableArray *pressureDataArray, *pressureTimeDataArray;
    NSMutableArray *temperatureDataArray, *temperatureTimeDataArray;
    NSMutableArray *accelerometerDataArray, *accelerometerTimeDataArray;
    
    //Variables to control Text Field auto positioning when keyboard appears
    CGRect firstResponderRect, keyBoardRect;
    
    NSDate *startTime;
}
@end

@implementation SensorHubViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    //Adding observer to get notified when Keyboard appears or hides
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Predefined array that stores Filter Configuration Options
    filterConfigOptionsArray = [NSArray arrayWithObjects:AVERAGE,MEDIUM,CUSTOM,NONE, nil];
    
    [self initSensorHubmodel];
    [self initBatteryModel];
    
    pressureDataArray = [NSMutableArray array];
    pressureTimeDataArray = [NSMutableArray array];
    
    temperatureDataArray = [NSMutableArray array];
    temperatureTimeDataArray = [NSMutableArray array];
    
    accelerometerDataArray = [NSMutableArray array];
    accelerometerTimeDataArray = [NSMutableArray array];
    
    startTime = [NSDate date];
    //Method for adding Done button as accessory view to the keyboard's top for each text fields
    [self addDoneButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Setting Initial size of the Scroll View and Main Parent View
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, INITIAL_CONTENT_SIZE_HEIGHT)];
    parentViewHeightConstraint.constant = INITIAL_CONTENT_SIZE_HEIGHT;
    scrollViewContentSizeHeight = INITIAL_CONTENT_SIZE_HEIGHT;
    
    //Setting Height of all Graph displaying views to Zero.
    graphViewOfAccelerometer_HeightConstraint.constant = 0;
    graphViewOfPressure_HeightConstraint.constant = 0;
    graphViewOfTemperature_HeightConstraint.constant = 0;
    
    //Setting Height of all Properties displaying views to Zero.
    propertiesViewOfAccelerometer_HeightConstraint.constant = 0;
    propertiesViewOfPressure_HeightConstraint.constant = 0;
    propertiesViewOfTemperature_HeightConstraint.constant = 0;
    
    //Setting the heights of all views specific to profiles
    accellerometerViewHeightConstraint.constant = ACCELLEROMETER_VIEW_HEIGHT;
    temperatureViewHeightConstraint.constant = TEMPERATURE_VIEW_HEIGHT;
    pressureViewHeightConstraint.constant = PRESSURE_VIEW_HEIGHT;
    
    [[super navBarTitleLabel] setText:SENSOR_HUB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (![self.navigationController.viewControllers containsObject:self]) {
        [mBatteryModel  stopUpdate];
        [mSensorHubModel stopUpdate];
    }
}

/*!
 *  @method initSensorHubmodel
 *
 *  @discussion Method to init the sensorhub model
 *
 */

-(void) initSensorHubmodel
{
    if (!mSensorHubModel) {
        mSensorHubModel = [[SensorHubModel alloc] init];
    }
    
    __weak typeof(self) wself = self;
    [mSensorHubModel startDiscoverAccelerometerCharacteristicsWithHandler:^(BOOL success, NSError *error) {
        __strong typeof(self) sself = wself;
        if (sself) {
            if (success) {
                sself->isAccelerometerCharacteristicsdiscovered = YES;
                __weak typeof(sself) wself2 = sself;
                [sself->mSensorHubModel startUpdateAccelerometerXYZValueswithHandler:^(BOOL success, NSError *error) {
                    __strong typeof(sself) sself2 = wself2;
                    if (sself2) {
                        if (success) {
                            @synchronized(sself2->mSensorHubModel.accelerometer) {
                                sself2->accellermeterReadingXValueLbl.text = [NSString stringWithFormat:@"%.0f",sself2->mSensorHubModel.accelerometer.xValue];
                                sself2->accellermeterReadingYValueLbl.text = [NSString stringWithFormat:@"%.0f",sself2->mSensorHubModel.accelerometer.yValue];
                                sself2->accellermeterReadingZValueLbl.text = [NSString stringWithFormat:@"%.0f",sself2->mSensorHubModel.accelerometer.zValue];
                                [sself2 handleAccelerometerGraph];
                            }
                        }
                    }
                }];
            }
        }
    }];
    
    [mSensorHubModel startDiscoverBarometerCharacteristicsWithHandler:^(BOOL success, NSError *error) {
        __strong typeof(self) sself = wself;
        if (sself) {
            if (success) {
                sself->isBarometerCharacteristicsdiscovered = YES;
                __weak typeof(sself) wself2 = sself;
                [sself->mSensorHubModel startUpdateBarometerPressureValueWithHandler:^(BOOL success, NSError *error) {
                    __strong typeof(sself) sself2 = wself2;
                    if (sself2) {
                        if (success) {
                            @synchronized(sself2->mSensorHubModel.barometer) {
                                sself2->pressureReadingValueLbl.text = sself2->mSensorHubModel.barometer.pressureValueString;
                                [sself2 handlePressureGraph];
                            }
                        }
                    }
                }];
            }
        }
    }];
    
    [mSensorHubModel startDiscoverTemperatureCharacteristicsWithHandler:^(BOOL success, NSError *error) {
        __strong typeof(self) sself = wself;
        if (sself) {
            if (success) {
                sself->isTemperatureCharacteristicsdiscovered = YES;
                __weak typeof(sself) wself2 = sself;
                [sself->mSensorHubModel startUpdateTemperatureValueCharacteristicWithHandler:^(BOOL success, NSError *error) {
                    __strong typeof(sself) sself2 = wself2;
                    if (sself2) {
                        if (success) {
                            @synchronized(sself2->mSensorHubModel.temperatureSensor) {
                                sself2->temperatureReadingValueLbl.text = sself2->mSensorHubModel.temperatureSensor.temperatureValueString;
                                [sself2 handleTemperatureGraph];
                            }
                        }
                    }
                }];
            }
        }
    }];
}

#pragma mark - Handling acclerometer

/*!
 *  @method readAccelerometerCharacteristics
 *
 *  @discussion Method to update Accelerometer datafields
 *
 */
-(void) readAccelerometerCharacteristics
{
    if (isAccelerometerCharacteristicsdiscovered) {
        __weak typeof(self) wself = self;
        [mSensorHubModel readValuesForAccelerometerCharacteristicsWithHandler:^(BOOL success, NSError *error) {
            __strong typeof(self) sself = wself;
            if (sself) {
                if (success) {
                    if (sself->mSensorHubModel.accelerometer.sensorTypeString != nil) {
                        sself->accelerometerSensorTypeValueLbl.text = sself->mSensorHubModel.accelerometer.sensorTypeString;
                    }
                    if (sself->mSensorHubModel.accelerometer.scanIntervalString != nil) {
                        sself->accelerometerSensorScanIntervalTxtFld.text = sself->mSensorHubModel.accelerometer.scanIntervalString;
                    }
                }
            }
        }];
    }
}

/*!
 *  @method handleAccelerometerGraph
 *
 *  @discussion Method to handle accelerometer graph
 *
 */
-(void) handleAccelerometerGraph
{
    if(mSensorHubModel.accelerometer.xValue) {
        NSTimeInterval timeInterval = fabs([startTime timeIntervalSinceNow]);
        [accelerometerTimeDataArray addObject:@(timeInterval)];
        [accelerometerDataArray addObject:@(mSensorHubModel.accelerometer.xValue)];
        if (accelerometerGraph && isAccelerometerGraphVisible) {
            [self checkAccelerometerGraphPointsCount];
            [accelerometerGraph updateLineGraph:accelerometerTimeDataArray Y:accelerometerDataArray ];
        }
    }
}

/*!
 *  @method checkAccelerometerGraphPointsCount
 *
 *  @discussion Method to check the graph plot points
 *
 */
-(void) checkAccelerometerGraphPointsCount {
    if (accelerometerTimeDataArray.count > MAX_GRAPH_POINTS) {
        accelerometerTimeDataArray = [[accelerometerTimeDataArray subarrayWithRange:NSMakeRange(accelerometerTimeDataArray.count - MAX_GRAPH_POINTS,MAX_GRAPH_POINTS)] mutableCopy];
        accelerometerGraph.chartView.setXmin = YES;
    } else {
        accelerometerGraph.chartView.setXmin = NO;
    }
    
    if (accelerometerDataArray.count > MAX_GRAPH_POINTS) {
        accelerometerDataArray = [[accelerometerDataArray subarrayWithRange:NSMakeRange(accelerometerDataArray.count - MAX_GRAPH_POINTS,MAX_GRAPH_POINTS)] mutableCopy];
    }
}

#pragma mark - Handling Temperature sensor

/*!
 *  @method readTemperatureCharacteristics
 *
 *  @discussion Method to update temperature data fields
 *
 */
-(void) readTemperatureCharacteristics
{
    if (isTemperatureCharacteristicsdiscovered) {
        __weak __typeof(self) wself = self;
        [mSensorHubModel readValuesForTemperatureCharacteristicsWithHandler:^(BOOL success, NSError *error) {
            __strong __typeof(self) sself = wself;
            if (sself) {
                if (success) {
                    if (sself->mSensorHubModel.temperatureSensor.sensorScanIntervalString != nil) {
                        sself->temperatureSensorScanIntervalTxtFld.text = sself->mSensorHubModel.temperatureSensor.sensorScanIntervalString;
                    }
                    if (sself->mSensorHubModel.temperatureSensor.sensorTypeString != nil) {
                        sself->temperatureSensorTypeValueLbl.text = sself->mSensorHubModel.temperatureSensor.sensorTypeString;
                    }
                }
            }
        }];
    }
}

/*!
 *  @method handleTemperatureGraph
 *
 *  @discussion Method to temperature graph
 *
 */
-(void) handleTemperatureGraph
{
    if(mSensorHubModel.temperatureSensor.temperatureValueString) {
        NSTimeInterval timeInterval = fabs([startTime timeIntervalSinceNow]);
        [temperatureTimeDataArray addObject:@(timeInterval)];
        [temperatureDataArray addObject:@([mSensorHubModel.temperatureSensor.temperatureValueString floatValue])];
        if (temperatureChart && isTemperatureChartVisible) {
            [self checkTemeperatureGraphPointsCount];
            [temperatureChart updateLineGraph:temperatureTimeDataArray Y:temperatureDataArray];
        }
    }
}

/*!
 *  @method checkTemeperatureGraphPointsCount
 *
 *  @discussion Method to check the graph plot points
 *
 */
-(void) checkTemeperatureGraphPointsCount{
    
    if (temperatureTimeDataArray.count > MAX_GRAPH_POINTS) {
        temperatureTimeDataArray = [[temperatureTimeDataArray subarrayWithRange:NSMakeRange(temperatureTimeDataArray.count - MAX_GRAPH_POINTS,MAX_GRAPH_POINTS)] mutableCopy];
        temperatureChart.chartView.setXmin = YES;
    } else {
        temperatureChart.chartView.setXmin = NO;
    }
    
    if (temperatureDataArray.count > MAX_GRAPH_POINTS) {
        temperatureDataArray = [[temperatureDataArray subarrayWithRange:NSMakeRange(temperatureDataArray.count - MAX_GRAPH_POINTS,MAX_GRAPH_POINTS)] mutableCopy];
    }
}

#pragma mark - Handling battery service

/*!
 *  @method initBatteryModel
 *
 *  @discussion Method to init the battery model
 *
 */
-(void) initBatteryModel
{
    for (CBService *service in [[CyCBManager sharedManager] foundServices]) {
        if ([service.UUID isEqual:BATTERY_LEVEL_SERVICE_UUID]) {
            [[CyCBManager sharedManager] setMyService:service];
            break;
        }
    }
    if (!mBatteryModel) {
        mBatteryModel = [[BatteryServiceModel alloc] init];
    }
    
    mBatteryModel.delegate = self;
    mSensorHubModel.batteryModel = mBatteryModel;
    
    __weak __typeof(self) wself = self;
    [mSensorHubModel startDiscoverBatteryCharacteristicsWithHandler:^(BOOL success, NSError *error) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            if (success) {
                [sself->mBatteryModel startUpdateCharacteristic];
            }
        }
    }];
}

/*!
 *  @method updateBatteryUI
 *
 *  @discussion Method to Update UI with the value received from model
 *
 */
-(void)updateBatteryUI
{
    @synchronized(mBatteryModel) {
        
        for(NSString *key in [mBatteryModel.batteryServiceDict allKeys]) {
            NSString *batteryLevelVal = [mBatteryModel.batteryServiceDict valueForKey:key];// Getting current battery level
            batteryReadingValueLbl.text = batteryLevelVal;
            break;
        }
    }
}

#pragma mark - Handling barometer

/*!
 *  @method readBarometerCharacteristics
 *
 *  @discussion Method to update barometer datafields
 *
 */
-(void) readBarometerCharacteristics
{
    if (isBarometerCharacteristicsdiscovered) {
        __weak __typeof(self) wself = self;
        [mSensorHubModel readValuesForBarometerCharacteristicsWithHandler:^(BOOL success, NSError *error) {
            __strong __typeof(self) sself = wself;
            if (sself) {
                if (success) {
                    if (sself->mSensorHubModel.barometer.sensorTypeString != nil) {
                        sself->pressureSensorTypeValueLbl.text = sself->mSensorHubModel.barometer.sensorTypeString;
                    }
                    if (sself->mSensorHubModel.barometer.sensorScanIntervalString != nil) {
                        sself->pressureSensorScanIntervalTxtFld.text = sself->mSensorHubModel.barometer.sensorScanIntervalString;
                    }
                }
            }
        }];
    }
}

/*!
 *  @method handlePressureGraph
 *
 *  @discussion Method to handle pressure graph
 *
 */
-(void) handlePressureGraph
{
    if(mSensorHubModel.barometer.pressureValueString) {
        NSTimeInterval timeInterval = fabs([startTime timeIntervalSinceNow]);
        [pressureTimeDataArray addObject:@(timeInterval)];
        [pressureDataArray addObject:@([mSensorHubModel.barometer.pressureValueString floatValue])];
        if (pressureChart && isPressureChartVisible) {
            [self checkPressureGraphPointsCount];
            [pressureChart updateLineGraph:pressureTimeDataArray Y:pressureDataArray];
        }
    }
}

/*!
 *  @method checkPressureGraphPointsCount
 *
 *  @discussion Method to check the graph plot points
 *
 */
-(void) checkPressureGraphPointsCount{
    
    if (pressureTimeDataArray.count > MAX_GRAPH_POINTS) {
        pressureTimeDataArray = [[pressureTimeDataArray subarrayWithRange:NSMakeRange(pressureTimeDataArray.count - MAX_GRAPH_POINTS,MAX_GRAPH_POINTS)] mutableCopy];
        pressureChart.chartView.setXmin = YES;
    } else {
        pressureChart.chartView.setXmin = NO;
    }
    
    if (pressureDataArray.count > MAX_GRAPH_POINTS) {
        pressureDataArray = [[pressureDataArray subarrayWithRange:NSMakeRange(pressureDataArray.count - MAX_GRAPH_POINTS,MAX_GRAPH_POINTS)] mutableCopy];
    }
}

#pragma mark - Button Actions

/*!
 *  @method locateDeviceBtnClicked:
 *
 *  @discussion Method to write value for immediate alert service
 *
 */
- (IBAction)locateDeviceBtnClicked:(UIButton *)sender
{
    __weak __typeof(self) wself = self;
    [mSensorHubModel startDiscoverImmediateAlertCharacteristicsWithHandler:^(BOOL success, NSError *error) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            if (success) {
                [sself->mSensorHubModel.findMeModel updateImmedieteALertCharacteristicValue:kAlertHigh withHandler:^(BOOL success, NSError *error) {
                    if (success) {
                        NSLog(@"successfully written value");
                    }
                }];
            }
        }
    }];
    [sender setSelected:sender.selected ? NO : YES];
}

#pragma mark - Expand/Collapse Graph Views Button Click Events

/*!
 *  @method accellerometerGraphBtnClicked:
 *
 *  @discussion Method to expand/collapse the Graph displaying view of accelerometer
 *
 */
- (IBAction)accellerometerGraphBtnClicked:(UIButton *)sender
{
    if (graphViewOfAccelerometer_HeightConstraint.constant == 0) {
        scrollViewContentSizeHeight += GRAPH_VIEW_HEIGHT;
        graphViewOfAccelerometer_HeightConstraint.constant = GRAPH_VIEW_HEIGHT;
        accellerometerViewHeightConstraint.constant += GRAPH_VIEW_HEIGHT;
    } else {
        scrollViewContentSizeHeight -= GRAPH_VIEW_HEIGHT;
        graphViewOfAccelerometer_HeightConstraint.constant = 0;
        accellerometerViewHeightConstraint.constant -= GRAPH_VIEW_HEIGHT;
    }
    
    parentViewHeightConstraint.constant = scrollViewContentSizeHeight;
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollViewContentSizeHeight)];
    
    [UIView animateWithDuration:1.0 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    // Add accelerometer Graph
    if (!sender.selected) {
        sender.selected = YES;
        isAccelerometerGraphVisible = YES ;
        
        if (!accelerometerGraph) {
            accelerometerGraph =[[MyLineChart alloc] initWithFrame:CGRectMake(0, 0, accellerometerGraphView.frame.size.width, accellerometerGraphView.frame.size.height)];
            accelerometerGraph.graphTitleLabel.text = ACCELEROMETER;
            [accelerometerGraph addXLabel:TIME yLabel:ACCELEROMETER];
            
            accelerometerGraph.pauseButton.frame = CGRectMake(accelerometerGraph.pauseButton.frame.origin.x, accelerometerGraph.pauseButton.frame.origin.y, accelerometerGraph.frame.size.width, accelerometerGraph.pauseButton.frame.size.height) ;
            
            accelerometerGraph.shareButton.frame = CGRectMake(0, 0, 0, 0);
        }
        
        if ([accelerometerTimeDataArray count]) {
            [self checkAccelerometerGraphPointsCount];
            [accelerometerGraph updateLineGraph:accelerometerTimeDataArray Y:accelerometerDataArray ];
        }
        [accellerometerGraphView addSubview:accelerometerGraph];
    } else {
        sender.selected = NO;
        isTemperatureChartVisible = NO;
    }
}

/*!
 *  @method temperatureGraphBtnClicked:
 *
 *  @discussion Method to expand/collapse the Graph displaying view of Temperature
 *
 */
- (IBAction)temperatureGraphBtnClicked:(UIButton *)sender
{
    if (graphViewOfTemperature_HeightConstraint.constant == 0) {
        scrollViewContentSizeHeight += GRAPH_VIEW_HEIGHT;
        graphViewOfTemperature_HeightConstraint.constant = GRAPH_VIEW_HEIGHT;
        temperatureViewHeightConstraint.constant += GRAPH_VIEW_HEIGHT;
    } else {
        scrollViewContentSizeHeight -= GRAPH_VIEW_HEIGHT;
        graphViewOfTemperature_HeightConstraint.constant = 0;
        temperatureViewHeightConstraint.constant -= GRAPH_VIEW_HEIGHT;
    }
    
    parentViewHeightConstraint.constant = scrollViewContentSizeHeight;
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollViewContentSizeHeight)];
    
    [UIView animateWithDuration:1.0 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    // Add temperature Graph
    if (!sender.selected) {
        isTemperatureChartVisible = YES ;
        sender.selected = YES;
        
        if (!temperatureChart) {
            temperatureChart =[[MyLineChart alloc] initWithFrame:CGRectMake(0, 0, temperatureGraphView.frame.size.width, temperatureGraphView.frame.size.height)];
            temperatureChart.graphTitleLabel.text = TEMPERATURE;
            [temperatureChart addXLabel:TIME yLabel:TEMPERATURE];
            
            temperatureChart.pauseButton.frame = CGRectMake(temperatureChart.pauseButton.frame.origin.x, temperatureChart.pauseButton.frame.origin.y, temperatureChart.frame.size.width, temperatureChart.pauseButton.frame.size.height) ;
            
            temperatureChart.shareButton.frame = CGRectMake(0, 0, 0, 0);
        }
        
        if ([temperatureTimeDataArray count]) {
            [self checkTemeperatureGraphPointsCount];
            [temperatureChart updateLineGraph:temperatureTimeDataArray Y:temperatureDataArray];
        }
        [temperatureGraphView addSubview:temperatureChart];
    } else {
        isTemperatureChartVisible = NO;
        sender.selected = NO;
    }
}

/*!
 *  @method pressureGraphBtnClicked:
 *
 *  @discussion Method to expand/collapse the Graph displaying view of Pressure
 *
 */
- (IBAction)pressureGraphBtnClicked:(UIButton *)sender
{
    if (graphViewOfPressure_HeightConstraint.constant == 0) {
        scrollViewContentSizeHeight += GRAPH_VIEW_HEIGHT;
        graphViewOfPressure_HeightConstraint.constant = GRAPH_VIEW_HEIGHT;
        pressureViewHeightConstraint.constant += GRAPH_VIEW_HEIGHT;
    } else {
        scrollViewContentSizeHeight -= GRAPH_VIEW_HEIGHT;
        graphViewOfPressure_HeightConstraint.constant = 0;
        pressureViewHeightConstraint.constant -= GRAPH_VIEW_HEIGHT;
    }
    
    parentViewHeightConstraint.constant = scrollViewContentSizeHeight;
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollViewContentSizeHeight)];
    
    [UIView animateWithDuration:1.0 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    // Add Pressure Graph
    if (!sender.selected) {
        isPressureChartVisible = YES ;
        sender.selected = YES;
        if (!pressureChart) {
            pressureChart =[[MyLineChart alloc] initWithFrame:CGRectMake(0, 0, pressureGraphView.frame.size.width, pressureGraphView.frame.size.height)];
            pressureChart.graphTitleLabel.text = PRESSURE;
            [pressureChart addXLabel:TIME yLabel:PRESSURE_YLABEL];
            
            pressureChart.pauseButton.frame = CGRectMake(pressureChart.pauseButton.frame.origin.x, pressureChart.pauseButton.frame.origin.y, pressureChart.frame.size.width, pressureChart.pauseButton.frame.size.height) ;
            
            pressureChart.shareButton.frame = CGRectMake(0, 0, 0, 0);
        }
        if ([pressureTimeDataArray count]) {
            [self checkPressureGraphPointsCount];
            [pressureChart updateLineGraph:pressureTimeDataArray Y:pressureDataArray ];
        }
        [pressureGraphView addSubview:pressureChart];
    } else {
        isPressureChartVisible = NO;
        sender.selected = NO;
    }
}

#pragma mark - Expand/Collapse Property Views Button Click Events

/*!
 *  @method accellerometerPropertiesBtnClicked:
 *
 *  @discussion Method to expand/collapse the Properties displaying view of Accelerometer
 *
 */
- (IBAction)accellerometerPropertiesBtnClicked:(UIButton *)sender
{
    if (propertiesViewOfAccelerometer_HeightConstraint.constant == 0) {
        scrollViewContentSizeHeight += ACCELLEROMETER_PROPERTIES_VIEW_HEIGHT;
        propertiesViewOfAccelerometer_HeightConstraint.constant = ACCELLEROMETER_PROPERTIES_VIEW_HEIGHT;
        accellerometerViewHeightConstraint.constant += ACCELLEROMETER_PROPERTIES_VIEW_HEIGHT;
    } else {
        scrollViewContentSizeHeight -= ACCELLEROMETER_PROPERTIES_VIEW_HEIGHT;
        propertiesViewOfAccelerometer_HeightConstraint.constant =  0;
        accellerometerViewHeightConstraint.constant -= ACCELLEROMETER_PROPERTIES_VIEW_HEIGHT;
    }
    
    parentViewHeightConstraint.constant = scrollViewContentSizeHeight;
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollViewContentSizeHeight)];
    
    [UIView animateWithDuration:1.0 animations:^{
        [self.view layoutIfNeeded];
    }];
    [sender setSelected: sender.selected ? NO : YES];
    
    // Adding values to data fields
    
    [self readAccelerometerCharacteristics];
}

/*!
 *  @method temperaturePropertiesBtnClicked:
 *
 *  @discussion Method to expand/collapse the Properties displaying view of Temperature
 *
 */
- (IBAction)temperaturePropertiesBtnClicked:(UIButton *)sender
{
    if (propertiesViewOfTemperature_HeightConstraint.constant == 0) {
        scrollViewContentSizeHeight += TEMPERATURE_PROPERTIES_VIEW_HEIGHT;
        propertiesViewOfTemperature_HeightConstraint.constant = TEMPERATURE_PROPERTIES_VIEW_HEIGHT;
        temperatureViewHeightConstraint.constant += TEMPERATURE_PROPERTIES_VIEW_HEIGHT;
        
    } else {
        scrollViewContentSizeHeight -= TEMPERATURE_PROPERTIES_VIEW_HEIGHT;
        propertiesViewOfTemperature_HeightConstraint.constant =  0;
        temperatureViewHeightConstraint.constant -= TEMPERATURE_PROPERTIES_VIEW_HEIGHT;
    }
    
    parentViewHeightConstraint.constant = scrollViewContentSizeHeight;
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollViewContentSizeHeight)];
    
    [UIView animateWithDuration:1.0 animations:^{
        [self.view layoutIfNeeded];
    }];
    [sender setSelected: sender.selected ? NO : YES];
    
    [self readTemperatureCharacteristics];
}

/*!
 *  @method pressurePropertiesBtnClicked:
 *
 *  @discussion Method to expand/collapse the Properties displaying view of Pressure
 *
 */
- (IBAction)pressurePropertiesBtnClicked:(UIButton *)sender
{
    if (propertiesViewOfPressure_HeightConstraint.constant == 0) {
        scrollViewContentSizeHeight += PRESSURE_PROPERTIES_VIEW_HEIGHT;
        propertiesViewOfPressure_HeightConstraint.constant = PRESSURE_PROPERTIES_VIEW_HEIGHT;
        pressureViewHeightConstraint.constant += PRESSURE_PROPERTIES_VIEW_HEIGHT;
    } else {
        scrollViewContentSizeHeight -= PRESSURE_PROPERTIES_VIEW_HEIGHT;
        propertiesViewOfPressure_HeightConstraint.constant =  0;
        pressureViewHeightConstraint.constant -= PRESSURE_PROPERTIES_VIEW_HEIGHT;
    }
    
    parentViewHeightConstraint.constant = scrollViewContentSizeHeight;
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollViewContentSizeHeight)];
    
    [UIView animateWithDuration:1.0 animations:^{
        [self.view layoutIfNeeded];
    }];
    [sender setSelected: sender.selected ? NO : YES];
    
    [self readBarometerCharacteristics];
}

#pragma mark -  Filter Configuration Button Click Events

/*!
 *  @method accellerometerFilterConfigurationBtnClicked:
 *
 *  @discussion Method to Show a Drop Down list that contains the available filter configuration options
 *  of accelerometer
 */
-(IBAction)accellerometerFilterConfigurationBtnClicked:(UIButton *)sender
{
    DropDownView *dropDwon = [[DropDownView alloc] initWithDelegate:self titles:filterConfigOptionsArray onButton:sender];
    isAccellerometerFilterConfigClicked = YES;
    isPressureFilterConfigClicked = NO;
    [dropDwon showView];
}

/*!
 *  @method pressureFilterConfigurationBtnClicked:
 *
 *  @discussion Method to Show a Drop Down list that contains the available filter configuration options
 *  of Pressure
 */
-(IBAction)pressureFilterConfigurationBtnClicked:(UIButton *)sender
{
    DropDownView *dropDwon = [[DropDownView alloc] initWithDelegate:self titles:filterConfigOptionsArray onButton:sender];
    isPressureFilterConfigClicked = YES;
    isAccellerometerFilterConfigClicked = NO;
    [dropDwon showView];
}

#pragma mark - DropDownView Delegate Methods

/*!
 *  @method dropDown: valueSelected index:
 *
 *  @discussion Method to be called when an item in the drop down list is selected
 *
 */
- (void)dropDown:(DropDownView *)dropDown valueSelected:(NSString *)value index:(int)index
{
    isAccellerometerFilterConfigClicked ? [accellerometerFilterConfigBtn setTitle:value forState:UIControlStateNormal] : nil;
    isPressureFilterConfigClicked ? [pressureFilterConfigBtn setTitle:value forState:UIControlStateNormal] : nil;
}

#pragma mark - TextField Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    firstResponderRect = [textField convertRect:textField.frame fromView:self.view];
    if (keyBoardRect.size.height != 0) {
        if (scrollViewBottomConstraint.constant == 0) {
            scrollViewBottomConstraint.constant = keyBoardRect.size.height;
            [UIView animateWithDuration:1 animations:^{
                [self.view layoutIfNeeded];
            }];
        }
        [scrollView scrollRectToVisible:firstResponderRect animated:YES];
    }
}

#pragma mark - KeyBoard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    keyBoardRect = [kbFrame CGRectValue];
    
    if (scrollViewBottomConstraint.constant == 0) {
        scrollViewBottomConstraint.constant = keyBoardRect.size.height;
        [UIView animateWithDuration:1 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    [scrollView scrollRectToVisible:firstResponderRect animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    scrollViewBottomConstraint.constant = 0;
    [UIView animateWithDuration:1 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Utility Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
    accelerometerSensorScanIntervalTxtFld.inputAccessoryView = keyboardToolbar;
    temperatureSensorScanIntervalTxtFld.inputAccessoryView = keyboardToolbar;
    pressureSensorScanIntervalTxtFld.inputAccessoryView = keyboardToolbar;
    pressureThresholdTxtFld.inputAccessoryView = keyboardToolbar;
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

@end
