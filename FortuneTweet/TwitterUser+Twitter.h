//
//  TwitterUser+Twitter.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "TwitterUser.h"

@interface TwitterUser (Twitter)
+ (TwitterUser *) listWithTwitterUser:(NSDictionary *) json
                 inManagedObjectContext:(NSManagedObjectContext *)context;

+ (TwitterUser *) tweetWithTwitterUser:(NSDictionary *) json
               inManagedObjectContext:(NSManagedObjectContext *)context;

@end
