//
//  TwitterList+Twitter.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "TwitterList+Twitter.h"
#import "TwitterUser+Twitter.h"
#import "TwitterAPI.h"

#import "FortuneBook.h"
#import "FortuneBook+Twitter.h"

@implementation TwitterList (Twitter)

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

+ (TwitterList *)listWithTwitterAccount:(NSDictionary *) jsonList
                                members:(NSDictionary *) jsonMember
                 inManagedObjectContext:(NSManagedObjectContext *)context
{
    TwitterList *list = nil;
    NSString *screen_name = [jsonList valueForKeyPath:@"user.screen_name"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TwitterList"];
    NSString *twitterListTitle = [jsonList objectForKey:@"slug"];
    request.predicate = [NSPredicate predicateWithFormat:@"ownername = %@ AND title = %@", screen_name, twitterListTitle];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        list = [NSEntityDescription insertNewObjectForEntityForName:@"TwitterList" inManagedObjectContext:context];
        list.title = twitterListTitle;
        list.descriptions = [jsonList objectForKey:@"description"];
        list.mode = [jsonList objectForKey:@"mode"];
        list.ownername = screen_name;
        
        
        NSMutableSet *users = [[NSMutableSet alloc] initWithObjects: nil];
        for (NSDictionary *jsonUser in jsonMember){
            NSLog(@"Member:%@", [jsonUser objectForKey:@"screen_name"]);

            TwitterUser *user = [TwitterUser listWithTwitterUser:jsonUser inManagedObjectContext:context];
            if( user ){
                [users addObject:user];
            }
        }
        list.users = users;
        FortuneBook *book = [FortuneBook bookFromTwitter:jsonList inManagedObjectContext:context];
        list.book = book;
        
        NSLog(@"List: %@ owned by %@", list.title, list.ownername);
    } else {
        list = [matches lastObject];
    }
    
    return list;
    
}

@end
