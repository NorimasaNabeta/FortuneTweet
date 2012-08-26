//
//  FortuneListTableCell.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/26.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "FortuneListTableCell.h"

@implementation FortuneListTableCell
@synthesize contentWebView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
