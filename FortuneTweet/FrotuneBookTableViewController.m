//
//  FrotuneBookTableViewController.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//
#import <Accounts/Accounts.h>

#import "FrotuneBookTableViewController.h"
#import "History.h"
#import "History+CLLocation.h"
#import "ManagedDocumentHelper.h"

#import "FortuneBook.h"
#import "FortuneBook+Plist.h"

#import "FortuneListTableViewController.h"

@interface FrotuneBookTableViewController () <FortuneListTableViewControllerDelegate>
@end

@implementation FrotuneBookTableViewController
@synthesize locationManager=_locationManager;
@synthesize accountStore=_accountStore;
@synthesize accounts=_accounts;

- (void) importDefaultBook
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"startrek" withExtension:@"plist"];
    NSArray *playDictionariesArray = [[NSArray alloc] initWithContentsOfURL:url];
    
    UIManagedDocument *sharedDocument = [ManagedDocumentHelper sharedManagedDocumentFortuneTweet];
    for (NSDictionary *playDictionary in playDictionariesArray) {
        [sharedDocument.managedObjectContext performBlock:^{
            [FortuneBook bookFromPlist:playDictionary inManagedObjectContext:sharedDocument.managedObjectContext];
            [sharedDocument saveToURL:sharedDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
        }];
    }
}


- (void)setupFetchedResultsController
{
    UIManagedDocument *sharedDocument = [ManagedDocumentHelper sharedManagedDocumentFortuneTweet];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FortuneBook"];
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    request.sortDescriptors = [NSArray arrayWithObject:sort1];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:sharedDocument.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
	// Start the location manager. -->didUpdateToLocation
    dispatch_sync(dispatch_get_main_queue(), ^{
        // NOTICE,A location manager (0xfe6aa20) was created on a dispatch queue executing on a thread other than the main thread.
        // It is the developer's responsibility to ensure that there is a run loop running on the thread on
        // which the location manager object is allocated.
        // In particular, creating location managers in arbitrary dispatch queues (not attached to the main queue) is not supported
        // and will result in callbacks not being received.
        //
         //[[self locationManager] startUpdatingLocation];
        [self importDefaultBook];
    });

}

- (ACAccountStore *) accountStore
{
    if (_accountStore == nil) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
}

// TODO: If account is ok, fetch the profile of current accounts, and save into the database. 
//
- (void) checkAccount
{
    if (_accounts == nil) {
        ACAccountType *accountTypeTwitter = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [self.accountStore requestAccessToAccountsWithType:accountTypeTwitter
                                     withCompletionHandler:^(BOOL granted, NSError *error) {
                                         if(granted) {
                                             self.accounts = [self.accountStore accountsWithAccountType:accountTypeTwitter];
                                             UIManagedDocument *sharedDocument = [ManagedDocumentHelper sharedManagedDocumentFortuneTweet];
                                             [ManagedDocumentHelper useDocument:sharedDocument
                                                                     usingBlock: ^(BOOL success){
                                                                         [self setupFetchedResultsController];
                                                                     }
                                                                   debugComment:@"BK"];

                                             
                                         } else {
                                             NSLog(@"ACCOUNT FAILED OR NOT GRANTED.");
                                         }
                                     }];
    }
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
    [[self locationManager] startUpdatingLocation];    

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
    [self checkAccount];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Book Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    FortuneBook *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = book.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"@%d", [book.contents count]];
    
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
	NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);

//    UIManagedDocument *sharedDocument = [ManagedDocumentHelper sharedManagedDocumentFortuneTweet];
//    [sharedDocument.managedObjectContext performBlock:^{
//        [History historyWithCLLocation:newLocation inManagedObjectContext:sharedDocument.managedObjectContext];
//        [sharedDocument saveToURL:sharedDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
//    }];
    
	// Work around a bug in MapKit where user location is not initially zoomed to.
	if (oldLocation == nil) {
		// Zoom to the current user location.
		// MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.0, 1500.0);
		// [regionsMapView setRegion:userLocation animated:YES];
	}
}

//
//
//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    FortuneBook *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([segue.destinationViewController respondsToSelector:@selector(setFortunebook:)]) {
        [segue.destinationViewController performSelector:@selector(setFortunebook:) withObject:book];
        [segue.destinationViewController performSelector:@selector(setDelegate:) withObject:self];
        
    }
}

#pragma mark - FortuneListTableViewControllerDelegate

- (CLLocation *) locationOfTweetController:(FortuneListTableViewController *)sender
{
    return [self.locationManager location];
}


@end
