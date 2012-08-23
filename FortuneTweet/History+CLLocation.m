//
//  History+CLLocation.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "History+CLLocation.h"

@implementation History (CLLocation)

+ (History *)historyWithCLLocation:(CLLocation *)location
            inManagedObjectContext:(NSManagedObjectContext *)context
{
    History *hist = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"History"];
    // request.predicate = [NSPredicate predicateWithFormat:@"timestamp = %@ ", location.timestamp];
    // NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    // request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // if (!matches || ([matches count] > 1)) {
        // handle error
    // } else if ([matches count] == 0) {
        hist = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];
        hist.timestamp = location.timestamp;
        hist.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
        hist.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
        NSLog(@"Hist[%d] %@, %@", [matches count], hist.latitude, hist.longitude);
    // } else {
    //     hist = [matches lastObject];
    // }
    
    return hist;
    
}

@end
