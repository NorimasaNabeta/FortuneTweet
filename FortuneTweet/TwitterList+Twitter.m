//
//  TwitterList+Twitter.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "TwitterList+Twitter.h"
#import "TwitterAPI.h"

@implementation TwitterList (Twitter)

     
+ (TwitterList *)listWithTwitterAccount:(ACAccount *) account
                                listAll:(NSDictionary *) json
                inManagedObjectContext:(NSManagedObjectContext *)context
{
    TwitterList *list = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TwitterList"];
    NSString *twitterListTitle = [json objectForKey:@"slug"];
    // account.username == screen_name
    request.predicate = [NSPredicate predicateWithFormat:@"owner = %@ AND title = %@", account.username, twitterListTitle];
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
        list.owner = account.username;
        NSLog(@"List: %@ owned by %@", list.title, list.owner);
    } else {
        list = [matches lastObject];
    }
    
    return list;

}

@end
