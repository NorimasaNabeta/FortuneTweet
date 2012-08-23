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
@synthesize history=_history;

- (void) setHistory:(History *)history
{
    if (_history != history) {
        _history=history;
    }
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
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    aView.annotation = annotation;    
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    
    return aView;
}

-(void) mapView:(MKMapView *)mapView
didAddAnnotationViews:(NSArray *)views
{
    if (self.history && self.mapView.window) {
        
        // http://stackoverflow.com/questions/2509223/apple-documentation-incorrect-about-mkmapview-regionthatfits
        self.mapView.centerCoordinate=CLLocationCoordinate2DMake([self.history.latitude doubleValue],  [self.history.longitude doubleValue]);
    }
}


- (void)mapView:(MKMapView *)mapView
didSelectAnnotationView:(MKAnnotationView *)aView
{
}


@end
