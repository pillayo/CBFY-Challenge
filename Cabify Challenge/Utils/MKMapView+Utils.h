//
//  MKMapView+Utils.h
//  Cabify Challenge
//
//  Created by Francisco Cuenca Montilla on 17/10/16.
//  Copyright © 2016 Francisco Cuenca Montilla. All rights reserved.
//

#import <MapKit/MapKit.h>

/*!
 *  Utils
 *
 *  Discussion:
 *    MKMapView Category with extra utils methods
 */
@interface MKMapView(Utils)

/*!
 * @discussion Focus region from coordinates
 * @param coordinate center of region
 */
- (void) centerMapToCoordinate:(CLLocationCoordinate2D)coordinate;

/*!
 * @discussion Zoom to show all points that contains a map
 */
- (void) zoomToFitMapAnnotations;

@end
