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

#import "LoggerViewController.h"
#import "LoggerHandler.h"
#import "Constants.h"
#import "UIView+Toast.h"
#import "CoreDataHandler.h"
#import "Utilities.h"
#import "UIAlertController+Additions.h"

/*!
 *  @class LoggerViewController
 *
 *  @discussion Class to handle the operations related to logger
 *
 */
@interface LoggerViewController () <AlertControllerDelegate>
{
    NSArray *dateHistory;
    UIAlertController *historyListActionSheet;
    IBOutlet UIButton *historyButton;
    CoreDataHandler *logDataHandler;
}

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;

@end

@implementation LoggerViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    if (!logDataHandler) {
        logDataHandler = [[CoreDataHandler alloc] init];
    }
    
    [[super navBarTitleLabel] setText:DATA_LOGGER];
    [self initLoggerTextView:[[LoggerHandler logManager] getTodayLogData]];
    [[LoggerHandler logManager] deleteOldLogData];
    
    [self initHistoryList];
    
    if (self.loggerTextView.text.length > 0) {
        NSRange initialRange = NSMakeRange(0, 1);
        [self.loggerTextView scrollRangeToVisible:initialRange];
    }
    [self showToastWithLatestLoggedTime];
}

/*!
 *  @method initHistoryList
 *
 *  @discussion Method to initialize array with last seven days data
 *
 */
-(void)initHistoryList {
    dateHistory = [[[logDataHandler getLogDates] reverseObjectEnumerator] allObjects];
    if ([[LoggerHandler logManager] getTodayLogData].count > 0) {
        _currentLogFileName = [NSString stringWithFormat:@"%@.txt", [dateHistory objectAtIndex:0]];
    } else {
        _currentLogFileName = [NSString stringWithFormat:@"%@.txt", [Utilities getTodayDateString]];
    }
    _fileNameLabel.text = _currentLogFileName;
}

/*!
 *  @method initLoggerTextView:
 *
 *  @discussion Method to display the data logged in a day
 *
 */
-(void)initLoggerTextView:(NSArray *)logArray
{
    self.loggerTextView.text =[[[[[[[NSString stringWithFormat:@"%@",logArray] stringByReplacingOccurrencesOfString:@"(" withString:@""]stringByReplacingOccurrencesOfString:@")" withString:@""]stringByReplacingOccurrencesOfString:@"\"" withString:@""]stringByReplacingOccurrencesOfString:@"," withString:@""]stringByReplacingOccurrencesOfString:DATE_SEPARATOR withString:@" , "] stringByReplacingOccurrencesOfString:DATA_SEPERATOR withString:@","];
}

#pragma mark - History Listing

/*!
 *  @method onHistoryTouched:
 *
 *  @discussion Method to handle history button touch
 *
 */
- (IBAction)onHistoryTouched:(id)sender
{
    [self showActionSheetForSender:sender];
}

/*!
 * @method showActionSheetForSender:
 *
 * @discussion Method to initialize the selection options while clicking on the history button
 *
 * @param sender <#sender description#>
 */
