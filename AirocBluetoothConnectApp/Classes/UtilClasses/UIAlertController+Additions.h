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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AlertControllerDelegate <NSObject>
- (void)alertController:(nonnull UIAlertController *)alertController clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@interface UIAlertController (PublicProperties)
@property (nonatomic) NSUInteger tag;
@property(nonatomic, readonly) NSInteger cancelButtonIndex; // -1 means none set. default is -1
@property(nonatomic, readonly) NSInteger destructiveButtonIndex; // -1 means none set. default is -1
@property(nonatomic, readonly) NSInteger firstOtherButtonIndex; // -1 if no otherButtonTitles
@property(nonatomic, readonly) NSInteger numberOfOtherButtons;
@end

@interface UIAlertController (Additions)

+ (instancetype)alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message;

+ (instancetype)alertWithTitle:(nullable NSString *)title
                       message:(nullable NSString *)message
                delegate:(nullable id<AlertControllerDelegate>)delegate
             cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *) otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

+ (instancetype)actionSheetWithTitle:(nullable NSString *)title sourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect delegate:(nullable id<AlertControllerDelegate>)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (instancetype)addOtherButtonWithTitle:(NSString *)otherButtonTitle;

- (void)presentInParent:(nullable UIViewController *)parent;

@end

NS_ASSUME_NONNULL_END
