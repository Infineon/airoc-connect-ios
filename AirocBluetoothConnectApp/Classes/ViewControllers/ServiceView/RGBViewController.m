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

#import "RGBViewController.h"
#import "RGBModel.h"
#import "Constants.h"

/*!
 *  @class RGBViewController
 *
 *  @discussion Class to handle user interactions and UI updation for RGB service
 *
 */
@interface RGBViewController ()
{
    RGBModel *rgbModel;
}

@property (weak, nonatomic) IBOutlet UIView *pickerContainer;
@property (weak, nonatomic) IBOutlet UIImageView *gamutImage;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImage;
@property (weak, nonatomic) IBOutlet UISlider *intensitySlider;
@property (weak, nonatomic) IBOutlet UIView *colorValueContainerView;
@property (weak, nonatomic) IBOutlet UIView *colorSelectionView;

/* Datafields */
@property (weak, nonatomic) IBOutlet UILabel *currentColorLabel;
@property (weak, nonatomic) IBOutlet UILabel *redColorLabel;
@property (weak, nonatomic) IBOutlet UILabel *greenColorLabel;
@property (weak, nonatomic) IBOutlet UILabel *blueColorLabel;
@property (weak, nonatomic) IBOutlet UILabel *intensityLabel;

/*Layout constraints for dynamically updating UI layouts*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorSelectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorSelectionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valuesDisplayViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valuesDisplayViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorSelectionViewTopDistanceConstraint;

- (IBAction)intensityChanged:(id)sender;

@end

@implementation RGBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self startUpdate];

    // Adding the tap gesture recognizer with uislider to get the tap
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)] ;
    [_intensitySlider addGestureRecognizer:tapRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    [self updateColorAndTableViewsSizesForCurrentOrientation];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navBarTitleLabel] setText:RGB_LED];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

    if (![self.navigationController.viewControllers containsObject:self])
    {
        // Stop receiving characteristic value when the user exits the screen
        [rgbModel stopUpdate];
    }
}

/*!
 *  @method initView
 *
 *  @discussion Method to init the view.
 *
 */
- (void)initView
{
    _thumbImage.hidden = YES; // Hide cursor initially
    [self updateColorAndTableViewsSizesForCurrentOrientation];
}

/*!
 *  @method startUpdate
 *
 *  @discussion Method to get value from specified characteristic.
 *
 */
-(void)startUpdate{
    rgbModel = [[RGBModel alloc] init];
    
    // Establish weak self reference
    __weak typeof(self) wself = self;
    [rgbModel setDidUpdateValueForCharacteristicHandler:^(BOOL success, NSError *error) {
        // Establish strong self reference
        __strong typeof(self) sself = wself;
        [sself updateRGBValues];
        
        // Init intensity slider position
        NSInteger intensity = sself->rgbModel.intensity;
        CGFloat percentage = intensity / (CGFloat)0xFF;
        CGFloat delta = percentage * (sself.intensitySlider.maximumValue - sself.intensitySlider.minimumValue);
        CGFloat value = sself.intensitySlider.minimumValue + delta;
        [sself.intensitySlider setValue:value animated:YES];
    }];
}

/*!
 *  @method updateRGBValues
 *
 *  @discussion Method to update the color and intensity in data fields.
 *
 */
-(void)updateRGBValues
{
    // Upadating datafields
    _redColorLabel.text = [self hexStringForInteger:rgbModel.red];
    _greenColorLabel.text = [self hexStringForInteger:rgbModel.green];
    _blueColorLabel.text = [self hexStringForInteger:rgbModel.blue];
    _intensityLabel.text = [self hexStringForInteger:rgbModel.intensity];
    _currentColorLabel.backgroundColor = [UIColor colorWithRed:rgbModel.red/255.0 green:rgbModel.green/255.0 blue:rgbModel.blue/255.0 alpha:rgbModel.intensity/255.0];
}

/*!
 *  @method hexStringForInteger:
 *
 *  @discussion returns hex string for integer value
 *
 */
-(NSString *)hexStringForInteger:(NSInteger)value
{
    return [NSString stringWithFormat:@"0x%02lx",(long)value];
}

/*!
 *  @method intensityChanged:
 *
 *  @discussion Method to handle the inensity change
 *
 */
- (IBAction)intensityChanged:(id)sender
{
    // Write the intensity values to the device
    [rgbModel writeColorWithRed:rgbModel.red green:rgbModel.green blue:rgbModel.blue intensity:_intensitySlider.value handler:^(BOOL success, NSError *error)
     {
         [self updateRGBValues];
     }];
}

#pragma mark - Device orientation notification

/*!
 *  @method updateColorAndTableViewsSizeForCurrentOrientation:
 *
 *  @discussion Updates color selection view and color values table sizes according to orientation.
 *  For landscape orientation the color selection view occupies 60% of screen width
 *  For portrait orientation the color selection view occupies 60% of screen height
 *
 */
