//
//  TwitterUser+Account.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/30.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "TwitterUser.h"

@interface TwitterUser (Account)
+ (TwitterUser *)accountWithTwitterUser:(NSDictionary *) json
                 inManagedObjectContext:(NSManagedObjectContext *)context;
@end
