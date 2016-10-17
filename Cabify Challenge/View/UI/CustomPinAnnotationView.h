//
//  CustomPinAnnotationView.h
//  Cabify Challenge
//
//  Created by Francisco Cuenca Montilla on 16/10/16.
//  Copyright © 2016 Francisco Cuenca Montilla. All rights reserved.
//

#import <MapKit/MapKit.h>

/*!
 *  CustomPinAnnotationView
 *
 *  Discussion:
 *    Custom pin with image
 */
@interface CustomPinAnnotationView : MKAnnotationView{
    UIImageView *imageView;
}

/*
 * @brief Custom pin Image
 */
@property (nonatomic, strong) UIImageView *imageView;


@end
