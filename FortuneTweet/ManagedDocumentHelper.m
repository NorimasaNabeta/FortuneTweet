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

//
//
//
+ (void) useDocument:(UIManagedDocument*) document usingBlock:(void (^)(BOOL))block debugComment:(NSString*)comment
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[document.fileURL path]]) {
        NSLog(@"useDocument:New %@ %@", comment, [document.fileURL path]);
        // does not exist on disk, so create it
        [document saveToURL:document.fileURL
           forSaveOperation:UIDocumentSaveForCreating completionHandler:block];
    } else if (document.documentState == UIDocumentStateClosed) {
        NSLog(@"useDocument:Open %@ %@", comment, [document.fileURL path]);
        // exists on disk, but we need to open it
        [document openWithCompletionHandler:block ];
    } else if (document.documentState == UIDocumentStateNormal) {
        NSLog(@"useDocument:Ready %@ %@", comment, [document.fileURL path]);
        // already open and ready to use
        block(YES);
    } else {
        BOOL success = YES;
        block(success);
    }
}




@end
