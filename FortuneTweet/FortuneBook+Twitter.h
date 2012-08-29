//
//  FortuneBook+Twitter.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/29.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "FortuneBook.h"

@interface FortuneBook (Twitter)
+ (FortuneBook *)bookFromTwitter:(NSDictionary *) userResult
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
