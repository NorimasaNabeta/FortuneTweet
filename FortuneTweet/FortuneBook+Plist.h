//
//  FortuneBook+Plist.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/25.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "FortuneBook.h"

@interface FortuneBook (Plist)
+ (FortuneBook *)bookFromPlist:(NSDictionary *) pList
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
