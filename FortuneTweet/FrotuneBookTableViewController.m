//
//  FrotuneBookTableViewController.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "FrotuneBookTableViewController.h"
#import "History.h"
#import "History+CLLocation.h"

@interface FrotuneBookTableViewController ()

@end

@implementation FrotuneBookTableViewController
@synthesize locationManager=_locationManager;

- (void)useDocument
{
    NSLog(@"useDocument: %@", [self.fortuneDatabase.fileURL path]);
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.fortuneDatabase.fileURL path]]) {
        // does not exist on disk, so create it
        [self.fortuneDatabase saveToURL:self.fortuneDatabase.fileURL
                       forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                           // [self setupFetchedResultsController];
                           // [self fetchTwitterDataIntoDocument:self.fortuneDatabase];
                           
                       }];
    } else if (self.fortuneDatabase.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        //[self.fortuneDatabase openWithCompletionHandler:^(BOOL success) {
        //    [self setupFetchedResultsController];
        //}];
    } else if (self.fortuneDatabase.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        // [self setupFetchedResultsController];
    }
}
- (void)setFortuneDatabase:(UIManagedDocument *)fortuneDatabase
{
    if (_fortuneDatabase != fortuneDatabase) {
        _fortuneDatabase = fortuneDatabase;
    }
    [self useDocument];
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

	// Start the location manager. -->didUpdateToLocation
	// [[self locationManager] startUpdatingLocation];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.fortuneDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"FortuneDatabase"];
        self.fortuneDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.locationManager = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
// #warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Book Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark Location manager

/**
 Return a location manager -- create one if necessary.
 */
- (CLLocationManager *)locationManager
{
	
    if (_locationManager != nil) {
		return _locationManager;
	}
	_locationManager = [[CLLocationManager alloc] init];
	[_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[_locationManager setDelegate:self];
	
	return _locationManager;
}

#pragma mark - CLLocationManagerDelegate
/**
 Conditionally enable the Add button:
 If the location manager is generating updates, then enable the button;
 If the location manager is failing, then disable the button.
 */

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
	NSLog(@"didFailWithError: %@", error);
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 60.0) return; // 10.0 second
    if (!self.fortuneDatabase) return;

	NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);

    // [self.fortuneDatabase.managedObjectContext performBlock:^{
    //     [History historyWithCLLocation:newLocation inManagedObjectContext:self.fortuneDatabase.managedObjectContext];
    //     [self.fortuneDatabase saveToURL:self.fortuneDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
    //}];

    
	// Work around a bug in MapKit where user location is not initially zoomed to.
	if (oldLocation == nil) {
		// Zoom to the current user location.
		// MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.0, 1500.0);
		// [regionsMapView setRegion:userLocation animated:YES];
	}
}


- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region  {
	// NSString *event = [NSString stringWithFormat:@"didEnterRegion %@ at %@", region.identifier, [NSDate date]];
	// [self updateWithEvent:event];
}


- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region {
	// NSString *event = [NSString stringWithFormat:@"didExitRegion %@ at %@", region.identifier, [NSDate date]];
	// [self updateWithEvent:event];
}


- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(CLRegion *)region
              withError:(NSError *)error {
	// NSString *event = [NSString stringWithFormat:@"monitoringDidFailForRegion %@: %@", region.identifier, error];
	// [self updateWithEvent:event];
}



@end
