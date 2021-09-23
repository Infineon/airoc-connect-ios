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

#import "BaseViewController.h"
#import "MenuViewController.h"
#import "ResourceHandler.h"
#import "Reachability.h"
#import "Constants.h"
#import "AboutView.h"
#import "Utilities.h"
#import "LoggerViewController.h"
#import "ProgressHandler.h"
#import "UIAlertController+Additions.h"

#define VIEW_COMMON_TAG 11111

#define MENU_VIEW_ID       @"MenuViewID"
#define MENU_ICON_IMAGE    @"rightMenuIcon"
#define SHARE_IMAGE        @"share"
#define SEARCH_ICON_IMAGE  @"SearchIcon"
#define VIEW_KEY           @"view"
#define LOGGER_VIEW_ID     @"LoggerViewID"
#define OFFLINE_VIEW_ID    @"OffLineContactUsView"
#define POPOVER_CONTROLLER @"UIPopoverPresentationController"

#define IMAGE_NAME         @"image.jpg"

static NSInteger const kNavButtonWidth = 40;

/*!
 *  @class BaseViewController
 *
 *  @discussion Class that act as a base for all the other view controllers. It initializes the UI and handles all the menu related operations
 *
 */
@interface BaseViewController () <MenuViewControllerDelegate, UISearchBarDelegate>
{
    MenuViewController *rightMenuViewController;
    BOOL isRightMenuPresent, isTitleViewSearchBar;
    AboutView *appDetailsView;
    UIView *offlineContactUsView;
}

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addNavigationBarView];
    [self addRightMenuView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup right menu

/*!
 *  @Method addrightMenuView
 *
 *  @discussion  Add right Menu to the BaseView.
 *
 */
-(void) addRightMenuView
{
    if (!rightMenuViewController) {
        rightMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:MENU_VIEW_ID];
        [self.view addSubview:rightMenuViewController.view];
        [self.view bringSubviewToFront:rightMenuViewController.view];
        
        rightMenuViewController.view.frame = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height+NAV_BAR_HEIGHT,
                                                        self.view.frame.size.width, self.view.frame.size.height - NAV_BAR_HEIGHT);
        rightMenuViewController.delegate = self;
        rightMenuViewController.rightMenuViewWidthConstraint.constant = 0.0f;
        [rightMenuViewController.view layoutIfNeeded];
        rightMenuViewController.view.hidden = YES;
    }
}

#pragma mark - Setup navigation bar

/*!
 *  @Method addNavigationBarView
 *
 *  @discussion  Method to add Custom Navigation bar
 *
 */
-(void) addNavigationBarView
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.backgroundColor = BLUE_COLOR;
    
    CGRect labelFrame = CGRectMake(-5, 0, [[UIScreen mainScreen] bounds].size.width, NAV_BAR_HEIGHT);
    // Add Navbar title label
    _navBarTitleLabel = [[UILabel alloc] initWithFrame:labelFrame];
    _navBarTitleLabel.backgroundColor = [UIColor clearColor];
    _navBarTitleLabel.textAlignment = NSTextAlignmentLeft;
    _navBarTitleLabel.textColor = [UIColor whiteColor];
    _navBarTitleLabel.text = @"";
    
    // Add NavBar buttons
    _rightMenuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kNavButtonWidth, NAV_BAR_HEIGHT)];
    [_rightMenuButton setImage:[UIImage imageNamed:MENU_ICON_IMAGE] forState:UIControlStateNormal];
    [_rightMenuButton addTarget:self action:@selector(rightMenuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kNavButtonWidth, NAV_BAR_HEIGHT)];
    [_shareButton setImage:[UIImage imageNamed:SHARE_IMAGE] forState:UIControlStateNormal];
    [_shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = _navBarTitleLabel;
    isTitleViewSearchBar = NO;
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithCustomView:_rightMenuButton],[[UIBarButtonItem alloc] initWithCustomView:_shareButton], nil];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
}

