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

#import <QuartzCore/QuartzCore.h>
#import "FirmwareFileSelectionViewController.h"
#import "Utilities.h"
#import "MRHexKeyboard.h"
#import "NSString+hex.h"
#import "UIAlertController+Additions.h"

#define BACK_BUTTON_IMAGE       @"backButton"

#define CHECKBOX_BUTTON_TAG     15
#define FILENAME_LABEL_TAG      25
#define ACTIVITY_INDICATOR_TAG  35

#define NO_CHANGE   @"No change"
#define IMAGE1      @"Image 1"
#define IMAGE2      @"Image 2"

#define SECURITY_KEY_WARNING_TITLE_KEY          @"BootloaderSecurityKeyWarningTitle"
#define SECURITY_KEY_WARNING_MESSAGE_KEY        @"BootloaderSecurityKeyWarningMessage"

#define VISIBLE_ROW_HEIGHT  65.0f
#define HIDDEN_ROW_HEIGHT   0.0f

/*!
 *  @class FirmwareFileSelectionViewController
 *
 *  @discussion Class to handle the firmware file selection
 *
 */
@interface FirmwareFileSelectionViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    __weak IBOutlet UITableView *fileListTable;
    __weak IBOutlet UILabel *headerLabel;
    __weak IBOutlet UIButton *upgradeButton;
    __weak IBOutlet UISwitch *securityKeySwitch;
    __weak IBOutlet UITextField *securityKeyTextField;
    __weak IBOutlet UIView *activeAppView;
    __weak IBOutlet NSLayoutConstraint *activeAppViewHeightConstraint;
    __weak IBOutlet UIButton *activeAppButton;
    NSMutableArray *selectedFileList;
    NSArray *fileList;
    BOOL isFileSearchFinished, stackFileSelected;
    MRHexKeyboard *hexKeyboard;
    ActiveApp activeApp;
    NSData *securityKey;
}

@end

@implementation FirmwareFileSelectionViewController

/*!
 *  @method setActiveApp
 *
 *  @discussion For dual-app bootloader only: set Active Applcation ID to either No Change or Image1 or Image2.
 *
 */
- (void) setActiveApp:(ActiveApp)activeApp {
    self->activeApp = activeApp;
    switch(activeApp) {
        case NoChange: {
            [activeAppButton setTitle:NO_CHANGE forState:UIControlStateNormal];
            break;
        }
        case Image1: {
            [activeAppButton setTitle:IMAGE1 forState:UIControlStateNormal];
            break;
        }
        case Image2: {
            [activeAppButton setTitle:IMAGE2 forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self setActiveApp:NoChange];
    [securityKeyTextField setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[super navBarTitleLabel] setText:FIRMWARE_UPGRADE];
    
    isFileSearchFinished = NO;
    stackFileSelected = NO;
    selectedFileList = [NSMutableArray new];
    __weak __typeof(self) wself = self;
    [self findFirmwareFilesWithCompletionBlock:^(NSArray *fileListArray) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            sself->fileList = [[NSArray alloc] initWithArray:fileListArray];
            sself->isFileSearchFinished = YES;
            [sself->fileListTable reloadData];
        }
    }];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_BUTTON_IMAGE] landscapeImagePhone:[UIImage imageNamed:BACK_BUTTON_IMAGE] style:UIBarButtonItemStyleDone target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.leftBarButtonItem.imageInsets = UIEdgeInsetsMake(0, -8, 0, 0);
    
    //UIKeyboardDidHideNotification when keyboard is fully hidden
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*!
 *  @method initiateView
 *
 *  @discussion Method - Setting the view initially or resets it into inital mode when required.
 *
 */
- (void)initView
{
    if (_upgradeMode == app_stack_combined) {
        activeAppView.hidden = YES;
        activeAppViewHeightConstraint.constant = 0;
    }
    fileListTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if (_upgradeMode == app_stack_separate) {
        headerLabel.text = LOCALIZEDSTRING(@"selectStackfile");
        [upgradeButton setTitle:UPGRADE_BTN_TITLE_NEXT forState:UIControlStateNormal];
    } else {
        headerLabel.text = LOCALIZEDSTRING(@"selectFirmwareFile");
        [upgradeButton setTitle:UPGRADE_BTN_TITLE_UPGRADE forState:UIControlStateNormal];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    __weak __typeof(self) wself = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            if (IS_IPAD) {
                [sself initView];
                if (sself->hexKeyboard) {
                    if (sself->hexKeyboard.orientation == UIDeviceOrientationFaceUp  && sself->hexKeyboard.isPresent) {
                        sself->hexKeyboard.orientation = [UIDevice currentDevice].orientation;
                    }
                    if ([UIDevice currentDevice].orientation != UIDeviceOrientationFaceUp && sself->hexKeyboard.orientation != [UIDevice currentDevice].orientation && sself->hexKeyboard.isPresent) {
                        [sself->hexKeyboard changeViewFrameSizeToFrame:CGRectMake(0, 0, sself.view.frame.size.width, KEYBOARD_HEIGHT)];
                        sself->hexKeyboard.orientation = [UIDevice currentDevice].orientation;
                    }
                }
            }
        }
    } completion:nil];
}

