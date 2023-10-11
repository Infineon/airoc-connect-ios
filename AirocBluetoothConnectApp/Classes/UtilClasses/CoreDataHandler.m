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

#import "CoreDataHandler.h"
#import "AppDelegate.h"
#import "Logger.h"
#import "Constants.h"
#import "Utilities.h"

#define LOGGER_ENTITY    @"Logger"
#define DATE             @"date"

/*!
 *  @class CoreDataHandler
 *
 *  @discussion Class that handles the operations related to coredata
 *
 */
@implementation CoreDataHandler

/*!
 *  @method addLogEvent:date:
 *
 *  @discussion Write log event
 *
 */
-(void) addLogEvent:(NSString *)event date:(NSString *)date {
    AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Logger *entity = [NSEntityDescription insertNewObjectForEntityForName:LOGGER_ENTITY inManagedObjectContext:appDelegate.managedObjectContext];
    entity.date = date;
    entity.event = event;

    NSError *error;
    [appDelegate.managedObjectContext save:&error];
}

/*!
 *  @method getLogEventsForDate:
 *
 *  @discussion Return log records for particular date
 *
 */
-(NSArray *) getLogEventsForDate:(NSString *)date {
    AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *desc = [NSEntityDescription entityForName:LOGGER_ENTITY inManagedObjectContext: appDelegate.managedObjectContext];
    [fetchRequest setEntity:desc];

    // Filtering criteria
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date = %@", date];
    [fetchRequest setPredicate:predicate];

    fetchRequest.returnsObjectsAsFaults = NO;

    NSError *error = nil;
    NSArray *fetchedObjects = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    // Returning only the logged events
    NSMutableArray *events = [[NSMutableArray alloc] init];
    if (error == nil && fetchedObjects != nil) {
        for (Logger *entity in fetchedObjects) {
            [events addObject:entity.event];
        }
    }
    return events;
}

/*!
 *  @method deleteLogEventsForDate:
 *
 *  @discussion Delete log records for particular date
 *
 */
-(void) deleteLogEventsForDate:(NSString *)date {
    AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *desc = [NSEntityDescription entityForName:LOGGER_ENTITY inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:desc];

    // Filtering criteria
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date = %@", date];
    [fetchRequest setPredicate:predicate];

    fetchRequest.returnsObjectsAsFaults = NO;

    NSError *error = nil;
    NSArray *fetchedObjects = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (error == nil && fetchedObjects != nil) {
        for (NSManagedObject *entity in fetchedObjects) {
            [appDelegate.managedObjectContext deleteObject:entity];
        }
    }

    [appDelegate.managedObjectContext save:&error];
}

/*!
 *  @method getLogDates
 *
 *  @discussion Return log record dates in historical order (oldest date is the first)
 *
 */
-(NSArray *) getLogDates {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSEntityDescription *desc = [NSEntityDescription entityForName:LOGGER_ENTITY inManagedObjectContext:appDelegate.managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = desc;

    // All objects in the backing store are implicitly distinct, but two dictionaries can be duplicates.
    // Since you only want distinct names, only ask for the 'name' property.
    fetchRequest.resultType = NSDictionaryResultType;
    fetchRequest.propertiesToFetch= @[DATE];
    fetchRequest.returnsDistinctResults = YES;
    fetchRequest.returnsObjectsAsFaults = NO;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:DATE ascending:YES]];

    NSError *error = nil;
    NSArray *fetchedObjects = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    // Collect log file names from fetch result
    NSMutableArray *logFileNames = [[NSMutableArray alloc] init];
    if (error == nil && fetchedObjects != nil) {
        for (NSDictionary *dict in fetchedObjects) {
            [logFileNames addObject:[dict objectForKey:DATE]];
        }
    }
    
    // Sort the items correctly. Default string sort doesn't work for dates.
    NSArray* result = logFileNames;
    if(logFileNames.count) {
        result = [Utilities sortDates:logFileNames withNewestFirst:false];
    }
    
    // The oldest date is the first
    return result;
}

@end