/*!
 *  @Method addSearchButtonToNavBar
 *
 *  @discussion  Method to add search button to navigation bar
 *
 */
-(void) addSearchButtonToNavBar
{
    _searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kNavButtonWidth, NAV_BAR_HEIGHT)];
    [_searchButton setImage:[UIImage imageNamed:SEARCH_ICON_IMAGE] forState:UIControlStateNormal];
    [_searchButton addTarget:self action:@selector(replaceNavBarTitleWithSearchBar) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithCustomView:_rightMenuButton],[[UIBarButtonItem alloc] initWithCustomView:_shareButton],[[UIBarButtonItem alloc] initWithCustomView:_searchButton], nil];
    
    CGRect titleFrame = CGRectMake(-5, 0, [[UIScreen mainScreen] bounds].size.width, NAV_BAR_HEIGHT);
    self.navBarTitleLabel.frame = titleFrame;
    self.navigationItem.titleView = _navBarTitleLabel;
    isTitleViewSearchBar = NO;
}

/*!
 *  @Method removeSearchButtonFromNavBar
 *
 *  @discussion  Method to remove search button from navigation bar
 *
 */
-(void) removeSearchButtonFromNavBar
{
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithCustomView:_rightMenuButton],[[UIBarButtonItem alloc] initWithCustomView:_shareButton], nil];
}

/*!
 *  @Method replaceNavBarTitleWithSearchBar
 *
 *  @discussion  Method to replace the titl with search bar
 *
 */
-(void) replaceNavBarTitleWithSearchBar
{
    _searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kNavButtonWidth, NAV_BAR_HEIGHT)];
    [_searchButton setImage:[UIImage imageNamed:SEARCH_ICON_IMAGE] forState:UIControlStateNormal];
    [_searchButton addTarget:self action:@selector(addSearchButtonToNavBar) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithCustomView:_rightMenuButton],[[UIBarButtonItem alloc] initWithCustomView:_shareButton],[[UIBarButtonItem alloc] initWithCustomView:_searchButton], nil];
    
    _searchBar = [UISearchBar new];
    _searchBar.delegate = self;
    _searchBar.tintColor = BLUE_COLOR; // Cursor color
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchBar.returnKeyType = UIReturnKeyDone;
    if (@available(iOS 13.0, *)) {
        // Preserving pre iOS 13 L&F
        _searchBar.searchTextField.backgroundColor = [UIColor whiteColor];
    }
    
    self.navigationItem.titleView = _searchBar;
    [_searchBar becomeFirstResponder];
    isTitleViewSearchBar = YES;
}

/*!
 *  @Method addCustomBackButtonToNavBar
 *
 *  @discussion  Method to add custom back button to navigation bar
 *
 */
-(void) addCustomBackButtonToNavBar
{
    UIBarButtonItem * backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_BUTTON_IMAGE] landscapeImagePhone:[UIImage imageNamed:BACK_BUTTON_IMAGE] style:UIBarButtonItemStyleDone target:self action:@selector(showBLEDevices)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.leftBarButtonItem.imageInsets = UIEdgeInsetsMake(0, -5, 0, 0);
}

/*!
 *  @Method removeCustomBackButtonFromNavBar
 *
 *  @discussion  Method to remove custom back button from navigation bar
 *
 */
-(void) removeCustomBackButtonFromNavBar
{
    if (self.navigationItem.leftBarButtonItem != nil) {
        self.navigationItem.leftBarButtonItem  = nil;
    }
}

#pragma mark - Navigation Bar button events

/*!
 *  @method rightMenuButtonClicked:
 *
 *  @discussion Method to show and hide the menu
 *
 */
-(IBAction)rightMenuButtonClicked:(id)sender
{
    // menu button action
    if (!isRightMenuPresent) {
        [self presentRightMenuView];
    } else {
        [self removeRightMenuView];
    }
}

/*!
 *  @method shareButtonClicked:
 *
 *  @discussion Method to handle share button click
 *
 */
