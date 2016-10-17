//
//  Utils.m
//  Cabify Challenge
//
//  Created by Francisco Cuenca Montilla on 16/10/16.
//  Copyright © 2016 Francisco Cuenca Montilla. All rights reserved.
//

#import "Utils.h"
#import "AFNetworking.h"

@implementation Utils


+ (void)showMessageErrorWithTitle:(NSString *)title andMessage:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}


+ (NSString *)getAddressFromPlacemark:(CLPlacemark *)placemark{
    
    if (placemark.locality == nil){
        return NSLocalizedString(@"errorNoAddress", nil);
    } else {
        NSMutableString *address = [[NSMutableString alloc] init];
        if (placemark.thoroughfare != nil && placemark.thoroughfare.length > 0)
            [address appendString:placemark.thoroughfare];
        if (placemark.subThoroughfare != nil && placemark.subThoroughfare.length > 0)
            [address appendFormat:@", %@", placemark.subThoroughfare];
        [address appendFormat:@", %@", placemark.locality];
        return address;
        
        //[[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        //if (locatedAt == nil) locatedAt = placemark.thoroughfare;
    }
}


+ (BOOL)isNetoworkConnected{
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
}


+ (CGSize)getSccreenSize{
    return [[UIScreen mainScreen] bounds].size;
}


@end
