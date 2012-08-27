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
/* 
- (NSString*)formatTimestamp:(NSTimeInterval)timeStamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:timeStamp];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss:SSS zzz"];
    // NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"YourTimeZone"];
    // [formatter setTimeZone:timeZone];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *dateString=[formatter stringFromDate:date];
    return dateString;
}
*/
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
