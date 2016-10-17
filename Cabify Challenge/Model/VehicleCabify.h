//
//  VehicleCabify.h
//  Cabify Challenge
//
//  Created by Francisco Cuenca Montilla on 16/10/16.
//  Copyright © 2016 Francisco Cuenca Montilla. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <Foundation/Foundation.h>

/*!
 *  VehicleCabify
 *
 *  Discussion:
 *    Vehicle/Service with cost for a journey
 */
@interface VehicleCabify : MTLModel<MTLJSONSerializing>

/*!
 * @brief Vehicle/Service identifier
 */
@property (nonatomic, strong) NSString *id;

/*!
 * @brief Vehicle/Service name
 */
@property (nonatomic, strong) NSString *name;

/*!
 * @brief Url of Vehicle/Service image
 */
@property (nonatomic, strong) NSURL *icon;

/*!
 * @brief Vehicle/Service price
 */
@property (nonatomic, strong) NSString *price;


/*!
 * @discussion Get array of vehicles
 * @param vehiclesJSON Array of NSDictionary with vehicle info
 * @return Array of vehicles
 */
+(NSArray *)vehiclesFromArrayJSON:(NSArray *)vehiclesJSON;

@end
