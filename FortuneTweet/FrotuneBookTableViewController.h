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

@interface FrotuneBookTableViewController : UITableViewController  <CLLocationManagerDelegate>
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) UIManagedDocument *fortuneDatabase;

@end