-(IBAction)shareButtonClicked:(id)sender
{
    // check whether the present viewcontroller is logger or not.
    if (![self.navBarTitleLabel.text isEqualToString:LOGGER]) {
        [self captureScreen:sender];
    } else {
        // Send the .txt file for logger view controller
        LoggerViewController *loggerVC = [self.navigationController.viewControllers lastObject];
        NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [docsPath stringByAppendingPathComponent:loggerVC.currentLogFileName];
        NSURL *textFileUrl = [NSURL fileURLWithPath:filePath];
        
        NSError *error;
        [loggerVC.loggerTextView.text writeToURL:textFileUrl atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        NSArray *shareExcludedActivitiesArray = @[UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeMessage,UIActivityTypePostToFacebook,UIActivityTypePostToTwitter];
        [self showActivityPopover:textFileUrl rect:[(UIButton *)sender frame] excludedActivities:shareExcludedActivitiesArray];
    }
}

#pragma mark - NavBar button utility methods

/*!
 *  @Method captureScreen
 *
 *  @discussion  Method to capture screen to share
 *
 */
-(void)captureScreen:(id)sender
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions([UIApplication sharedApplication].keyWindow.bounds.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext([UIApplication sharedApplication].keyWindow.bounds.size);
    }
    
    [[UIApplication sharedApplication].keyWindow.rootViewController.view drawViewHierarchyInRect:[UIApplication sharedApplication].keyWindow.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self showActivityPopover:[self saveImage:image] rect:[(UIButton*)sender frame] excludedActivities:nil];
}

/*!
 *  @method saveImage:
 *
 *  @discussion Method to save image to the document path
 *
 */
-(NSURL*)saveImage:(UIImage *)image
{
    UIImage *shareImg=image;
    NSData *compressedImage = UIImageJPEGRepresentation(shareImg, 0.8 );
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imagePath = [docsPath stringByAppendingPathComponent:IMAGE_NAME];
    NSURL *imageUrl     = [NSURL fileURLWithPath:imagePath];
    [compressedImage writeToURL:imageUrl atomically:YES];
    return imageUrl;
}

/*!
 *  @Method showActivityPopover:Rect
 *
 *  @discussion  Method to show share window
 *
 */
-(void)showActivityPopover:(NSURL *)pathUrl rect:(CGRect)rect excludedActivities:(NSArray *)excludedActivityTypes
{
    NSArray *imageToShare=[NSArray arrayWithObjects:SHARE_IMAGE,pathUrl , nil];
    UIActivityViewController *shareAction=[[UIActivityViewController alloc]initWithActivityItems:imageToShare applicationActivities:nil];
    if (NSClassFromString(POPOVER_CONTROLLER))
    {
        shareAction.popoverPresentationController.sourceView = self.parentViewController.view;
        shareAction.popoverPresentationController.sourceRect = rect;
    }
    
    if (excludedActivityTypes != nil)
    {
        shareAction.excludedActivityTypes = excludedActivityTypes;
    }
    else {
        shareAction.excludedActivityTypes=@[UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeMessage];
    }
    
    [self presentViewController:shareAction animated:TRUE completion:nil];
}

#pragma mark - MenuViewController Delegate

/*!
 *  @method presentRightMenuView
 *
 *  @discussion Method to animatedly present the right menu
 *
 */
