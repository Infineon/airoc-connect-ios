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

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

/*!
 *  @property rightMenuButton
 *
 *  @discussion Button that handle right menu display
 *
 */

/*!
 *  @property shareButton
 *
 *  @discussion button that handle share
 *
 */

/*!
*  @property searchButton
*
*  @discussion button that handle search
*
*/
@property (strong,nonatomic) UIButton *rightMenuButton, *shareButton, *searchButton;

/*!
 *  @property navBarTitleLabel
 *
 *  @discussion displays title in each view
 *
 */
@property (strong,nonatomic) UILabel *navBarTitleLabel;

/*!
 *  @property searchBar
 *
 *  @discussion Textfield to enter the the text to search
 *
 */
@property (strong,nonatomic) UISearchBar *searchBar;

/*!
 *  @method saveImage:
 *
 *  @discussion Method to save image to the document path
 *
 */
-(NSURL*)saveImage:(UIImage *)image;

/*!
 *  @Method showActivityPopover:rect
 *
 *  @discussion  Method to show share window
 *
 */
-(void) showActivityPopover:(NSURL *)pathUrl rect:(CGRect)rect excludedActivities:(NSArray *)excludedActivityTypes;

/*!
 *  @Method addSearchButtonToNavBar
 *
 *  @discussion  Method to add search button to navigation bar
 *
 */
-(void) addSearchButtonToNavBar;

/*!
 *  @Method removeSearchButtonFromNavBar
 *
 *  @discussion  Method to remove search button from navigation bar
 *
 */
-(void) removeSearchButtonFromNavBar;

@end
