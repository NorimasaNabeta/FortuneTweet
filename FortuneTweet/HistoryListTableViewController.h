//
//  HistoryListTableViewController.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface HistoryListTableViewController : CoreDataTableViewController
@property (nonatomic, strong) UIManagedDocument *fortuneDatabase;
@end
