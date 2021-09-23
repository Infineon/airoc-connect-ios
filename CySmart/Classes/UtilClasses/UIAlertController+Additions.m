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

#import <objc/runtime.h>
#import <stdarg.h>
#import "UIAlertController+Additions.h"
#import "Constants.h"

#define TAG_UNDEFINED NSIntegerMin

@interface UIAlertController (PrivateProperties)
@property (nullable, nonatomic, weak) id<AlertControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *buttonIndices;
@end

@implementation UIAlertController (Additions)

+ (instancetype)alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message {
    
    return [UIAlertController alertWithTitle:title message:message delegate:nil cancelButtonTitle:OPT_OK otherButtonTitles:nil, nil];
}

+ (instancetype)alertWithTitle:(nullable NSString *)title
                       message:(nullable NSString *)message
                      delegate:(nullable id <AlertControllerDelegate>)delegate
             cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *) otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    
    va_list args;
    va_start(args, otherButtonTitles);
    UIAlertController *alert = [UIAlertController impl_alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert delegate:delegate cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:nil otherButtonTitles:otherButtonTitles args:args];
    va_end(args);
    
    return alert;
}

+ (instancetype)actionSheetWithTitle:(nullable NSString *)title sourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect delegate:(nullable id<AlertControllerDelegate>)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    
    va_list args;
    va_start(args, otherButtonTitles);
    UIAlertController *actionSheet = [UIAlertController impl_alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet delegate:delegate cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles args:args];
    va_end(args);
    
    actionSheet.modalPresentationStyle = UIModalPresentationPopover;
    actionSheet.popoverPresentationController.sourceView = sourceView;
    actionSheet.popoverPresentationController.sourceRect = sourceRect;
    
    return actionSheet;
}

+ (instancetype)impl_alertControllerWithTitle:(nullable NSString *)title
                                      message:(nullable NSString *)message
                               preferredStyle:(UIAlertControllerStyle)preferredStyle
                                     delegate:(nullable id<AlertControllerDelegate>)delegate
                            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                       destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle
                            otherButtonTitles:(nullable NSString *)otherButtonTitles
                                         args:(va_list)args {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:preferredStyle];
    alertController.tag = TAG_UNDEFINED;
    alertController.delegate = delegate;
    alertController.buttonIndices = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *buttonTitles = [[NSMutableArray alloc] init];
    NSMutableArray *actionStyles = [[NSMutableArray alloc] init];
    
    alertController.buttonIndices[NSStringFromSelector(@selector(cancelButtonIndex))] = [NSNumber numberWithInteger:cancelButtonTitle ? buttonTitles.count : -1];
    if (cancelButtonTitle) {
        [buttonTitles addObject:cancelButtonTitle];
        [actionStyles addObject:[NSNumber numberWithInteger:UIAlertActionStyleCancel]];
    }
    
    alertController.buttonIndices[NSStringFromSelector(@selector(destructiveButtonIndex))] = [NSNumber numberWithInteger:destructiveButtonTitle ? buttonTitles.count : -1];
    if (destructiveButtonTitle) {
        [buttonTitles addObject:destructiveButtonTitle];
        [actionStyles addObject:[NSNumber numberWithInteger:UIAlertActionStyleDestructive]];
    }
    
    alertController.buttonIndices[NSStringFromSelector(@selector(firstOtherButtonIndex))] = [NSNumber numberWithInteger:otherButtonTitles ? buttonTitles.count : -1];
    if (otherButtonTitles) {
        [buttonTitles addObject:otherButtonTitles];
        [actionStyles addObject:[NSNumber numberWithInteger:UIAlertActionStyleDefault]];
        
        NSString *arg = nil;
        while ((arg = va_arg(args, NSString *))) {
            [buttonTitles addObject:arg];
            [actionStyles addObject:[NSNumber numberWithInteger:UIAlertActionStyleDefault]];
        }
    }
    
    __weak UIAlertController *wAlertController = alertController;
    __weak id<AlertControllerDelegate> wDelegate = delegate;
    for (NSUInteger i = 0; i < buttonTitles.count; ++i) {
        NSUInteger actionCount = alertController.actions.count;
        UIAlertAction *action = [UIAlertAction
                                 actionWithTitle:buttonTitles[i]
                                 style:[actionStyles[i] integerValue]
                                 handler:(^(UIAlertAction *action){
            __strong UIAlertController *sAlertController = wAlertController;
            __strong id<AlertControllerDelegate> sDelegate = wDelegate;
            if (sAlertController && sDelegate) {
                [sDelegate alertController:sAlertController clickedButtonAtIndex:actionCount];
            }
        })];
        [alertController addAction:action];
    }
    
    return alertController;
}

