//
//  ManagedDocumentHelper.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/24.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DATABASE_FILENAME @"FortuneDatabase"

@interface ManagedDocumentHelper : NSObject
//+ (UIManagedDocument *)sharedManagedDocumentFortuneTweet:(NSString *)name;
+ (UIManagedDocument *)sharedManagedDocumentFortuneTweet;
+ (void) useDocument:(UIManagedDocument*) document usingBlock:(void (^)(BOOL))block debugComment:(NSString*)comment;

@end
