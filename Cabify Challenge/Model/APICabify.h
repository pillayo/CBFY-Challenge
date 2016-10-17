//
//  APICabify.h
//  Cabify Challenge
//
//  Created by Francisco Cuenca Montilla on 16/10/16.
//  Copyright © 2016 Francisco Cuenca Montilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@class RACSignal;

/*!
 *  APICabify
 *
 *  Discussion:
 *    Manages methods to connect with API Cabify
 */
@interface APICabify : NSObject

/*
 * @discussion To get an estimate, start and end points need to be provided.
 * @param start Coordinate with start point
 * @param end Coordinate with end point
 * @return Reactive Signal for asynchronous call
 */
+ (RACSignal *)getEstimateWithStart:(CLLocationCoordinate2D)start andEnd:(CLLocationCoordinate2D)end;
+ (RACSignal *)getImage:(NSURL *)imageUrl;

@end
