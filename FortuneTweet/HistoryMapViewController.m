//
//  HistoryMapViewController.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "HistoryMapViewController.h"
#import "History.h"
#import "Fortune.h"

@interface HistoryMapViewController () <MKMapViewDelegate>

@end

@implementation HistoryMapViewController
@synthesize mapView=_mapView;
@synthesize annotations=_annotations;

- (void) setAnnotations:(NSArray *)annotations;
{
    if (_annotations != annotations) {
        _annotations = annotations;
        
        HistoryAnnotation *history = [annotations objectAtIndex:0];
        if (history) {
            self.title = history.history.fortune.quotation;
        }
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        
        span.latitudeDelta=0.1;
        span.longitudeDelta=0.1;
        region.span=span;
        for (HistoryAnnotation *annotation in self.annotations){
            // Set min and max to the 1st object in the annotations
            __block CLLocationCoordinate2D min = [[self.annotations objectAtIndex:0] coordinate];
            __block CLLocationCoordinate2D max = min;
            
            [self.annotations enumerateObjectsUsingBlock:^(id element, NSUInteger idx, BOOL *stop){
                // We want to throw an error if it is not a dictionary
                assert([element isKindOfClass:[HistoryAnnotation class]]);
                HistoryAnnotation *location = element;
                
                // Get the coordinates name for each location
                CLLocationCoordinate2D currentCcoordinate = location.coordinate;
                min.latitude = MIN(min.latitude, currentCcoordinate.latitude);
                min.longitude = MIN(min.longitude, currentCcoordinate.longitude);
                max.latitude = MAX(max.latitude, currentCcoordinate.latitude);
                max.longitude = MAX(max.longitude, currentCcoordinate.longitude);
            }];
            CLLocationCoordinate2D center = CLLocationCoordinate2DMake((max.latitude + min.latitude)/2.0, (max.longitude + min.longitude)/2.0);
            MKCoordinateSpan span = MKCoordinateSpanMake(max.latitude - min.latitude, max.longitude - min.longitude);
            MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
            self.mapView.centerCoordinate=region.center;
            [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];

            // self.mapView.centerCoordinate = annotation.coordinate;
            // region.center=annotation.coordinate;
            // [self.mapView setRegion:region animated:TRUE];
            // [self.mapView regionThatFits:region];

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
