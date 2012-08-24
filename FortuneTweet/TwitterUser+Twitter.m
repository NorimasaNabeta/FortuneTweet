//
//  TwitterUser+Twitter.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "TwitterUser+Twitter.h"

@implementation TwitterUser (Twitter)

/*
 {
 "profile_sidebar_border_color": "b09a90",
>> "id": 17584067,
 "friends_count": 91,
 "time_zone": "Tokyo",
 "notifications": false,
 "url": "http://www.geocities.jp/yzru1108/",
 "verified": false,
 "created_at": "Mon Nov 24 03:09:35 +0000 2008",
 "profile_background_tile": false,
 "listed_count": 708,
 "profile_sidebar_fill_color": "e6d5b3",
 "utc_offset": 32400,
>>  "name": "?????",
 "is_translator": false,
 "protected": false,
 "contributors_enabled": false,
 "followers_count": 8131,
 "profile_background_color": "5ba1cf",
 "location": "?",
 "default_profile_image": false,
 "lang": "ja",
 "show_all_inline_media": false,
 "favourites_count": 1,
 "description": " ... ",
 "profile_background_image_url": "http://a0.twimg.com/profile_background_images/179260978/karen01___2.jpeg",
 "profile_link_color": "bd6a3d",
 "profile_image_url": "http://a0.twimg.com/profile_images/994249198/twicon_normal.jpg",
?? "id_str": "17584067",
 "geo_enabled": false,
 "follow_request_sent": false,
 "profile_use_background_image": true,
 "profile_text_color": "ad3090",
 "profile_image_url_https": "https://si0.twimg.com/profile_images/994249198/twicon_normal.jpg",
 
 "status": {
   "coordinates": null,
   "in_reply_to_user_id": null,
   "geo": null,
   "truncated": false,
   "retweeted": false,
   "in_reply_to_screen_name": null,
   "id_str": "238527412609118209",
   "in_reply_to_status_id": null,
   "in_reply_to_status_id_str": null,
   "in_reply_to_user_id_str": null,
   "favorited": false,
   "source": "<a href=\"http://www.s-software.net/\" rel=\"nofollow\">...</a>",
   "id": 238527412609118200,
   "created_at": "Thu Aug 23 06:45:41 +0000 2012",
   "contributors": null,
   "place": null,
   "retweet_count": 2,
   "text": " ... "
 },
 "statuses_count": 3481,
 "profile_background_image_url_https": "https://si0.twimg.com/profile_background_images/179260978/karen01___2.jpeg",
 "following": false,
 "default_profile": false,
>> "screen_name": "Keji_NtyPe"
 },

 
 */
+ (TwitterUser *)listWithTwitterUser:(NSDictionary *) json
                 inManagedObjectContext:(NSManagedObjectContext *)context
{
    TwitterUser *user = nil;
    NSString *screen_name = [json objectForKey:@"screen_name"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TwitterUser"];
    request.predicate = [NSPredicate predicateWithFormat:@"screenname = %@", screen_name];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"screenname" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    
    // 'keypath sceenname not found in entity <NSSQLEntity TwitterUser id=4>'
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"TwitterUser" inManagedObjectContext:context];

        // user.blocked = [json objectForKey:@""];
        // user.followed = [json objectForKey:@""];
        // user.friend = [json objectForKey:@""];
        user.name = [json objectForKey:@"name"];
        user.profileimageURL = [json objectForKey:@"profile_image_url"];
        user.userid = [json objectForKey:@"id_str"];
        user.screenname = screen_name;
        NSLog(@"User: %@ ", user.screenname);
    } else {
        user = [matches lastObject];
    }
    
    return user;
    
}

@end
