//
//  TwitterUser.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/09/07.
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
@property (nonatomic, retain) NSData * profileimageBlob;
@property (nonatomic, retain) NSString * profileimageURL;
@property (nonatomic, retain) NSString * screenname;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSSet *belonglists;
@property (nonatomic, retain) NSSet *ownlists;
@end

@interface TwitterUser (CoreDataGeneratedAccessors)

- (void)addBelonglistsObject:(TwitterList *)value;
- (void)removeBelonglistsObject:(TwitterList *)value;
- (void)addBelonglists:(NSSet *)values;
- (void)removeBelonglists:(NSSet *)values;

- (void)addOwnlistsObject:(TwitterList *)value;
- (void)removeOwnlistsObject:(TwitterList *)value;
- (void)addOwnlists:(NSSet *)values;
- (void)removeOwnlists:(NSSet *)values;

@end
