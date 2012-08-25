//
//  History+CLLocation.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import "History.h"
#import "Fortune.h"

@interface History (CLLocation)
+ (History *)historyWithCLLocation:(CLLocation *)location
                      fortuneTweet:(Fortune*)fortune
            inManagedObjectContext:(NSManagedObjectContext *)context;

@end