#pragma mark - Button Events

/*!
 *  @method securityKeySwitchAction:
 *
 *  @discussion Enables/disables the SecurityKeyTextField
 */
- (IBAction)securityKeySwitchAction:(id)sender {
    BOOL enabled = ((UISwitch *) sender).on;
    [securityKeyTextField setEnabled:enabled];
    if (enabled) {
        [securityKeyTextField becomeFirstResponder];
    }
}

/*!
 *  @method activeAppButtonAction:
 *
 *  @discussion Displays selector of active application in Dual Application Bootloader project
 */
- (IBAction)activeAppButtonAction:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Set active application:" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *noChange = [UIAlertAction actionWithTitle:NO_CHANGE style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self setActiveApp:NoChange];
    }];
    UIAlertAction *image1 = [UIAlertAction actionWithTitle:IMAGE1 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self setActiveApp:Image1];
    }];
    UIAlertAction *image2 = [UIAlertAction actionWithTitle:IMAGE2 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self setActiveApp:Image2];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    [alert addAction:noChange];
    [alert addAction:image1];
    [alert addAction:image2];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/*!
 *  @method upgradeBtnTouched
 *
 *  @discussion Method - Button action method for sending selected files to OTAHomeVC
 *
 */
- (IBAction)upgradeBtnTouched:(UIButton *)sender {
    if (securityKeySwitch.on && nil == securityKey) {
        [[UIAlertController alertWithTitle:LOCALIZEDSTRING(SECURITY_KEY_WARNING_TITLE_KEY) message:LOCALIZEDSTRING(SECURITY_KEY_WARNING_MESSAGE_KEY)] presentInParent:nil];
        return;
    }
    if (app_stack_separate == _upgradeMode) {
        if ([upgradeButton.titleLabel.text isEqualToString:UPGRADE_BTN_TITLE_NEXT]) {
            if (0 == selectedFileList.count) {
                [[UIAlertController alertWithTitle:APP_NAME message:LOCALIZEDSTRING(@"selectStackFileToProceed")] presentInParent:nil];
                return;
            }
            stackFileSelected = YES;
            headerLabel.text = LOCALIZEDSTRING(@"selectApplicationFile");
            [upgradeButton setTitle:UPGRADE_BTN_TITLE_UPGRADE forState:UIControlStateNormal];
            [fileListTable reloadData];
        } else {
            if (selectedFileList.count < 2) {
                [[UIAlertController alertWithTitle:APP_NAME message:LOCALIZEDSTRING(@"selectApplicationFileToProceed")] presentInParent:nil];
                return;
            }
            [self.navigationController popViewControllerAnimated:YES];
            [self.delegate firmwareFilesSelected:selectedFileList upgradeMode:_upgradeMode securityKey:securityKey activeApp:activeApp];
        }
    } else {
        if (selectedFileList.count == 0) {
            if (app_stack_combined == _upgradeMode) {
                [[UIAlertController alertWithTitle:APP_NAME message:LOCALIZEDSTRING(@"selectSingleFileForUpgrade")] presentInParent:nil];
            } else {
                [[UIAlertController alertWithTitle:APP_NAME message:LOCALIZEDSTRING(@"selectFileForApplicationUpgrade")] presentInParent:nil];
            }
            return;
        }
        [self.navigationController popViewControllerAnimated:YES];
        [self.delegate firmwareFilesSelected:selectedFileList upgradeMode:_upgradeMode securityKey:securityKey activeApp:activeApp];
    }
}

/*!
 *  @method checkBoxButtonClicked:
 *
 *  @discussion Method - Does the same function as table cell selection
 *
 */
