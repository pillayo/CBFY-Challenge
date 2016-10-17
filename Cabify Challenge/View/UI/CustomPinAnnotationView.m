//
//  CustomPinAnnotationView.m
//  Cabify Challenge
//
//  Created by Francisco Cuenca Montilla on 16/10/16.
//  Copyright © 2016 Francisco Cuenca Montilla. All rights reserved.
//

#import "CustomPinAnnotationView.h"

@implementation CustomPinAnnotationView

@synthesize imageView;

#define kHeight 57
#define kWidth  37
#define kBorder 5

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
				
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    self.frame = CGRectMake(0, 0, kWidth, kHeight);
    self.backgroundColor = [UIColor clearColor];
		
    imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.frame = CGRectMake(kBorder, 0, 31, 37);
    
    [self addSubview:imageView];
		
	return self;
}



@end
