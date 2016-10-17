//
//  MKMapView+Utils.m
//  Cabify Challenge
//
//  Created by Francisco Cuenca Montilla on 17/10/16.
//  Copyright © 2016 Francisco Cuenca Montilla. All rights reserved.
//

#import "MKMapView+Utils.h"

@implementation MKMapView (Utils)

- (void)centerMapToCoordinate:(CLLocationCoordinate2D)coordinate {
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    region.span = span;
    region.center = coordinate;
    
    [self setRegion:region animated:YES];
    
}

- (void) zoomToFitMapAnnotations
{
    if([self.annotations count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(NSObject<MKAnnotation> *annotation in self.annotations){
        if (![annotation isKindOfClass:[MKUserLocation class]]){
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
            
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
        }
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    if ([self.annotations count] <= 2){
        region.span.latitudeDelta = 0.05f;
        region.span.longitudeDelta = 0.05f;
    } else {
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.8f; // Add a little extra space on the sides
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.6f; // Add a little extra space on the sides
    }
    
    region = [self regionThatFits:region];
    [self setRegion:region animated:YES];
}

@end
