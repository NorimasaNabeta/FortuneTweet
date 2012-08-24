//
//  ManagedDocumentHelper.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/24.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "ManagedDocumentHelper.h"

// 'Creating a Singleton Instance'
// http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CocoaFundamentals/CocoaObjects/CocoaObjects.html#//apple_ref/doc/uid/TP40002974-CH4-SW32
// 'Grand Central Dispatch (GCD) Reference'
// http://developer.apple.com/library/ios/#documentation/Performance/Reference/GCD_libdispatch_Ref/Reference/reference.html#//apple_ref/doc/uid/TP40008079
//
@implementation ManagedDocumentHelper
//+ (UIManagedDocument *) sharedManagedDocumentFortuneTweet:(NSString *)name
+ (UIManagedDocument *) sharedManagedDocumentFortuneTweet
{
    static dispatch_once_t once;
    static UIManagedDocument *_fortuneDatabase;
    dispatch_once(&once, ^{
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        _fortuneDatabase = [[UIManagedDocument alloc] initWithFileURL:[url URLByAppendingPathComponent:DATABASE_FILENAME]];
    });
    return _fortuneDatabase;
}
@end
