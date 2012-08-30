//
//  TwitterUser.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/30.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TwitterList;

@interface TwitterUser : NSManagedObject

@property (nonatomic, retain) NSNumber * blocked;
@property (nonatomic, retain) NSNumber * followed;
@property (nonatomic, retain) NSNumber * friend;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * profileimageURL;
@property (nonatomic, retain) NSString * screenname;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSSet *lists;
@end

@interface TwitterUser (CoreDataGeneratedAccessors)

- (void)addListsObject:(TwitterList *)value;
- (void)removeListsObject:(TwitterList *)value;
- (void)addLists:(NSSet *)values;
- (void)removeLists:(NSSet *)values;

@end
