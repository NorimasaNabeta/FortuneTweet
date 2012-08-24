//
//  HistoryMapViewController.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CoreDataTableViewController.h"
#import "History.h"
#import "HistoryAnnotation.h"


@interface HistoryMapViewController : UIViewController
@property (nonatomic,strong) NSArray *annotations;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end
