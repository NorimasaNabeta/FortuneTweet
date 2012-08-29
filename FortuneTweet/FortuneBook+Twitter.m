//
//  FortuneBook+Twitter.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/29.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "FortuneBook+Twitter.h"

@implementation FortuneBook (Twitter)

#define COREDATA_ENTITY_NAME  @"FortuneBook"


// bookId <-- hash value of list title
// http://stackoverflow.com/questions/3468268/objective-c-sha1
// #include <CommonCrypto/CommonDigest.h>
// unsigned char digest[CC_SHA1_DIGEST_LENGTH];
// NSData *stringBytes = [someString dataUsingEncoding: NSUTF8StringEncoding]; /* or some other encoding */
// if (CC_SHA1([stringBytes bytes], [stringBytes length], digest)) {
//     /* SHA-1 hash has been calculated and stored in 'digest'. */
//     ...
// }
//
// title  <-- user/list_name (i.e.  @norimasa_nabeta/anime )
// 
+ (FortuneBook *)bookFromTwitter:(NSDictionary *) userResult
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    FortuneBook *book = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:COREDATA_ENTITY_NAME];

    NSString *bookId = [userResult objectForKey:@"playId"]; // <--
    
    request.predicate = [NSPredicate predicateWithFormat:@"bookid = %@", bookId];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // NSLog(@"BOOK=%@",bookId);
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        book = [NSEntityDescription insertNewObjectForEntityForName:COREDATA_ENTITY_NAME inManagedObjectContext:context];
        book.title = [userResult objectForKey:@"playName"]; //
        book.bookid = bookId;
        book.rwmode = [NSNumber numberWithBool:1]; // the book that created based on twitter list readwrite(1)
        
        // *FortuneBook creted from Twitter has no fortune record at initil state.
        
        // NSMutableSet *forts = [[NSMutableSet alloc] initWithObjects: nil];
        // for (NSDictionary *dict in [userResult objectForKey:@"quotations"]) { //
        //     Fortune *fort = [Fortune fortuneFromTwitter:dict inManagedObjectContext:context];
        //     if( fort ){
        //         [forts addObject:fort];
        //     }
        // }
        // book.contents = forts;
    } else {
        book = [matches lastObject];
    }
    
    return book;
    
}

@end
