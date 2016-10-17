//
//  VehicleCostView.h
//  Cabify Challenge
//
//  Created by Francisco Cuenca Montilla on 16/10/16.
//  Copyright © 2016 Francisco Cuenca Montilla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VehicleCabify.h"

/*!
 *  VehicleCostViewCell
 *
 *  Discussion:
 *    Cell representing service Cabify
 */
@interface VehicleCostViewCell : UICollectionViewCell

/*
 * @brief Vehicle/Service to represent
 */
@property (strong, nonatomic) VehicleCabify *vehicle;

@end
