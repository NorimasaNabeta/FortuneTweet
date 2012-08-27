//
//  Fortune+Plist.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/25.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "Fortune+Plist.h"

@implementation Fortune (Plist)

#define COREDATA_ENTITY_NAME  @"Fortune"

+ (Fortune *)fortuneFromPlist:(NSDictionary *) pList
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Fortune *fort = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:COREDATA_ENTITY_NAME];
    NSString *fortuneid = [pList objectForKey:@"qid"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"fortuneid = %@", fortuneid];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"act" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        // @synthesize character, act, scene, quotation;
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
        //NSLog(@"id=%@",fortuneid);
        fort = [NSEntityDescription insertNewObjectForEntityForName:COREDATA_ENTITY_NAME inManagedObjectContext:context];
        fort.fortuneid = [pList objectForKey:@"qid"];
        fort.act = [pList objectForKey:@"act"];
        fort.scene = [pList objectForKey:@"scene"];
        fort.character = [pList objectForKey:@"character"];
        fort.quotation = [pList objectForKey:@"quotation"];
    } else {
        fort = [matches lastObject];
    }
    
    return fort;
    
}


@end