- (IBAction)checkBoxButtonClicked:(UIButton *)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:fileListTable];
    NSIndexPath *indexPath = [fileListTable indexPathForRowAtPoint:buttonPosition];
    
    if (isFileSearchFinished && fileList.count > 0) {
        if (!selectedFileList) {
            selectedFileList = [NSMutableArray new];
        }
        
        if(sender.selected) {
            if ([fileListTable cellForRowAtIndexPath:indexPath].tag == selectedFileList.count) {
                [selectedFileList removeObjectAtIndex:[fileListTable cellForRowAtIndexPath:indexPath].tag-1];
            } else {
                [selectedFileList removeObjectAtIndex:[fileListTable cellForRowAtIndexPath:indexPath].tag];
            }
            [fileListTable reloadData];
        } else {
            if (_upgradeMode == app_stack_separate && [upgradeButton.titleLabel.text isEqualToString:UPGRADE_BTN_TITLE_UPGRADE] && selectedFileList.count == 2) {
                
                [selectedFileList removeObjectAtIndex:1];
            } else if ((selectedFileList.count == 1 && _upgradeMode != app_stack_separate) || (_upgradeMode == app_stack_separate  && [upgradeButton.titleLabel.text isEqualToString:UPGRADE_BTN_TITLE_NEXT] && selectedFileList.count == 1)) {
                
                [selectedFileList removeObjectAtIndex:0];
            }
            if (selectedFileList.count < 2) {
                if((_upgradeMode == app_stack_separate && stackFileSelected) || (selectedFileList.count == 0)) {
                    
                    [fileListTable cellForRowAtIndexPath:indexPath].tag = selectedFileList.count;
                    [selectedFileList addObject:[fileList objectAtIndex:indexPath.row]];
                }
            }
            [fileListTable reloadData];
        }
        
        BOOL enabled = NO;
        if (_upgradeMode == app_stack_separate) {
            enabled = stackFileSelected // application file screen
            && !sender.selected // checkbox checked
            && selectedFileList.count == 2; // application file selected
        } else {
            enabled = !sender.selected // checkbox checked
            && selectedFileList.count == 1; // application file selected
        }
        if (enabled) {
            NSUInteger i = selectedFileList.count - 1;
            NSDictionary *fileDict = [selectedFileList objectAtIndex:i];
            NSString *fileName = [fileDict valueForKey:FILE_NAME];
            enabled = [[fileName pathExtension] caseInsensitiveCompare:@"cyacd"] == NSOrderedSame; // cyacd application file
        }
        [self setSecurityKeySectionEnabled:enabled];
        [self setActiveAppSectionEnabled:(enabled && _upgradeMode != app_stack_combined)];
    }
}

/*!
 *  @method setSecurityKeySectionEnabled:
 *
 *  @discussion Enable/disable the Security Key panel.
 *  Security Key is only relevant for CYACD and not for CYACD2 file format.
 *  Hence the Security Key panel will be enabled for CYACD and disabled for CYACD2.
 *
 */
- (void) setSecurityKeySectionEnabled:(BOOL)enabled {
    [securityKeySwitch setEnabled:enabled];
    if (!enabled) {
        [securityKeySwitch setOn:NO];
        // Explicitly invoking the handler for the securityKeySwitch as it is not being invoked automatically here
        [self securityKeySwitchAction:securityKeySwitch];
    }
}

/*!
 *  @method setActiveAppSectionEnabled:
 *
 *  @discussion Enable/disable the Active Application panel.
 *  Active Application is only relevant for CYACD and not for CYACD2 file format.
 *  Hence the Active Application panel will be enabled for CYACD and disabled for CYACD2.
 *
 */
- (void) setActiveAppSectionEnabled:(BOOL)enabled {
    [activeAppButton setEnabled:enabled];
}

/*!
 *  @method backButtonAction
 *
 *  @discussion Method - Custom Nav bar back button action to handle multiple file selection scenario
 *
 */
