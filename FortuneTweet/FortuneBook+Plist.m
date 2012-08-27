//
//  FortuneBook+Plist.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/25.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "FortuneBook+Plist.h"
#import "Fortune+Plist.h"

@implementation FortuneBook (Plist)

#define COREDATA_ENTITY_NAME  @"FortuneBook"

+ (FortuneBook *)bookFromPlist:(NSDictionary *) pList
                 inManagedObjectContext:(NSManagedObjectContext *)context
{
    FortuneBook *book = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:COREDATA_ENTITY_NAME];
    NSString *bookId = [pList objectForKey:@"playId"];

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
        book.title = [pList objectForKey:@"playName"];
        book.bookid = bookId;
        book.rwmode = 0; // the book that loaded from plist is always readonly(0)

        NSMutableSet *forts = [[NSMutableSet alloc] initWithObjects: nil];
        for (NSDictionary *dict in [pList objectForKey:@"quotations"]) {
            // @synthesize character, act, scene, quotation;
            // <plist version="1.0"><array>
            // <dict><key>playId</key><string>d232c6c498283da7cb5b433a82e2b2bb9d5b39a9</string>
            // <key>playName</key><string>startrek</string>
            // <key>quotations</key><array>
            // <dict><key>qid</key><string>d0e8b2c867343776542b4cdea97d6d5bd4f8c640</string>
            // <key>act</key><string>stardate 3468.1.</string>
            // <key>scene</key><string>"Who Mourns for Adonais?"</string>
            // <key>character</key><string>Lt. Carolyn Palamas</string>
            // <key>quotation</key><string>A father doesn't destroy his children.</string></dict>
            //NSString *act = [dict objectForKey:@"act"];
            //NSString *scene = [dict objectForKey:@"scene"];
            //NSString *character = [dict objectForKey:@"character"];
            //NSString *quotation = [dict objectForKey:@"quotation"];
            //NSLog(@"act=%@, scn=%@, chr=%@, qot=%@", act,scene,character,quotation);
            Fortune *fort = [Fortune fortuneFromPlist:dict inManagedObjectContext:context];
            if( fort ){
                [forts addObject:fort];
            }
        }
        book.contents = forts;
    } else {
        book = [matches lastObject];
    }
    
    return book;
    
}

@end
