//
//  AppDelegate.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// @property (strong, nonatomic) ACAccountStore *accountStore;
// @property (strong, nonatomic) NSArray *accounts;
@property (strong, nonatomic) NSCache *imageCache;

@end
