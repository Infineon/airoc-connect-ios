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

#import "MenuViewController.h"
#import "MenuTableViewCell.h"
#import "Reachability.h"
#import "Constants.h"

#define TABLE_IMAGEVIEW_LEADING_CONSTRAINT_CONSTANT     55.0
#define MENU_TABLE_CELL_IDENTIFIER                      @"menuTableCell"

#define menuItems           [NSArray arrayWithObjects:@"Bluetooth® LE Devices",@"Data Logger",@"Infineon",@"About",nil]
#define menuItemImages      [NSArray arrayWithObjects:@"cypress_BLE_products", @"settings",   @"cypress", @"about",nil]

#define subMenuItems        [NSArray arrayWithObjects:@"Home",@"Products",@"App Website",@"Contact Us",nil]
#define subMenuItemImages   [NSArray arrayWithObjects:@"home",@"products",              @"mobile",     @"contact",   nil]

/*!
 *  @class MenuViewController
 *
 *  @discussion Class to handle the menu related operations 
 *
 */
@interface MenuViewController ()
{
    NSMutableArray *menuItemsMutableArray;
    NSMutableArray *menuItemImagesMutableArray;
    
    BOOL isSubMenuVisible;
}

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    menuItemsMutableArray = [menuItems mutableCopy];
    menuItemImagesMutableArray = [menuItemImages mutableCopy];
    [self tableView:_menuTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - tableView delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return menuItemsMutableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *menuTableCellIdentifier = MENU_TABLE_CELL_IDENTIFIER;
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:menuTableCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[MenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:menuTableCellIdentifier];
    }
    
    NSString *ItemName = [menuItemsMutableArray objectAtIndex:[indexPath row]];
    cell.menuItemLabel.text = ItemName ;
    cell.menuItemImageview.image = [UIImage imageNamed:[menuItemImagesMutableArray objectAtIndex:[indexPath row]]];
    
    if (isSubMenuVisible)
    {
        if ([indexPath row] > 2 && [indexPath row] < 7 && cell.menuItemImageViewLeadingConstraint.constant != TABLE_IMAGEVIEW_LEADING_CONSTRAINT_CONSTANT)
        {
            cell.menuItemImageViewLeadingConstraint.constant += 40;
        }
    }
    return cell;
}

/*!
 *  @method tableView: didSelectRowAtIndexPath:
 *
 *  @discussion Method to handle the selection in menu
 *
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger selectedIndex= [indexPath row];
    switch (selectedIndex)
    {
        case 0:
            // Show the bluetooth devices
            if (_delegate && [_delegate respondsToSelector:@selector(showBLEDevices)])
            {
                [_delegate showBLEDevices];
            }
            break;
        case 1:
            // Show Logger
            if (_delegate && [_delegate respondsToSelector:@selector(showLoggerView)])
            {
                [_delegate showLoggerView];
            }
            break;
        case 2:
            {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(selectedIndex+1, 4)];
                NSArray *indexPathArray =
                    [NSArray arrayWithObjects:
                        [NSIndexPath indexPathForRow:selectedIndex+1 inSection:0],
                        [NSIndexPath indexPathForRow:selectedIndex+2 inSection:0],
                        [NSIndexPath indexPathForRow:selectedIndex+3 inSection:0],
                        [NSIndexPath indexPathForRow:selectedIndex+4 inSection:0],
                        nil
                    ];
                
                if (isSubMenuVisible)
                {
                    isSubMenuVisible = NO;
                    [menuItemsMutableArray removeObjectsAtIndexes:indexSet];
                    [menuItemImagesMutableArray removeObjectsAtIndexes:indexSet];
                    [_menuTableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                }
                else
                {
                    isSubMenuVisible = YES;
                    [menuItemsMutableArray insertObjects:subMenuItems atIndexes:indexSet];
                    [menuItemImagesMutableArray insertObjects:subMenuItemImages atIndexes:indexSet];
                    [_menuTableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationBottom];
                }
            }
            break;
        case 3:
            if (isSubMenuVisible)
            {
                // Show CySmart home
                if (_delegate && [_delegate respondsToSelector:@selector(showCypressHomePage)])
                {
                    [_delegate showCypressHomePage];
                }
            }
            else
            {
                // Show about
                if (_delegate && [_delegate respondsToSelector:@selector(showAboutView)])
                {
                    [_delegate showAboutView];
                }
            }
            break;
        case 4:
            // show the Cypress Products WebPage
            if (_delegate && [_delegate respondsToSelector:@selector(showCypressBLEProductsWebPage)])
            {
                [_delegate showCypressBLEProductsWebPage];
            }
            break;
        case 5:
            // Show mobile
            if (_delegate && [_delegate respondsToSelector:@selector(showCypressMobilePage)])
            {
                [_delegate showCypressMobilePage];
            }
            break;
        case 6:
            // show the Cypress contact WebPage
            if (_delegate && [_delegate respondsToSelector:@selector(showCypressContactWebPage)])
            {
                [_delegate showCypressContactWebPage];
            }
            break;
        case 7:
            // Show about
            if (_delegate && [_delegate respondsToSelector:@selector(showAboutView)])
            {
                [_delegate showAboutView];
            }
            break;
        default:
            break;
    }
    [_menuTableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
