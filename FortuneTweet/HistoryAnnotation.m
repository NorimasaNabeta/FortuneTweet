//
//  HistoryAnnotation.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/24.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "HistoryAnnotation.h"

@implementation HistoryAnnotation
@synthesize history=_history;

+ (HistoryAnnotation *)annotationForHistory:(History *)history
{
    HistoryAnnotation *annotation = [[HistoryAnnotation alloc] init];
    annotation.history = history;
    
    return annotation;
}

#pragma mark - MKAnnotation
- (NSString *)title
{
    return [NSString stringWithFormat:@"%@", self.history.timestamp];
}

- (NSString *)subtitle
{
    return (self.history.address ? self.history.address: @"Here" );
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.history.latitude doubleValue];
    coordinate.longitude = [self.history.longitude doubleValue];
    return coordinate;
}

@end
