//
//  FrotuneBookTableViewController.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CoreDataTableViewController.h"

@interface FrotuneBookTableViewController : CoreDataTableViewController  <CLLocationManagerDelegate>
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) NSArray *accounts;
@property (nonatomic, retain) CLLocationManager *locationManager;

@end
