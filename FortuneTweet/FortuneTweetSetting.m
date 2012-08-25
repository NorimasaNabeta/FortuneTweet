//
//  FortuneTweetSetting.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/25.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "FortuneTweetSetting.h"

@implementation FortuneTweetSetting

+ (NSDictionary *) getAppProperty: (NSString *) title
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *props = [defaults  objectForKey:title];
    if (! props){
        props = [[NSDictionary alloc] initWithObjectsAndKeys: nil];
    }
    
    return props;
}


+ (void) setAppProperty:(NSString *)title value:(NSDictionary *) dict
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *props = [[defaults objectForKey:title] mutableCopy];
    if (!props){
        props = [[NSMutableDictionary alloc] initWithObjectsAndKeys: nil];
    }
    
    [defaults setObject:[props copy] forKey:title];
    [defaults synchronize];
}

@end