-(void) presentRightMenuView
{
    [self addSearchButtonToNavBar];
    [self removeSearchButtonFromNavBar];
    rightMenuViewController.view.hidden = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        const UIInterfaceOrientation toOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        const CGFloat mult = toOrientation == UIInterfaceOrientationPortrait ? 0.6 : 0.5;
        rightMenuViewController.rightMenuViewWidthConstraint.constant = rightMenuViewController.view.frame.size.width * mult;
    } else {
        rightMenuViewController.rightMenuViewWidthConstraint.constant = rightMenuViewController.view.frame.size.width - 50;
    }
    __weak __typeof(self) wself = self;
    [UIView animateWithDuration:.5 animations:^{
        __strong __typeof(self) sself = wself;
        if (sself) {
            [sself->rightMenuViewController.view layoutIfNeeded];
        }
    } completion:^(BOOL finished) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            sself->isRightMenuPresent = YES;
            if (sself->rightMenuViewController.rightMenuView.frame.size.width == 0) {
                [sself->rightMenuViewController.view removeFromSuperview];
                sself->rightMenuViewController.rightMenuViewWidthConstraint.constant = 0.0f;
                [sself.view layoutSubviews];
                [sself.view addSubview:sself->rightMenuViewController.view];
                sself->rightMenuViewController.rightMenuViewWidthConstraint.constant = sself->rightMenuViewController.view.frame.size.width - 50;
                [UIView animateWithDuration:0.5 animations:^{
                    [sself->rightMenuViewController.view layoutIfNeeded];
                }];
            }
        }
    }];
}

/*!
 *  @method removeRightMenuView
 *
 *  @discussion Method to animatedly hide the right menu
 *
 */
-(void) removeRightMenuView
{
    rightMenuViewController.rightMenuViewWidthConstraint.constant =0.0f;
    __weak __typeof(self) wself = self;
    [UIView animateWithDuration:0.5 animations:^{
        __strong __typeof(self) sself = wself;
        if (sself) {
            [sself->rightMenuViewController.view layoutIfNeeded];
        }
    } completion:^(BOOL finished) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            sself->isRightMenuPresent = NO;
            sself->rightMenuViewController.view.hidden = YES;
            if ([sself.navBarTitleLabel.text isEqualToString:BLE_DEVICE]) {
                [sself addSearchButtonToNavBar];
            }
        }
    }];
}

/*!
 *  @method showCypressBLEProductsWebPage
 *
 *  @discussion Method to show the web page of Cypress BLE Products
 *
 */
-(void) showCypressBLEProductsWebPage
{
    // Remove other views
    [self removeRightMenuView];
    [self removeLastShowedView];
    
    // Check internet connectivity
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus connectionStatus = [networkReachability currentReachabilityStatus];
    
    if (connectionStatus != NotReachable) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:BLE_PRODUCTS_URL] options:@{} completionHandler:nil];
    } else {
        [[UIAlertController alertWithTitle:APP_NAME message:LOCALIZEDSTRING(@"internetUnavailbleAlert")] presentInParent:nil];
    }
}

/*!
 *  @method showCypressContactWebPage
 *
 *  @discussion Method to show the webpage of Cypress contact webpage
 *
 */
-(void) showCypressContactWebPage
{
    // Remove other views
    [self removeRightMenuView];
    [self removeLastShowedView];
    
    // Check internet connectivity
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus connectionStatus = [networkReachability currentReachabilityStatus];
    
    if (connectionStatus != NotReachable) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:CONTACT_URL] options:@{} completionHandler:nil];
    } else {
        _navBarTitleLabel.text = CONTACT_US;
        
        // Add custom back button
        [self addCustomBackButtonToNavBar];
        
        offlineContactUsView = nil;
        if (!offlineContactUsView) {
            UIViewController * contactUsVC = [self.storyboard instantiateViewControllerWithIdentifier:OFFLINE_VIEW_ID];
            offlineContactUsView = contactUsVC.view;
            offlineContactUsView.frame = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height+NAV_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height);
        }
        [self.view insertSubview:offlineContactUsView belowSubview:rightMenuViewController.view];
        offlineContactUsView.tag = VIEW_COMMON_TAG;
    }
}

/*!
 *  @method showCySmartHomePage
 *
 *  @discussion Method to show cypress home page
 *
 */
-(void) showCypressHomePage
{
    // Remove other views
    [self removeRightMenuView];
    [self removeLastShowedView];
    
    // Check internet connectivity
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus connectionStatus = [networkReachability currentReachabilityStatus];
    
    if (connectionStatus != NotReachable) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:CYPRESS_HOME_URL] options:@{} completionHandler:nil];
    } else {
        [[UIAlertController alertWithTitle:APP_NAME message:LOCALIZEDSTRING(@"internetUnavailbleAlert")] presentInParent:nil];
    }
}

