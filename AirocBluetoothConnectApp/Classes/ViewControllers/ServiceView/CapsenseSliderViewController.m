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

#import "CapsenseSliderViewController.h"

/*!
 *  @class CapsenseSliderViewController
 *
 *  @discussion Class to handle the UI updates with capsense slider service
 *
 */
@interface CapsenseSliderViewController ()
{
    float arrowWidthMultiplier, sliderViewFrameHeight, currentSliderValue;
    BOOL isFingerRemoved;
    capsenseModel *sliderModel;  // Model to handle the service and characteristics
}

/* constraint outlets to handle arrow movement */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstArrowLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondArrowLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thirdArrowLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fourthArrowLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fifthArrowLeadingConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *firstArrowImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstArrowWidthConstraint;

@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderViewHeightConstraint;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray * greyArrowImageViews;

@end


@implementation CapsenseSliderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    sliderViewFrameHeight = _sliderView.frame.size.height;  // Slider height is stored to change height for Ipad
    
    // Initializing the position of arrows in slider
    [self initiallizeView];
    [self.view layoutIfNeeded];
    
    // Initialize model
    [self initSliderModel];
    
    for (UIImageView * arrowImage in _greyArrowImageViews) {
        [arrowImage setHidden:NO];
    }
    [_sliderView setBackgroundColor:[UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    [[self navBarTitleLabel] setText:CAPSENSE];
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (![self.navigationController.viewControllers containsObject:self]) {
        [sliderModel stopUpdate];   // stop receiving characteristic value when the user exits the screen
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
 *  @method initSliderModel
 *
 *  @discussion Method to discover the specified characteristics of a service.
 *
 */
-(void) initSliderModel {
    if (!sliderModel) {
        sliderModel = [[capsenseModel alloc] init];;
    }
    
    [sliderModel startDiscoverCharacteristicWithUUID:_sliderCharacteristicUUID completionHandler:^(BOOL success, CBService *service, NSError *error) {
        if (success) {
            // Start receiving characteristic value when characteristic found successfully
            [self updateSliderUI];
        }
    }];
}

/*!
 *  @method updateSliderUI
 *
 *  @discussion Method to Start receiving characteristic value
 *
 */
-(void) updateSliderUI {
    __weak __typeof(self) wself = self;
    [sliderModel updateCharacteristicWithHandler:^(BOOL success, NSError *error) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            if (success){
                @synchronized(sself->sliderModel) {
                    float sliderValue = sself->sliderModel.capsenseSliderValue;
                    
                    sself->isFingerRemoved = sliderValue == 255;
                    if (!sself->isFingerRemoved) {
                        sself->currentSliderValue = sliderValue;
                    }
                    [sself changeSliderToPosition:sliderValue isFingerRemoved:sself->isFingerRemoved];
                }
            }
        }
    }];
}

/*!
 *  @method initializeView
 *
 *  @discussion Method to handle the screen when the user first enters.
 *
 */
-(void) initiallizeView {
    // Calculate the factor by which the arrow should be moved
    arrowWidthMultiplier = [self calculateArrowWidthMultiplier];
    
    // Initially hiding all the imageViews
    _firstArrowLeadingConstraint.constant = -_firstArrowImageView.frame.size.width + 10;
    _secondArrowLeadingConstraint.constant = _thirdArrowLeadingConstraint.constant = _fourthArrowLeadingConstraint.constant = _fifthArrowLeadingConstraint.constant = -_firstArrowImageView.frame.size.width;
    for (UIImageView * arrowImage in _greyArrowImageViews) {
        [arrowImage setHidden:YES];
    }
}

/*!
 *  @method changeSliderToPosition:
 *
 *  @discussion Method to move the arrows with the value received
 *
 */
-(void)changeSliderToPosition:(float)value isFingerRemoved:(BOOL)isFingerRemoved {
    
    const float totalWidth = self.view.frame.size.width;
    const float imageWidth = _firstArrowImageView.frame.size.width;
    const float mult = arrowWidthMultiplier;
    const float d = (20 * mult - imageWidth) * 5 / 4;
    
    // The range of characteristic value is checked to move the respective arrow
    if (value <= 20) {
        
        _firstArrowLeadingConstraint.constant = totalWidth - imageWidth - (100 - value) * mult + 10;
        _secondArrowLeadingConstraint.constant = _thirdArrowLeadingConstraint.constant = _fourthArrowLeadingConstraint.constant = _fifthArrowLeadingConstraint.constant = -imageWidth;
    }
    else if (value > 20 && value <= 40){
        
        _firstArrowLeadingConstraint.constant = 0;
        _secondArrowLeadingConstraint.constant = _thirdArrowLeadingConstraint.constant = _fourthArrowLeadingConstraint.constant = _fifthArrowLeadingConstraint.constant = totalWidth - imageWidth - (100 - value) * mult;
    }
    else if (value > 40 && value <= 60){
        
        _firstArrowLeadingConstraint.constant = 0;
        _secondArrowLeadingConstraint.constant = _firstArrowLeadingConstraint.constant + imageWidth + d;
        _thirdArrowLeadingConstraint.constant = _fourthArrowLeadingConstraint.constant = _fifthArrowLeadingConstraint.constant = totalWidth - imageWidth - (100 - value) * mult;
    }
    else if (value > 60 && value <= 80){
        
        _firstArrowLeadingConstraint.constant = 0;
        _secondArrowLeadingConstraint.constant = _firstArrowLeadingConstraint.constant + imageWidth + d;
        _thirdArrowLeadingConstraint.constant = _secondArrowLeadingConstraint.constant + imageWidth + d;
        _fourthArrowLeadingConstraint.constant = _fifthArrowLeadingConstraint.constant = totalWidth - imageWidth - (100 - value) * mult;
    }
    else if (value > 80 && value <= 100){
        
        _firstArrowLeadingConstraint.constant = 0;
        _secondArrowLeadingConstraint.constant = _firstArrowLeadingConstraint.constant + imageWidth + d;
        _thirdArrowLeadingConstraint.constant = _secondArrowLeadingConstraint.constant + imageWidth + d;
        _fourthArrowLeadingConstraint.constant = _thirdArrowLeadingConstraint.constant + imageWidth + d;
        _fifthArrowLeadingConstraint.constant = totalWidth - imageWidth - (100 - value) * mult;
    }
    
    // Animate the view
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.05 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    // Reset the view when the user remove finger
    if (isFingerRemoved) {
        for (UIImageView *arrowImage in _greyArrowImageViews) {
            [arrowImage setHidden:NO];
        }
        [_sliderView setBackgroundColor:[UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0]];
    } else {
        if (![[_greyArrowImageViews objectAtIndex:0] isHidden]) {
            [_sliderView setBackgroundColor:[UIColor colorWithRed:12.0/255.0 green:55.0/255.0 blue:123.0/255.0 alpha:1.0]];
            for (UIImageView * arrowImage in _greyArrowImageViews) {
                [arrowImage setHidden:YES];
            }
        }
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    __weak __typeof(self) wself = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            if (IS_IPAD) {
                sself->arrowWidthMultiplier = [sself calculateArrowWidthMultiplier];
                [sself changeSliderToPosition:sself->currentSliderValue isFingerRemoved:sself->isFingerRemoved];
            }
        }
    } completion:nil];
}

/*!
 *  @method calculateArrowWidthMultiplier
 *
 *  @discussion Method to calculate the factor by which the arrow should be moved
 *
 */
-(float) calculateArrowWidthMultiplier {
    // Multiplier is different for Ipad since the image size is different
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        _sliderViewHeightConstraint.constant = sliderViewFrameHeight * 2;
        _firstArrowWidthConstraint.constant = self.view.frame.size.width / 5;
        [self.view layoutIfNeeded];
    }
    float multiplier = self.view.frame.size.width / 100;
    return multiplier;
}

@end
