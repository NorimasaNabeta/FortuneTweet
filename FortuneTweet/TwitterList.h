//
//  TwitterList.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/25.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TwitterUser;

@interface TwitterList : NSManagedObject

@property (nonatomic, retain) NSString * descriptions;
@property (nonatomic, retain) NSString * mode;
@property (nonatomic, retain) NSString * ownername;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *users;
@end

@interface TwitterList (CoreDataGeneratedAccessors)

- (void)addUsersObject:(TwitterUser *)value;
- (void)removeUsersObject:(TwitterUser *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