/*!
 *  @method showCypressMobilePage
 *
 *  @discussion Method to show cypress mobile page
 *
 */
-(void) showCypressMobilePage
{
    // Remove other views
    [self removeRightMenuView];
    [self removeLastShowedView];
    
    // Check internet connectivity
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus connectionStatus = [networkReachability currentReachabilityStatus];
    
    if (connectionStatus != NotReachable) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:CYPRESS_MOBILE_URL] options:@{} completionHandler:nil];
    } else {
        [[UIAlertController alertWithTitle:APP_NAME message:LOCALIZEDSTRING(@"internetUnavailbleAlert")] presentInParent:nil];
    }
}

/*!
 *  @method showAboutView
 *
 *  @discussion Method to show the about view
 *
 */
-(void) showAboutView
{
    _navBarTitleLabel.text = ABOUT_US;
    
    // Remove other views
    [self removeRightMenuView];
    [self removeLastShowedView];
    
    // Add custom back button
    [self addCustomBackButtonToNavBar];
    appDetailsView = nil;
    if (!appDetailsView) {
        appDetailsView = [[AboutView alloc] initWithFrame:self.view.frame];
        appDetailsView.tag = VIEW_COMMON_TAG;
    }
    [self.view insertSubview:appDetailsView belowSubview:rightMenuViewController.view];
}

/*!
 *  @method showLoggerView
 *
 *  @discussion Method to show loggerview
 *
 */
-(void)showLoggerView
{
    // Remove other views
    [self removeRightMenuView];
    [self removeLastShowedView];
    
    [_navBarTitleLabel setText:LOGGER];
    if (![[self.navigationController.viewControllers lastObject] isKindOfClass:[LoggerViewController class]]) {
        LoggerViewController *logger = [self.storyboard instantiateViewControllerWithIdentifier:LOGGER_VIEW_ID];
        [self.navigationController pushViewController:logger animated:YES];
    }
}

/*!
 *  @method removeLastShowedView
 *
 *  @discussion Method to remove the last showed view
 *
 */
-(void)removeLastShowedView
{
    UIView *lastView = [self.view viewWithTag:VIEW_COMMON_TAG];
    [lastView removeFromSuperview];
    
    [self removeCustomBackButtonFromNavBar];
}

/*!
 *  @method showBLEDevices
 *
 *  @discussion Method to move to home screen
 *
 */
-(void) showBLEDevices
{
    // Remove other views
    [self removeLastShowedView];
    [self removeRightMenuView];
    [self addSearchButtonToNavBar];
    if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[LoggerViewController class]]) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    
    _navBarTitleLabel.text = DEVICES;
    // Move to home screen
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    __weak __typeof(self) wself = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        __strong __typeof(self) sself = wself;
        if (sself) {
            const UIInterfaceOrientation toOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            const CGFloat mult = toOrientation == UIInterfaceOrientationPortrait ? 0.6 : 0.5;
            if (!sself->rightMenuViewController.view.isHidden) {
                sself->rightMenuViewController.rightMenuViewWidthConstraint.constant = sself->rightMenuViewController.view.frame.size.width * mult;
                
                [sself->rightMenuViewController.view layoutIfNeeded];
            }
            
            //Left aligning the Title View
            if (sself->isTitleViewSearchBar) {
                if (sself.navigationItem.rightBarButtonItems.count > 2) {
                    NSString * searchString = sself.searchBar.text;
                    [sself replaceNavBarTitleWithSearchBar];
                    sself.searchBar.text = searchString;
                }
            } else {
                sself.navBarTitleLabel.frame = CGRectMake(-5, 0, [[UIScreen mainScreen] bounds].size.height, NAV_BAR_HEIGHT);
                sself.navigationItem.titleView = sself.navBarTitleLabel;
            }
        }
    } completion:nil];
}

@end
