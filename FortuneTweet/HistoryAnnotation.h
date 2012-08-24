//
//  HistoryAnnotation.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/24.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "History.h"

@interface HistoryAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) History *history;
+ (HistoryAnnotation *)annotationForHistory:(History *)history;

@end
