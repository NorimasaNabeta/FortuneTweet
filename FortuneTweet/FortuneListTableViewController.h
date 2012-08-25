//
//  FortuneListTableViewController.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import "CoreDataTableViewController.h"
#import "FortuneBook.h"
#import "Fortune.h"

@interface FortuneListTableViewController : CoreDataTableViewController
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) NSArray *accounts;
@property (strong, nonatomic) FortuneBook *fortunebook;
@end
