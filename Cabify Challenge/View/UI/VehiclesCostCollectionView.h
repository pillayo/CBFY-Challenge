//
//  VehiclesCostCollectionView.h
//  Cabify Challenge
//
//  Created by Francisco Cuenca Montilla on 16/10/16.
//  Copyright © 2016 Francisco Cuenca Montilla. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 *  VehiclesCostCollectionView
 *
 *  Discussion:
 *    Cells collection representing services Cabify
 */
@interface VehiclesCostCollectionView : UIView<UICollectionViewDelegate, UICollectionViewDataSource>

/*
 * @brief Vehicles/Services to represent
 */
@property (strong, nonatomic) NSArray *vehicles;

@end
