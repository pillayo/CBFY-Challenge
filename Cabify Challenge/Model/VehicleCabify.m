//
//  VehicleCabify.m
//  Cabify Challenge
//
//  Created by Francisco Cuenca Montilla on 16/10/16.
//  Copyright © 2016 Francisco Cuenca Montilla. All rights reserved.
//

#import "VehicleCabify.h"

@implementation VehicleCabify

#pragma mark - JSON to Objective-C Properties Mapping

// Map the Objective-C properties to their respective JSON keys.
+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"id": @"vehicle_type._id",
             @"name": @"vehicle_type.name",
             @"icon": @"vehicle_type.icons.regular",
             @"price": @"price_formatted"};
}

+ (NSValueTransformer *)iconJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;        
    
    return self;
}

+(NSArray *)vehiclesFromArrayJSON:(NSArray *)vehiclesJSON{
    NSMutableArray *vehicles = [[NSMutableArray alloc] init];
    for (NSDictionary *vehicleJson in vehiclesJSON){        
        VehicleCabify *vehicle = [MTLJSONAdapter modelOfClass:VehicleCabify.class fromJSONDictionary:vehicleJson error:nil];
        [vehicles addObject:vehicle];
    }
    return vehicles;
    
}


@end