- (instancetype)addOtherButtonWithTitle:(NSString *)otherButtonTitle {
    
    NSUInteger actionCount = self.actions.count;
    if (self.firstOtherButtonIndex < 0) {
        self.buttonIndices[NSStringFromSelector(@selector(firstOtherButtonIndex))] = [NSNumber numberWithInteger:actionCount];
    }
    __weak UIAlertController *wSelf = self;
    __weak id<AlertControllerDelegate> wDelegate = self.delegate;
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:otherButtonTitle
                             style:UIAlertActionStyleDefault
                             handler:(^(UIAlertAction *action){
        __strong UIAlertController *sSelf = wSelf;
        __strong id<AlertControllerDelegate> sDelegate = wDelegate;
        if (sSelf && sDelegate) {
            [sDelegate alertController:sSelf clickedButtonAtIndex:actionCount];
        }
    })];
    [self addAction:action];
    
    return self;
}

- (void)presentInParent:(nullable UIViewController *)parent {
    UIViewController *p = parent ? parent : [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [p presentViewController:self animated:YES completion:nil];
}

@end

@implementation UIAlertController (PublicProperties)
@dynamic tag;
@dynamic cancelButtonIndex; // -1 means none set. default is -1
@dynamic destructiveButtonIndex; // -1 means none set. default is -1
@dynamic firstOtherButtonIndex; // -1 if no otherButtonTitles
@dynamic numberOfOtherButtons;

- (void)setTag:(NSUInteger)tag {
    objc_setAssociatedObject(self, @selector(tag), [NSNumber numberWithUnsignedInteger:tag], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSUInteger)tag {
    return [(NSNumber *)objc_getAssociatedObject(self, @selector(tag)) unsignedIntegerValue];
}

- (NSInteger)cancelButtonIndex {
    return [self.buttonIndices[NSStringFromSelector(@selector(cancelButtonIndex))] integerValue];
}

- (NSInteger)destructiveButtonIndex {
    return [self.buttonIndices[NSStringFromSelector(@selector(destructiveButtonIndex))] integerValue];
}

- (NSInteger)firstOtherButtonIndex {
    return [self.buttonIndices[NSStringFromSelector(@selector(firstOtherButtonIndex))] integerValue];
}

- (NSInteger)numberOfOtherButtons {
    NSInteger count = self.actions.count;
    if (self.cancelButtonIndex >= 0)
        --count;
    if (self.destructiveButtonIndex >= 0)
        --count;
    return count;
}
@end

@implementation UIAlertController (PrivateProperties)
@dynamic delegate;
@dynamic buttonIndices;

- (void)setDelegate:(id<AlertControllerDelegate>) delegate {
    __weak id weakObject = delegate;
    id (^block)(void) = ^{ return weakObject; };
    objc_setAssociatedObject(self, @selector(delegate), block, OBJC_ASSOCIATION_COPY);
}
- (id<AlertControllerDelegate>)delegate {
    id (^block)(void) = objc_getAssociatedObject(self, @selector(delegate));
    return (block ? block() : nil);
}

- (void)setButtonIndices:(NSMutableDictionary *) buttonIndices {
    objc_setAssociatedObject(self, @selector(buttonIndices), buttonIndices, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableDictionary *)buttonIndices {
    return objc_getAssociatedObject(self, @selector(buttonIndices));
}
@end
