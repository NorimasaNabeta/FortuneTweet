//
//  UserListTableViewController.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

#import "CoreDataTableViewController.h"
#import "TwitterList.h"

@interface UserListTableViewController : CoreDataTableViewController
@property (nonatomic, strong) TwitterList *twitterList;
@property (nonatomic, strong) ACAccount *account;
@end
