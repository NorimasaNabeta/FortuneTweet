//
//  TwitterUser.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TwitterUser : NSManagedObject

@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSString * screenname;
@property (nonatomic, retain) NSNumber * friend;
@property (nonatomic, retain) NSNumber * followed;
@property (nonatomic, retain) NSNumber * blocked;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * profileimageURL;

@end
