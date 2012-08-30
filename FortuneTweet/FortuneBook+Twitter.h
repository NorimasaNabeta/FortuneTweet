//
//  FortuneBook+Twitter.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/29.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "FortuneBook.h"
#import "TwitterList.h"

@interface FortuneBook (Twitter)
+(NSString*) sha1:(NSString*)input;

+ (FortuneBook *)bookFromTwitter:(NSDictionary *) jsonList
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
