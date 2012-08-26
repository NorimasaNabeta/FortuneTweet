//
//  HistoryMapViewController.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "HistoryMapViewController.h"

@interface HistoryMapViewController () <MKMapViewDelegate>

@end

@implementation HistoryMapViewController
@synthesize mapView=_mapView;
@synthesize annotations=_annotations;

- (void) setAnnotations:(NSArray *)annotations;
{
    if (_annotations != annotations) {
        _annotations = annotations;
    }
    [self updateMapView];
}

-(void) updateMapView
{
    if (self.mapView.annotations) {
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    if (self.annotations) {
        [self.mapView addAnnotations:self.annotations];
    }
}
-(void)setMapView:(MKMapView *)mapView
{
    _mapView=mapView;
    [self updateMapView];
}


- (IBAction)styleChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 1:
            self.mapView.mapType=MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType=MKMapTypeHybrid;
            break;
        default:
            self.mapView.mapType=MKMapTypeStandard;
            break;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate=self;
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - MKMapViewDelegate

-(void) mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"CalloutTapped:");
    //[self performSegueWithIdentifier:@"Map Photo View" sender:self];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString* PhotoAnnotationIdentifier = @"PhotoAnnotationIdentifier";
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:PhotoAnnotationIdentifier];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PhotoAnnotationIdentifier];
        aView.canShowCallout = YES;
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        // aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    aView.annotation = annotation;    
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    
    return aView;
}

-(void) mapView:(MKMapView *)mapView
didAddAnnotationViews:(NSArray *)views
{
    if (self.annotations && self.mapView.window) {
        
        for (HistoryAnnotation *annotation in self.annotations){
            self.mapView.centerCoordinate = annotation.coordinate;
            // http://stackoverflow.com/questions/2509223/apple-documentation-incorrect-about-mkmapview-regionthatfits
            // self.mapView.centerCoordinate=CLLocationCoordinate2DMake([self.history.latitude doubleValue],  [self.history.longitude doubleValue]);
        }
    }
}


- (void)mapView:(MKMapView *)mapView
didSelectAnnotationView:(MKAnnotationView *)aView
{
    // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //    UIImage *image = [self.delegate mapViewController:self imageForAnnotation:aView.annotation];
        // DEBUG
        // [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]]; // simulate 2 sec latency
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        NSString *idCurrent = [FlickrFetcher stringValueFromKey:((FlickrPhotoAnnotation *) aView.annotation).photo nameKey:FLICKR_PHOTO_ID];
    //            [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
    //     });
    // });

}


@end