- (void) backButtonAction
{
    if (_upgradeMode == app_stack_separate && [upgradeButton.titleLabel.text isEqualToString:UPGRADE_BTN_TITLE_UPGRADE])
    {
        if (selectedFileList.count > 1) {
            [selectedFileList removeObjectAtIndex:1];
        }
        stackFileSelected = NO;
        headerLabel.text = LOCALIZEDSTRING(@"selectStackfile");
        [upgradeButton setTitle:UPGRADE_BTN_TITLE_NEXT forState:UIControlStateNormal];
        [fileListTable reloadData];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Read .cyacd Files
/*!
 *  @method findFirmwareFilesWithCompletionBlock
 *
 *  @discussion Method - Searches the document folder of app for .cyacd and .cyacd2 files and lists them in table
 *
 */
- (void)findFirmwareFilesWithCompletionBlock:(void(^)(NSArray *))onComplete
{
    NSMutableArray *fileList = [NSMutableArray new];
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirPath = [documentPaths objectAtIndex:0];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:documentsDirPath error:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension IN %@", [NSArray arrayWithObjects:@"cyacd", @"cyacd2", nil]];
    NSArray *fileNameList = (NSMutableArray *)[dirContents filteredArrayUsingPredicate:predicate];
    
    for (NSString *fileName in fileNameList) {
        NSMutableDictionary *firmwareFile = [NSMutableDictionary new];
        [firmwareFile setValue:fileName forKey:FILE_NAME];
        [firmwareFile setValue:documentsDirPath forKey:FILE_PATH];
        [fileList addObject:firmwareFile];
    }
    if (onComplete) {
        onComplete(fileList);
    }
}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"firmwareFileCell"];
    UIActivityIndicatorView * loadingIndicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:ACTIVITY_INDICATOR_TAG];
    UILabel *fileNameLbl = (UILabel *) [cell.contentView viewWithTag:FILENAME_LABEL_TAG];
    UIButton *checkBoxBtn = (UIButton *) [cell.contentView viewWithTag:CHECKBOX_BUTTON_TAG];
    
    if (!isFileSearchFinished) {
        [loadingIndicator setHidden:NO];
        [checkBoxBtn setHidden:YES];
        [fileNameLbl setHidden:YES];
        [loadingIndicator startAnimating];
    }else{
        [loadingIndicator setHidden:YES];
        [fileNameLbl setHidden:NO];
        if (fileList.count == 0) {
            [checkBoxBtn setHidden:YES];
            fileNameLbl.text = LOCALIZEDSTRING(@"fileNotAvailableMessage");
        }else if (_upgradeMode == app_stack_separate &&
                  [upgradeButton.titleLabel.text isEqualToString:UPGRADE_BTN_TITLE_UPGRADE] &&
                  fileList.count <= 1){
            
            [checkBoxBtn setHidden:YES];
            fileNameLbl.text = LOCALIZEDSTRING(@"fileNotAvailableMessage");
        }else{
            [checkBoxBtn setHidden:NO];
            [checkBoxBtn setSelected:NO];
            
            if (_upgradeMode == app_stack_separate && selectedFileList.count == 1) {
                
                NSString *selectedFileStoragePath = [NSString pathWithComponents:[NSArray arrayWithObjects:[[selectedFileList objectAtIndex:0] valueForKey:FILE_PATH],[[selectedFileList objectAtIndex:0] valueForKey:FILE_NAME], nil]];
                
                NSString *indexPathFileStoragePath = [NSString pathWithComponents:[NSArray arrayWithObjects:[[fileList objectAtIndex:indexPath.row] valueForKey:FILE_PATH],[[fileList objectAtIndex:indexPath.row] valueForKey:FILE_NAME], nil]];
                
                if ([selectedFileStoragePath isEqualToString:indexPathFileStoragePath]) {
                    if (!stackFileSelected) {
                        [checkBoxBtn setSelected:YES];
                    }
                }
            }else if (_upgradeMode == app_stack_separate && selectedFileList.count == 2){
                
                NSString *selectedFileStoragePath = [NSString pathWithComponents:[NSArray arrayWithObjects:[[selectedFileList objectAtIndex:0] valueForKey:FILE_PATH],[[selectedFileList objectAtIndex:1] valueForKey:FILE_NAME], nil]];
                
                NSString *indexPathFileStoragePath = [NSString pathWithComponents:[NSArray arrayWithObjects:[[fileList objectAtIndex:indexPath.row] valueForKey:FILE_PATH],[[fileList objectAtIndex:indexPath.row] valueForKey:FILE_NAME], nil]];
                
                if ([selectedFileStoragePath isEqualToString:indexPathFileStoragePath]) {
                    [checkBoxBtn setSelected:YES];
                }
            }else if (_upgradeMode != app_stack_separate && selectedFileList.count == 1){
                
                NSString *selectedFileStoragePath = [NSString pathWithComponents:[NSArray arrayWithObjects:[[selectedFileList objectAtIndex:0] valueForKey:FILE_PATH],[[selectedFileList objectAtIndex:0] valueForKey:FILE_NAME], nil]];
                
                NSString *indexPathFileStoragePath = [NSString pathWithComponents:[NSArray arrayWithObjects:[[fileList objectAtIndex:indexPath.row] valueForKey:FILE_PATH],[[fileList objectAtIndex:indexPath.row] valueForKey:FILE_NAME], nil]];
                
                if ([selectedFileStoragePath isEqualToString:indexPathFileStoragePath]) {
                    [checkBoxBtn setSelected:YES];
                }
            }
            fileNameLbl.text = [[fileList objectAtIndex:indexPath.row] valueForKey:FILE_NAME];
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!fileList || fileList.count == 0)
    {
        // The value is returned as one to set the "File not available" text in the table. The user must check the count of firmwareFilesListArray before adding values to the cells of table.
        return 1;
    }
    return fileList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_upgradeMode == app_stack_separate && selectedFileList.count >= 1) {
        
        NSString *selectedFilePath = [[selectedFileList objectAtIndex:0] valueForKey:FILE_PATH];
        NSString *selectedFileName = [[selectedFileList objectAtIndex:0] valueForKey:FILE_NAME];
        NSString *selectedFileStoragePath = [NSString pathWithComponents:[NSArray arrayWithObjects:selectedFilePath, selectedFileName, nil]];
        
        NSString *indexFilePath = [[fileList objectAtIndex:indexPath.row] valueForKey:FILE_PATH];
        NSString *indexFileName = [[fileList objectAtIndex:indexPath.row] valueForKey:FILE_NAME];
        NSString *indexPathFileStoragePath = [NSString pathWithComponents:[NSArray arrayWithObjects:indexFilePath, indexFileName, nil]];
        
        if ([selectedFileStoragePath isEqualToString:indexPathFileStoragePath]) {
            if (stackFileSelected) {
                return HIDDEN_ROW_HEIGHT;
            }
        }
    }
    return VISIBLE_ROW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIButton *checkBoxBtn = (UIButton *) [[tableView cellForRowAtIndexPath:indexPath].contentView viewWithTag:CHECKBOX_BUTTON_TAG];
    [self checkBoxButtonClicked:checkBoxBtn];
}

