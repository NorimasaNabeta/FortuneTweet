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

@implementation TwitterList (Twitter)

/*
+ (TwitterList *)listWithTwitterAccount:(NSDictionary *) json
                 inManagedObjectContext:(NSManagedObjectContext *)context
{
    TwitterList *list = nil;
    NSString *screen_name = [json valueForKeyPath:@"user.screen_name"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TwitterList"];
    NSString *twitterListTitle = [json objectForKey:@"slug"];
    // account.username == screen_name
    request.predicate = [NSPredicate predicateWithFormat:@"owner = %@ AND title = %@", screen_name, twitterListTitle];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        list = [NSEntityDescription insertNewObjectForEntityForName:@"TwitterList" inManagedObjectContext:context];
        list.title = twitterListTitle;
        list.descriptions = [json objectForKey:@"description"];
        list.mode = [json objectForKey:@"mode"];
        list.owner = screen_name;
        NSLog(@"List: %@ owned by %@", list.title, list.owner);
    } else {
        list = [matches lastObject];
    }
    
    return list;
    
}
*/

+ (TwitterList *)listWithTwitterAccount:(NSDictionary *) jsonList
                                members:(NSDictionary *) jsonMember
                 inManagedObjectContext:(NSManagedObjectContext *)context
{
    TwitterList *list = nil;
    NSString *screen_name = [jsonList valueForKeyPath:@"user.screen_name"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TwitterList"];
    NSString *twitterListTitle = [jsonList objectForKey:@"slug"];
    request.predicate = [NSPredicate predicateWithFormat:@"owner = %@ AND title = %@", screen_name, twitterListTitle];
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
        list.owner = screen_name;
        
        
        NSMutableSet *users = [[NSMutableSet alloc] initWithObjects: nil];
        for (NSDictionary *jsonUser in jsonMember){
            NSLog(@"Member:%@", [jsonUser objectForKey:@"screen_name"]);

            TwitterUser *user = [TwitterUser listWithTwitterUser:jsonUser inManagedObjectContext:context];
            if( user ){
                [users addObject:user];
            }
        }
        list.users = users;
        NSLog(@"List: %@ owned by %@", list.title, list.owner);
    } else {
        list = [matches lastObject];
    }
    
    return list;
    
}

@end
