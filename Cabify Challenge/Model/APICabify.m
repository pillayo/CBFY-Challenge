//
//  APICabify.m
//  Cabify Challenge
//
//  Created by Francisco Cuenca Montilla on 16/10/16.
//  Copyright © 2016 Francisco Cuenca Montilla. All rights reserved.
//

#import "APICabify.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "AFNetworking.h"
#import "Constants.h"
#import "VehicleCabify.h"

@implementation APICabify

/*
 * @discussion To get an request for estimate call
 * @param parameters body POST for estimate call
 * @return Request for estimate call
 */
+ (NSURLRequest *)requestForEstimate:(NSDictionary *)parameters {
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@/estimate", URLAPICabify] parameters:parameters error:nil];
    [request addValue:@"Content-Type" forHTTPHeaderField:@"application/json"];
    [request addValue:[NSString stringWithFormat:@"Bearer %@",APIKEY] forHTTPHeaderField:@"Authorization"];
    [request addValue:@"en" forHTTPHeaderField:@"Accept-Language"];
    
    return request;    
}

/*
 * @discussion To get an BODY JSON for estimate call
 * @param start Coordinate with start point
 * @param end Coordinate with end point
 * @return NSDictionary with body JSON for estimate call
 */
+(NSDictionary *)parametersGetEstimate:(CLLocationCoordinate2D)start andEnd:(CLLocationCoordinate2D)end{
    NSDictionary *parameters =
    @{@"stops":
          @[ @{@"loc" :@[[NSNumber numberWithDouble:start.latitude], [NSNumber numberWithDouble:start.longitude] ]},
             @{@"loc" : @[[NSNumber numberWithDouble:end.latitude], [NSNumber numberWithDouble:end.longitude] ]}],
      @"start_at": @""};
    return parameters;
}

+ (RACSignal *)getEstimateWithStart:(CLLocationCoordinate2D)start andEnd:(CLLocationCoordinate2D)end{
    
    // 1 - define the errors
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:NSLocalizedString(@"errorComunicationInfo", nil) forKey:NSLocalizedDescriptionKey];
    NSError *invalidResponseError = [NSError errorWithDomain:@"APICabify"
                                                        code:generalError
                                                    userInfo:details];
    
    // 2 - create the signal block
    @weakify(self)
    void (^signalBlock)(RACSubject *subject) = ^(RACSubject *subject) {
        @strongify(self);
        
        // 3 - create the request
        NSDictionary *parameters = [self parametersGetEstimate:start andEnd:end];
        NSURLRequest *request = [self requestForEstimate:parameters];
        
        // 5 - perform the request
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationkeyIncreaseNetworkActivity object:nil];
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                if (isDebugCabify) NSLog(@"Error: %@", error);
                [subject sendError:invalidResponseError];
            } else {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                if (httpResponse.statusCode == 200) {
                    NSArray *vehicles = nil;
                    if (responseObject != nil &&  [responseObject isKindOfClass:[NSArray class]]){
                        vehicles = [VehicleCabify vehiclesFromArrayJSON:responseObject];
                    }
                    [subject sendNext:vehicles];
                    [subject sendCompleted];
                    if (isDebugCabify) NSLog(@"%@",responseObject);
                } else {
                    [subject sendError:invalidResponseError];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationkeyDecreaseNetworkActivity object:nil];
        }];
        [dataTask resume];
    };
    
    RACSignal *signal = [RACSignal startLazilyWithScheduler:[RACScheduler scheduler]
                                                      block:signalBlock];
    
    return signal;
}

+(RACSignal *)getImage:(NSURL *)imageUrl {
    
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground];
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSData *data = [NSData dataWithContentsOfURL:imageUrl];
        UIImage *image = [UIImage imageWithData:data];
        [subscriber sendNext:image];
        [subscriber sendCompleted];
        return nil;
    }] subscribeOn:scheduler];
    
}


@end
