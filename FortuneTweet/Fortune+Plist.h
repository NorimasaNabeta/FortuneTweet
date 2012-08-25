//
//  Fortune+Plist.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/25.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "Fortune.h"

@interface Fortune (Plist)
+ (Fortune *)fortuneFromPlist:(NSDictionary *) pList
           inManagedObjectContext:(NSManagedObjectContext *)context;
@end
