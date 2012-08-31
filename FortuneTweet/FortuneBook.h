//
//  FortuneBook.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/31.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Fortune, TwitterList;

@interface FortuneBook : NSManagedObject

@property (nonatomic, retain) NSString * bookid;
@property (nonatomic, retain) NSNumber * rwmode;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *contents;
@property (nonatomic, retain) TwitterList *twitterlist;
@end

@interface FortuneBook (CoreDataGeneratedAccessors)

- (void)addContentsObject:(Fortune *)value;
- (void)removeContentsObject:(Fortune *)value;
- (void)addContents:(NSSet *)values;
- (void)removeContents:(NSSet *)values;

@end
