//
//  Fortune.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/09/07.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FortuneBook, History;

@interface Fortune : NSManagedObject

@property (nonatomic, retain) NSString * act;
@property (nonatomic, retain) NSString * character;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * fortuneid;
@property (nonatomic, retain) NSString * quotation;
@property (nonatomic, retain) NSString * scene;
@property (nonatomic, retain) FortuneBook *book;
@property (nonatomic, retain) NSOrderedSet *tweets;
@end

@interface Fortune (CoreDataGeneratedAccessors)

- (void)insertObject:(History *)value inTweetsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTweetsAtIndex:(NSUInteger)idx;
- (void)insertTweets:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTweetsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTweetsAtIndex:(NSUInteger)idx withObject:(History *)value;
- (void)replaceTweetsAtIndexes:(NSIndexSet *)indexes withTweets:(NSArray *)values;
- (void)addTweetsObject:(History *)value;
- (void)removeTweetsObject:(History *)value;
- (void)addTweets:(NSOrderedSet *)values;
- (void)removeTweets:(NSOrderedSet *)values;
@end
