//
//  Fortune.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Fortune : NSManagedObject

@property (nonatomic, retain) NSString * fortuneid;
@property (nonatomic, retain) NSSet *tweets;
@end

@interface Fortune (CoreDataGeneratedAccessors)

- (void)addTweetsObject:(NSManagedObject *)value;
- (void)removeTweetsObject:(NSManagedObject *)value;
- (void)addTweets:(NSSet *)values;
- (void)removeTweets:(NSSet *)values;

@end