#pragma mark UITextField delegate

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    [self showHexKeyboard];
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *currentString = textField.text;
    NSString *newString = [currentString stringByReplacingCharactersInRange:range withString:string];
    NSString *stripped = [newString stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    stripped = [stripped stringByReplacingOccurrencesOfString:@" " withString:@""];
    BOOL isValidLength = stripped.length <= (SECURITY_KEY_NUM_BYTES * 2);
    return isValidLength;
}

#pragma mark - Utility Methods

/*!
 *  @method showHexKeyboard
 *
 *  @discussion Initializes and shows hex keyboard
 *
 */
-(void)showHexKeyboard {
    if (!hexKeyboard) {
        hexKeyboard = [[MRHexKeyboard alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, KEYBOARD_HEIGHT)];
    } else {
        [hexKeyboard changeViewFrameSizeToFrame:CGRectMake(0, 0, self.view.frame.size.width, KEYBOARD_HEIGHT)];
    }
    securityKeyTextField.inputView = [hexKeyboard initWithTextField:securityKeyTextField];
    hexKeyboard.orientation = [UIDevice currentDevice].orientation;
    hexKeyboard.isPresent = YES;
    [self addDoneButton];
}

/*!
 *  @method onKeyboardHide
 *
 *  @discussion Invoked upon hiding the keyboard.
 */
-(void)onKeyboardHide:(NSNotification *)notification
{
    if (notification.name == UIKeyboardDidHideNotification) {
        if (securityKey == nil) {
            [[UIAlertController alertWithTitle:LOCALIZEDSTRING(SECURITY_KEY_WARNING_TITLE_KEY) message:LOCALIZEDSTRING(SECURITY_KEY_WARNING_MESSAGE_KEY)] presentInParent:nil];
        }
    }
}

/*!
 *  @method addDoneButton:
 *
 *  @discussion Adds Done button on top of the keyboard when displayed
 *
 */
- (void)addDoneButton {
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem * flexibleSpaceItem= [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                          target:nil action:nil];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                 target:self action:@selector(doneButtonPressed)];
    keyboardToolbar.items = @[flexibleSpaceItem, doneItem];
    securityKeyTextField.inputAccessoryView = keyboardToolbar;
}

/*!
 *  @method doneButtonPressed
 *
 *  @discussion Handler for the keyboard's Done button
 *
 */
- (void)doneButtonPressed {
    [securityKeyTextField resignFirstResponder];
    [self.view endEditing:YES];
    
    //Apply padding with 0 if necessary
    securityKeyTextField.text = [securityKeyTextField.text decoratedHexStringLSB:YES];
    
    NSData *data = [Utilities dataFromHexString:[securityKeyTextField.text undecoratedHexString]];
    if (data.length != SECURITY_KEY_NUM_BYTES) {
        securityKey = nil;
    } else {
        securityKey = data;
    }
}

@end
