//
//  Utils.h
//  Cabify Challenge
//
//  Created by Francisco Cuenca Montilla on 16/10/16.
//  Copyright © 2016 Francisco Cuenca Montilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CLPlacemark.h>

/*!
 *  Utils
 *
 *  Discussion:
 *    Useful tools for use in controllers
 */
@interface Utils : NSObject

/*!
 * @discussion Get a message alert
 * @param title title for alert
 * @param message description for alert
 */
+ (void)showMessageErrorWithTitle:(NSString *)title andMessage:(NSString *)message;

/*!
 * @discussion Get the summay addres description for a placemark
 * @param placemark Complete info address
 * @return string with summary address
 */
+ (NSString *)getAddressFromPlacemark:(CLPlacemark *)placemark;

/*!
 * @discussion Network connection is available
 * @return true if is available, false if not available
 */
+ (BOOL)isNetoworkConnected;

/*!
 * @discussion Get device size
 * @return device size, width and height
 */
+ (CGSize)getSccreenSize;

@end
