//
//  History+CLLocation.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "History+CLLocation.h"

@implementation History (CLLocation)

#define COREDATA_ENTITY_NAME  @"History"

+ (History *)historyWithCLLocation:(CLLocation *)location
                      fortuneTweet:(Fortune*)fortune
            inManagedObjectContext:(NSManagedObjectContext *)context
{
    History *hist = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:COREDATA_ENTITY_NAME];
    // request.predicate = [NSPredicate predicateWithFormat:@"timestamp = %@ ", location.timestamp];
    // NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    // request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    hist = [NSEntityDescription insertNewObjectForEntityForName:COREDATA_ENTITY_NAME inManagedObjectContext:context];
    hist.timestamp = location.timestamp;
    hist.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
    hist.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
    hist.fortune = fortune;
    NSLog(@"Hist[%d] %@, %@", [matches count], hist.latitude, hist.longitude);
    
    return hist;
    
}

@end
