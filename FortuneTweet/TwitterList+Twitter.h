//
//  TwitterList+Twitter.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "TwitterList.h"
#import <Accounts/Accounts.h>

@interface TwitterList (Twitter)

//+ (TwitterList *)listWithTwitterAccount:(NSDictionary *) json
//                 inManagedObjectContext:(NSManagedObjectContext *)context;
+ (TwitterList *)listWithTwitterAccount:(NSDictionary *) jsonList
                                members:(NSDictionary *) jsonMember
                 inManagedObjectContext:(NSManagedObjectContext *)context;
@end