-(void)showActionSheetForSender:(id)sender {
    historyListActionSheet = nil;
    historyListActionSheet = [UIAlertController actionSheetWithTitle:[sender title] sourceView:sender sourceRect:[sender bounds] delegate:self cancelButtonTitle:OPT_CANCEL destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    if ([dateHistory count]) {
        if ([[LoggerHandler logManager] getTodayLogData].count == 0) {
            [historyListActionSheet addOtherButtonWithTitle:[NSString stringWithFormat:@"%@.txt", [Utilities getTodayDateString]]];
        }
        for(NSString *date in dateHistory) {
            [historyListActionSheet addOtherButtonWithTitle:[NSString stringWithFormat:@"%@.txt", date]];
        }
    } else {
        [historyListActionSheet addOtherButtonWithTitle:[NSString stringWithFormat:@"%@.txt", [Utilities getTodayDateString]]];
    }
    [historyListActionSheet presentInParent:self];
}

/*!
 *  @method alertController:clickedButtonAtIndex:
 *
 *  @discussion Method to handle the date selection in history.The view will be automatically dismissed after this call returns.
 *
 */
- (void)alertController:(nonnull UIAlertController *)alertController clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex != alertController.cancelButtonIndex ) { // other than CANCEL button
        if ([dateHistory count]) { // history available
            if ([[LoggerHandler logManager] getTodayLogData].count == 0) { // no today's history
                if (buttonIndex == alertController.firstOtherButtonIndex) { // first LOG button
                    _currentLogFileName = [NSString stringWithFormat:@"%@.txt",[Utilities getTodayDateString]];
                    _fileNameLabel.text = _currentLogFileName;
                    [self initLoggerTextView:[[LoggerHandler logManager] getTodayLogData]];
                } else { // 2+ LOG button
                    [self initLoggerTextView:[logDataHandler getLogEventsForDate:[dateHistory objectAtIndex:(buttonIndex - alertController.firstOtherButtonIndex - 1)]]];
                    _currentLogFileName = [NSString stringWithFormat:@"%@.txt", [dateHistory objectAtIndex:(buttonIndex - alertController.firstOtherButtonIndex - 1)]];
                    _fileNameLabel.text = _currentLogFileName;
                }
            } else { // today's history available
                [self initLoggerTextView:[logDataHandler getLogEventsForDate:[dateHistory objectAtIndex:(buttonIndex - alertController.firstOtherButtonIndex)]]];
                _currentLogFileName = [NSString stringWithFormat:@"%@.txt", [dateHistory objectAtIndex:(buttonIndex - alertController.firstOtherButtonIndex)]];
                _fileNameLabel.text = _currentLogFileName;
            }
        } else { // no history
            _currentLogFileName = [NSString stringWithFormat:@"%@.txt",[Utilities getTodayDateString]];
            _fileNameLabel.text = _currentLogFileName;
        }
    }
    historyListActionSheet = nil;
}

/*!
 *  @method showToastWithLatestLoggedTime
 *
 *  @discussion Method to show the user the last logged time
 *
 */
-(void) showToastWithLatestLoggedTime
{
    NSArray *stringArray = [[[[LoggerHandler logManager] getTodayLogData] lastObject] componentsSeparatedByString:DATE_SEPARATOR];
    if([stringArray count])
    {
        NSString *lastItem = [[stringArray firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        lastItem  = [[[lastItem stringByReplacingOccurrencesOfString:@"[" withString:@""] stringByReplacingOccurrencesOfString:@"]" withString:@""] stringByReplacingOccurrencesOfString:@"|" withString:@" "];
        
        [self.view makeToast:[NSString stringWithFormat:@"%@ %@",LOCALIZEDSTRING(@"loggerToastMessage"),lastItem]];
    }
    else
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@ %@ %@",LOCALIZEDSTRING(@"loggerToastMessage"),[Utilities getTodayDateString],[Utilities getTodayTimeString]]];
    }
}

/*!
 *  @method scrollToDownButtonClicked:
 *
 *  @discussion Method to handle the button click
 *
 */
- (IBAction)scrollToDownButtonClicked:(UIButton *)sender {
    [self scrollTextViewToBottom:self.loggerTextView];
}

/*!
 *  @method scrollTextViewToBottom :
 *
 *  @discussion Method to scroll the text view to the bottom
 *
 */
-(void)scrollTextViewToBottom:(UITextView *)textView {
    if(textView.text.length > 0 ) {
        NSRange bottom = NSMakeRange(textView.text.length -1, 1);
        [textView scrollRangeToVisible:bottom];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    __weak __typeof(self) wself = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        __strong __typeof(self) sself = wself;
        if (sself) {
            if (sself->historyListActionSheet) {
                [sself->historyListActionSheet dismissViewControllerAnimated:NO completion:nil];
                [sself showActionSheetForSender:sself->historyButton];
            }
        }
    } completion:nil];
}

@end
