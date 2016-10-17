//
//  AppDelegate.m
//  Cabify Challenge
//
//  Created by Francisco Cuenca Montilla on 14/10/16.
//  Copyright © 2016 Francisco Cuenca Montilla. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "AFNetworking.h"

static int NetworkActivityIndicatorCounter = 0;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(increaseNetworkActivityIndicator) name:notificationkeyIncreaseNetworkActivity object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decreaseNetworkActivityIndicator) name:notificationkeyDecreaseNetworkActivity object:nil];        
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)applicationWillTerminate:(UIApplication *)application {
 
}


- (void) increaseNetworkActivityIndicator
{
    NetworkActivityIndicatorCounter++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NetworkActivityIndicatorCounter > 0;
}

- (void) decreaseNetworkActivityIndicator
{
    NetworkActivityIndicatorCounter--;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NetworkActivityIndicatorCounter > 0;
}



@end
