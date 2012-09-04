//
//  TwitterLineTableViewController.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/31.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

//#import "CoreDataTableViewController.h"
#import "EGORefreshTableViewController.h"

@class TwitterLineTableViewController;
@protocol TwitterLineTableViewControllerDelegate <NSObject>
- (UIImage *)lineViewController:(TwitterLineTableViewController *)sender imageForTweet:(id)tweet;
@end

@interface TwitterLineTableViewController : EGORefreshTableViewController
@property (strong, nonatomic) ACAccount *account;
@property (strong, nonatomic) id timeline;

@property (strong, nonatomic) NSString *slug;
@property (strong, nonatomic) id delegate;
@end
