//
//  TwitterUser+Account.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/30.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "TwitterUser+Account.h"

/*
 {
 "name": "development",
 "full_name": "@norimasa_nabeta/development",
 "following": false,
 "description": "???????",
 "mode": "public",
 "user": {
 "profile_sidebar_border_color": "DFDFDF",
 "id": 73650741,
 "name": "NorimasaNabeta",
 "is_translator": false,
 "protected": false,
 "contributors_enabled": false,
 "followers_count": 11,
 "id_str": "73650741",
 "statuses_count": 332,
 "following": false,
 "default_profile": false,
 "screen_name": "norimasa_nabeta"
 },
 "id_str": "70372290",
 "member_count": 8,
 "subscriber_count": 0,
 "slug": "development",
 "created_at": "Fri May 11 01:27:24 +0000 2012",
 "uri": "/norimasa_nabeta/development",
 "id": 70372290
 },
 */

@implementation TwitterUser (Account)

+ (TwitterUser *)accountWithTwitterUser:(NSDictionary *) json
              inManagedObjectContext:(NSManagedObjectContext *)context
{
    TwitterUser *user = nil;
    NSString *screen_name = [json valueForKeyPath:@"user.screen_name"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TwitterUser"];
    request.predicate = [NSPredicate predicateWithFormat:@"screenname = %@", screen_name];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"screenname" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
        
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"TwitterUser" inManagedObjectContext:context];
        
        // user.blocked = [json objectForKey:@""];
        // user.followed = [json objectForKey:@""];
        // user.friend = [json objectForKey:@""];
        user.name = [json valueForKeyPath:@"user.name"];
        user.profileimageURL = [json valueForKeyPath:@"user.profile_image_url"];
        user.userid = [json valueForKeyPath:@"user.id_str"];
        user.screenname = screen_name;
        NSLog(@"Account User: %@ ", user.screenname);
    } else {
        user = [matches lastObject];
    }
    
    return user;
    
}

@end