- (void)updateColorAndTableViewsSizesForCurrentOrientation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect safeArea = self.view.safeAreaLayoutGuide.layoutFrame;
    CGFloat colorSelectionTopMargin = self.colorSelectionViewTopDistanceConstraint.constant;

    bool isLandscape = \
        orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight;

    if (isLandscape) {
        // Occupy almost full height (except top margin) and 60% of width
        self.colorSelectionViewHeightConstraint.constant = safeArea.size.height - colorSelectionTopMargin;
        self.colorSelectionViewWidthConstraint.constant = safeArea.size.width * 0.6;
        
        // Occupy full height and 40% of width
        self.valuesDisplayViewHeightConstraint.constant = safeArea.size.height;
        self.valuesDisplayViewWidthConstraint.constant = safeArea.size.width - self.colorSelectionViewWidthConstraint.constant;
        
    } else {
        // Portrait
        
        // It is important to take top margin into height calculation. Otherwise intensity slider view will be partially hidden.
        self.colorSelectionViewHeightConstraint.constant = safeArea.size.height * 0.6 - colorSelectionTopMargin;
        self.colorSelectionViewWidthConstraint.constant = safeArea.size.width;
        
        self.valuesDisplayViewHeightConstraint.constant = safeArea.size.height * 0.4;
        self.valuesDisplayViewWidthConstraint.constant = safeArea.size.width;
    }
    [self.view layoutSubviews];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    // Calculate relative position of color picker on gamut image
    CGPoint oldLocationOnGamut = [_pickerContainer convertPoint:_thumbImage.center toView:_gamutImage];
    CGFloat relativeXOnGamut = oldLocationOnGamut.x / _gamutImage.frame.size.width;
    CGFloat relativeYOnGamut = oldLocationOnGamut.y / _gamutImage.frame.size.height;
    
    // Update color picker position during rotation
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    __weak __typeof(self) wself = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        __strong __typeof(self) sself = wself;
        if (sself && IS_IPAD) {
            [sself updateColorAndTableViewsSizesForCurrentOrientation];
            // Re-calculate layout size. Otherwise color picker will be misplaced
            [self.view layoutIfNeeded];
            
            // Calculate new position of color picker
            CGFloat newAbsoluteXOnGamut = sself.gamutImage.frame.size.width * relativeXOnGamut;
            CGFloat newAbsoluteYOnGamut = sself.gamutImage.frame.size.height * relativeYOnGamut;
            CGPoint newLocationOnGamut = CGPointMake(newAbsoluteXOnGamut, newAbsoluteYOnGamut);
            CGPoint newLocationOnSuperView = [sself.gamutImage convertPoint:newLocationOnGamut toView:sself.pickerContainer];
            
            // Draw color picker on new location
            [sself.thumbImage setCenter:newLocationOnSuperView];
        }
    } completion: nil];
}

#pragma mark - tap in slider

/*!
 *  @method sliderTapped:
 *
 *  @discussion Method to handle the the tap on slider
 *
 */
-(void) sliderTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if (_intensitySlider.highlighted) {
        return; // tap on thumb, let slider deal with it
    }
    CGPoint point = [gestureRecognizer locationInView: _intensitySlider];
    CGFloat percentage = point.x / _intensitySlider.bounds.size.width;
    CGFloat delta = percentage * (_intensitySlider.maximumValue - _intensitySlider.minimumValue);
    CGFloat value = _intensitySlider.minimumValue + delta;
    [_intensitySlider setValue:value animated:YES];

    // Write the intensity values to the device
    [rgbModel writeColorWithRed:rgbModel.red green:rgbModel.green blue:rgbModel.blue intensity:_intensitySlider.value handler:^(BOOL success, NSError *error) {
        [self updateRGBValues];
    }];
}


#pragma mark - Touch Methods

/* Methods to handle the touch events */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint tappedPt = [[touches anyObject] locationInView:_pickerContainer];
    [self colorOfPoint:tappedPt]; // Get color at the point where the touch began
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    CGPoint tappedPt = [[touches anyObject] locationInView:_pickerContainer];
    [self colorOfPoint:tappedPt]; // Get color at the point where the touch ended
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint tappedPt = [[touches anyObject] locationInView:_pickerContainer];
    [self colorOfPoint:tappedPt]; // Get color at the current point
}

/*!
 *  @method colorOfPoint:
 *
 *  @discussion Method that returns the color at a particular point
 *
 */
-(UIColor *) colorOfPoint:(CGPoint)point
{
    _thumbImage.hidden = YES;
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    static const int WIDTH = 1;
    static const int HEIGHT = 1;
    static const int BITS_PER_COMPONENT = 8;
    static const int BYTES_PER_ROW = 4;
    CGContextRef context = CGBitmapContextCreate(pixel, WIDTH, HEIGHT, BITS_PER_COMPONENT, BYTES_PER_ROW, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(context, -point.x, -point.y);

    [_pickerContainer.layer renderInContext:context];

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGFloat intensity = _intensitySlider.value/255.0;
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0
                                     green:pixel[1]/255.0
                                     blue:pixel[2]/255.0
                                     alpha:intensity];
    _thumbImage.hidden = NO;

    // Checking the selected color reside inside the color gamut
    if(pixel[3] > 0 && (pixel[0] > 0 || pixel[1] > 0 || pixel[2] > 0 ))
    {
        // Writing the color values to the peripheral
        [rgbModel writeColorWithRed:pixel[0] green:pixel[1] blue:pixel[2] intensity:_intensitySlider.value handler:^(BOOL success, NSError *error)
         {
             if (success)
             {
                 [self updateRGBValues];
             }
         }];
        _thumbImage.center = point ;
        [_currentColorLabel setBackgroundColor:color];   //showing the current selected color in the screen
    }
    return color;
}

@end
